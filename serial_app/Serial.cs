using System;
using System.IO;
using System.IO.Ports;
using System.Globalization;
using System.Security;
using System.Threading;

namespace cmpe264_serial
{
    class SerialCommApp
    {
        public static void Main()
        {
            Console.WriteLine("- > Enter the name of a serial port from the list below");

            string[] portNames = SerialPort.GetPortNames();
            if (portNames.Length == 0)
            {
                Console.WriteLine("- > ERROR: No serial ports found. Press enter to exit");
            }

            for (int i = 0; i < portNames.Length; i++)
            {
                Console.WriteLine("    {0}", portNames[i]);
            }
            Console.Write("- > ");

            String portName = Console.ReadLine();

            // UART settings. These must match the UART transceiver module (uart.v)
            int baudRate = 9600;
            Parity parityBits = Parity.None;
            int dataBits = 8;
            StopBits stopBits = StopBits.One;

            const int READ_TIMEOUT = 500;
            const int WRITE_TIMEOUT = 500;
           
            SerialPort serial = new SerialPort(portName, baudRate, parityBits, dataBits, stopBits);
            serial.ReadTimeout = READ_TIMEOUT;
            serial.WriteTimeout = WRITE_TIMEOUT;
            if (!openSerialPort(serial))
            {
                Console.WriteLine("Failed to open serial port. Press enter to exit");
            }
            Console.WriteLine("- > Serial port opened successfully");
            Console.WriteLine("- > Current UART settings");
            Console.WriteLine("    BAUD: {0}", baudRate);
            Console.WriteLine("    Parity: {0}", parityBits);
            Console.WriteLine("    Data bits: {0}", dataBits);
            Console.WriteLine("    Stop bits: {0}", stopBits);

            bool exit = false;
            String[] input;
            while (!exit)
            {
                Console.WriteLine("- > Enter a command, or type 'help'");
                Console.Write("- > ");
                input = Console.ReadLine().Split(' ');

                if (input[0].Equals("help"))
                {
                    doHelpCommand();
                }
                else if (input[0].Equals("read"))
                {
                    doReadCommand(serial, input);
                }
                else if (input[0].Equals("write"))
                {
                    doWriteCommand(serial, input);
                }
                else if (input[0].Equals("file"))
                {
                    doFileCommand(serial, input);
                }
                else if (input[0].Equals("exit"))
                {
                    serial.Close();
                    exit = true;
                }
                else
                {
                    Console.WriteLine("- > Invalid command!");
                }
            }
        }

        static void doReadCommand(SerialPort serial, string[] input)
        {
            if (input.Length != 2)
            {
                Console.WriteLine("- READ > ERROR: bad arguments");
                return;
            }
            byte addr = (byte)(uint.Parse(input[1], NumberStyles.AllowHexSpecifier));
            uint rxData;

            serial.DiscardInBuffer();

            try
            {
                rxData = serialRead(serial, addr);
            }
            catch (TimeoutException)
            {
                Console.WriteLine("- READ > ERROR: read timed out");
                return;
            }

            Console.WriteLine("- READ > Received data: {0:X}", rxData);
        }

        static void doWriteCommand(SerialPort serial, string[] input)
        {
            if (input.Length != 3 && input.Length != 4)
            {
                Console.WriteLine("- WRITE > ERROR: bad arguments");
                return;
            }

            bool verifyWrite = true;
            if (input.Length == 4)
            {
                if (input[3] == "-noverify")
                {
                    verifyWrite = false;
                }
            }

            byte addr = (byte)(uint.Parse(input[1], NumberStyles.AllowHexSpecifier));
            uint data = uint.Parse(input[2], NumberStyles.AllowHexSpecifier);

            if (serialWrite(serial, addr, data, false)) // TODO re-enable verifyWrite
            {
                Console.WriteLine("- WRITE > Write completed successfully");
            }
            else
            {
                Console.WriteLine("- WRITE > ERROR: Write failed");
            }
        }

        static void doFileCommand(SerialPort serial, string[] input)
        {
            if (input.Length != 3 && input.Length != 4)
            {
                Console.WriteLine("- FILE > ERROR: bad arguments");
                return;
            }

            bool verifyWrite = true;
            if (input.Length == 4)
            {
                if (input[3] == "-noverify")
                {
                    verifyWrite = false;
                }
            }

            string filePath = input[1];
            uint startingAddr = uint.Parse(input[2], NumberStyles.AllowHexSpecifier);

            string[] lines;
            try
            {
                lines = readFile(filePath);
            }
            catch (IOException)
            {
                Console.WriteLine("- FILE > Failed to open file");
                return;
            }

            bool failed = false;
            for (uint i = 0; i < lines.Length; i++)
            {
                byte addr = (byte)(startingAddr + i);
                uint data = uint.Parse(lines[i], NumberStyles.AllowHexSpecifier);

                Console.WriteLine("- FILE > Writing {0:X} to address {1:X}...", data, addr);
                if (!serialWrite(serial, addr, data, false)) // TODO re-enable verifyWrite
                {
                    Console.WriteLine("- FILE > File write failed");
                    failed = true;
                    break;
                }
                Thread.Sleep(5);
            }
            if (!failed)
            {
                Console.WriteLine("- FILE > File write completed successfully");
            }
        }

        static void doHelpCommand()
        {
            Console.WriteLine("- HELP > List of commands. Note that the format for all addresses/data is hex");
            Console.WriteLine("         read <addr>");
            Console.WriteLine("            Reads a single byte from the specified address");
            Console.WriteLine("         write <addr> <data> [-noverify]");
            Console.WriteLine("            Writes a single byte to the specified address");
            Console.WriteLine("         file  <file_name> <starting_addr> [-noverify]");
            Console.WriteLine("            Writes an entire file of bytes starting at the specified address.");
            Console.WriteLine("         exit ");
            Console.WriteLine("            Exits program");
        }

        static string[] readFile(string filePath)
        {
            string[] lines;
            try
            {
                lines = System.IO.File.ReadAllLines(filePath);
            }
            catch (ArgumentException)
            {
                Console.WriteLine("- FILE > Invalid pathname");
                throw new IOException();
            }
            catch (PathTooLongException)
            {
                Console.WriteLine("- FILE > Path too long");
                throw new IOException();
            }
            catch (DirectoryNotFoundException)
            {
                Console.WriteLine("- FILE > Can't find directory");
                throw new IOException();
            }
            catch (UnauthorizedAccessException)
            {
                Console.WriteLine("- FILE > Do not have permission to read this file");
                throw new IOException();
            }
            catch (FileNotFoundException)
            {   
                Console.WriteLine("- FILE > Can't find file");
                throw new IOException();
            }
            catch (IOException)
            {
                Console.WriteLine("- FILE > IO failed in reading this file");
                throw new IOException();
            }
            catch (NotSupportedException)
            {
                Console.WriteLine("- FILE > Path is in an invalid format");
                throw new IOException();
            }
            catch (SecurityException)
            {
                Console.WriteLine("- FILE > Do not have permission to read this file");
                throw new IOException();
            }

            return lines;
        }

        static uint serialRead(SerialPort serial, byte addr)
        {
            const bool write = false;
            byte[] tx_byte = { formAddress(addr, write) };
            serial.Write(tx_byte, 0, 1);

            byte[] rx_data_bytes = new byte[4];
            for (int i = 0; i < 4; i++)
            {
                try
                {
                    rx_data_bytes[i] = (byte)serial.ReadByte();
                }
                catch (TimeoutException)
                {
                    throw new TimeoutException(); // ???
                }
            }

            return toInt(rx_data_bytes);
        }

        static bool serialWrite(SerialPort serial, byte addr, uint data, bool verifyWrite)
        {
            const bool write = true;
            byte[] tx_byte = { formAddress(addr, write) };
            serial.Write(tx_byte, 0, 1); // address 
            Thread.Sleep(1);
            serial.Write(toByteArray(data), 0, 4); // data

            if (verifyWrite)
            {
                Thread.Sleep(1);
                // Check that value was successfully written by reading it back
                serial.DiscardInBuffer();
                try
                {
                    if (data == serialRead(serial, addr))
                    {
                        return true;
                    }
                    else
                    {
                        Console.WriteLine("- WRITE > ERROR: Verification read did not match");
                        return false;
                    }
                }
                catch (TimeoutException)
                {
                    Console.WriteLine("- WRITE > ERROR: Verification read timed out");
                    return false;
                }
            }

            return true;
        }

        static byte formAddress(byte addr, bool write)
        {
            const byte WRITE_MASK = 0x80;
            const byte READ_MASK = 0x00;
            if (write)
            {
                return (byte)(addr + WRITE_MASK);
            }
            else
            {
                return (byte)(addr + READ_MASK);
            }
        }

        static byte[] toByteArray(uint val)
        {
            byte[] arr = new byte[4];
            arr[0] = (byte)val;
            arr[1] = (byte)(val >> 8);
            arr[2] = (byte)(val >> 16);
            arr[3] = (byte)(val >> 24);

            return arr;
        }

        static uint toInt(byte[] arr)
        {
            uint val = 0;
            val += arr[0];
            val += (uint)(arr[1] << 8);
            val += (uint)(arr[2] << 16);
            val += (uint)(arr[3] << 24);

            return val;
        }

        static bool openSerialPort(SerialPort serial)
        {
            try
            {
                serial.Open();
            }
            catch (UnauthorizedAccessException)
            {
                Console.WriteLine("ERROR: Access to port denied. Press enter to exit");
                Console.ReadLine();
                return false;
            }
            catch (ArgumentOutOfRangeException)
            {
                Console.WriteLine("ERROR: Bad UART settings. Press enter to exit");
                Console.ReadLine();
                return false;
            }
            catch (ArgumentException)
            {
                Console.WriteLine("ERROR: Bad port name. Press enter to exit");
                Console.ReadLine();
                return false;
            }
            catch (IOException)
            {
                Console.WriteLine("ERROR: Invalid port state. Press enter to exit");
                Console.ReadLine();
                return false;
            }
            catch (InvalidOperationException)
            {
                Console.WriteLine("ERROR: Port already open. Press enter to exit");
                Console.ReadLine();
                return false;
            }

            return true;
        }
    }
}


