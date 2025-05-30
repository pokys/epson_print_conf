# epson_print_conf

Epson Printer Configuration tool via SNMP (TCP/IP)

## Product Overview

The Epson Printer Configuration Tool provides an interface for the configuration and monitoring of Epson printers connected via Wi-Fi using the SNMP protocol. A range of features are offered for both end-users and developers.

The software also includes a configurable printer dictionary, which can be easily extended. In addition, it is possible to import and convert external Epson printer configuration databases.

## Docker Compose
```bash
version: "3.3"
services:
  epson_print_conf:
    ports:
      - 5990:5990
    environment:
      - HOME=/
    container_name: epson-print-config
    image: pokys/epson_print_conf
    command: x11vnc -usepw -create
networks: {}

```

## Key Features

- __SNMP Interface__: Connect and manage Epson printers using SNMP over TCP/IP, supporting Wi-Fi connections (not USB).

    Printers are queried via Simple Network Management Protocol (SNMP) with a set of Object Identifiers (OIDs) used by Epson printers. Some of them are also valid with other printer brands. SNMP is used to manage the EEPROM and read/set specific Epson configuration.

- __Detailed Status Reporting__: Produce a comprehensive printer status report (with options to focus on specific details).

    Epson printers produce a status response in a proprietary "new binary format" named @BDC ST2, including a data structure which is partially undocumented (such messages
    start with `@BDC [SP] ST2 [CR] [LF]` ...). @BDC ST2 is used to convey various aspects of the status of the printer, such as errors, paper status, ink and more. The element fields of this format may vary depending on the printer model. The *Epson Printer Configuration Tool* can decode all element fields found in publicly available Epson Programming Manuals of various printer models (a relevant subset of fields used by the Epson printers).

- __Advanced Maintenance Functions__:
    - Open the Web interface of the printer (via the default browser).
    - Reset the ink waste counter.

      The ink waste counters track the amount of ink discarded during maintenance tasks to prevent overflow in the waste ink pads. Once the counters indicate that one of the printer pads is full, the printer will stop working to avoid potential damage or ink spills. Resetting the ink waste counter extends the printer operation while a pad maintenance or tank replacement is programmed (operation that shall necessarily be pefromed).
    - Adjust the power-off timer (for energy efficiency).
    - Change the _First TI Received Time_,

      The *First TI Received Time* in Epson printers typically refers to the timestamp of the first transmission instruction to the printer. This feature tracks when the printer first operated.

    - Change the printer WiFi MAC address and the printer serial number (typically used in specialized scenarios where specific device identifiers are required).
    - Read and write to EEPROM addresses.
    - Dump and analyze sets of EEPROM addresses.
    - Detect the access key (*read_key* and *write_key*) and some attributes of the printer configuration.

      The GUI includes some features that attempt to detect the attributes of an Epson printer whose model is not included in the configuration; such features can also be used with known printers, to detect additional parameters.

    - Import and export printer configuration datasets in various formats: epson_print_conf pickle, Reinkpy XML, Reinkpy TOML.

    - Access various administrative and debugging options.

- __Available Interfaces__:
    - __Graphical User Interface__: [Tcl/Tk](https://en.wikipedia.org/wiki/Tk_(software)) platform-independent GUI with an autodiscovery function that detects printer IP addresses and model names.
    - __Command Line Tool__: For users who prefer command-line interactions, providing the full set of features.
    - __Python API Interface__: For developers to integrate and automate printer management tasks.

Note on the ink waste counter reset feature: resetting the ink waste counter is just removing a lock; not replacing the tank will reduce the print quality and make the ink spill.

## Install-2-go (macOS)
Prerequirements: Docker, TigerVNC

### 1. Install Tiger VNC Viewer

```bash
brew install tigervnc-viewer
```

### 2. Download Docker Image

```bash
docker pull mvoreakou/epson-god-mode:latest
```

### 3. App run
```bash
docker run --rm --publish 5990:5990 --env HOME=/ mvoreakou/epson-god-mode x11vnc -usepw -create
```
### 4. Open GUI
Open tiger VNC that was installed on your mac, and fill

`VNC server:` `localhost:5990`

Click `Connect` & voila!


## Installation

Install requirements using *requirements.txt*:

```bash
git clone https://github.com/Ircama/epson_print_conf
cd epson_print_conf
pip install -r requirements.txt
```

Notes (at the time of writing):

- [before pysnmp, install pyasn1 with version 0.4.8 and not 0.5](https://github.com/etingof/pysnmp/issues/440#issuecomment-1544341598)
- [pull pysnmp from the GitHub master branch, not from PyPI](https://stackoverflow.com/questions/54868134/snmp-reading-from-an-oid-with-three-libraries-gives-different-execution-times#comment96532761_54869361)

This program exploits [pysnmp](https://github.com/etingof/pysnmp), basing on the related [documentation](https://pysnmp.readthedocs.io/).

It is tested with Ubuntu / Windows Subsystem for Linux, Windows.

## Usage

### Running the pre-built GUI executable code

The *epson_print_conf.zip* archive in the [Releases](https://github.com/Ircama/epson_print_conf/releases/latest) folder incudes the *epson_print_conf.exe* executable asset; the ZIP archive is auto-generated by a [GitHub Action](.github/workflows/build.yml). *epson_print_conf.exe* is a Windows GUI that can be directly executed.

### Running the GUI with Python

Run *ui.py* as in this example:

```
python ui.py
```

This GUI runs on any Operating Systems supported by Python (not just Windows), but needs that [Tkinter](https://docs.python.org/3/library/tkinter.html) is installed. While the *Tkinter* package might be generally available by default with recent Python versions for Windows, [it needs a specific installation on other Operating Systems](https://stackoverflow.com/questions/76105218/why-does-tkinter-or-turtle-seem-to-be-missing-or-broken-shouldnt-it-be-part).

GUI usage:

```
usage: ui.py [-h] [-m MODEL] [-a HOSTNAME] [-P PICKLE_FILE] [-O] [-d]

optional arguments:
  -h, --help            show this help message and exit
  -m MODEL, --model MODEL
                        Printer model. Example: -m XP-205
  -a HOSTNAME, --address HOSTNAME
                        Printer host name or IP address. (Example: -a 192.168.1.87)
  -P PICKLE_FILE, --pickle PICKLE_FILE
                        Load a pickle configuration archive saved by parse_devices.py
  -O, --override        Replace the default configuration with the one in the pickle file instead of merging (default is to merge)
  -d, --debug           Print debug information

epson_print_conf GUI
```

### How to import an external printer configuration DB

With the GUI, the following operations are possible (from the file menu):

- Load a PICKLE configuration file or web URL.

  This operation allows to open a file saved with the GUI ("Save the selected printer configuration to a PICKLE file") or with the *parse_devices.py* utility. In addition to the printer configuration DB, this file includes the last used IP address and printer model in order to simplify the GUI usage.

- Import an XML configuration file or web URL

  This option allows to import the XML configuration file downloaded from <https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d>. Alternatively, this option directly accepts the [source Web URL](https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d) of this file, incorporating the download operation into the GUI.

- Import a TOML configuration file or web URL

  Similar to the XML import, this option allows to load the TOML configuration file downloaded from <https://codeberg.org/atufi/reinkpy/raw/branch/main/reinkpy/epson.toml> and also accepts the [source Web URL](https://codeberg.org/atufi/reinkpy/raw/branch/main/reinkpy/epson.toml) of this file, incorporating the download operation into the GUI.

Other menu options allow to filter or clean up the configuration list, as well as select a specific printer model and then save data to a PICKLE file.

### How to detect parameters of an unknown printer

- Detect Printers:

  Start by pressing the *Detect Printers* button. This action generates a tree view, which helps in analyzing the device's parameters. The printer model field should automatically populate if detection is successful.

- Detect Access Keys:

  If the printer is not listed in the configuration or is not manageable, press *Detect Access Keys.* This process may take several minutes to complete.

  - If the message *"Could not detect read_key."* appears at the end, it means the printer cannot be controlled with the current software version (refer to "Known Incompatible Models" below).

  - If no errors are reported in the output, proceed by pressing *Detect Configuration.*

- Analyze Results:

  Each of these operations generates both a tree view and a text view. These outputs help determine if an existing configured model closely matches or is identical to the target printer. Use the right mouse button to switch between the two views for easier analysis.

- Important Notes:

  - These processes can take several minutes to complete. Ensure the printer remains powered on throughout the entire operation.
  - To avoid interruptions, consider temporarily disabling the printer's auto power-off timer.

### How to revert a change performed through the GUI

The GUI displays a `[NOTE]` in the status box before performing any change, specifying the current EEPROM values before the rewrite operation. This line can be copied and pasted as is into the text box that appears when the "Write EEPROM" button is pressed; the execution of the related action reverts the changes to their original values.

It is recommended to copy the status history and keep it in a safe place after making changes, so that a reverse operation can be performed when needed.

### Known incompatible models

Some recent firmwares supported by new printers disabled SNMP EEPROM management or changed the access mode (possibly for security reasons).

For the following models there is no known way to read the EEPROM via SNMP protocol using the adopted read/write key and the related algorithm:

- [XP-7100 with firmware version YL25O7 (25 Jul 2024)](https://github.com/Ircama/epson_print_conf/issues/42) (firmware YL11K6 works)
- Possibly [ET-7700](https://github.com/Ircama/epson_print_conf/issues/46)
- [ET-2800](https://github.com/Ircama/epson_print_conf/issues/27)
- [ET-2814](https://github.com/Ircama/epson_print_conf/issues/42#issuecomment-2571587444)
- [ET-2850, ET-2851, ET-2853, ET-2855, ET-2856](https://github.com/Ircama/epson_print_conf/issues/26)
- [ET-4800](https://github.com/Ircama/epson_print_conf/issues/29) with new firmware (older firmware might work)
- [L3250](https://github.com/Ircama/epson_print_conf/issues/35)
- [L18050](https://github.com/Ircama/epson_print_conf/issues/47)
- [EcoTank ET-2862 with firmware 05.18.XF12OB dated 12/11/2024](https://github.com/Ircama/epson_print_conf/discussions/58) and possibly ET-2860 / 2861 / 2863 / 2865 series.

For model XP-2200, check https://github.com/Ircama/epson_print_conf/issues/51

### Using the command-line tool

```
python epson_print_conf.py [-h] -m MODEL -a HOSTNAME [-p PORT] [-i] [-q QUERY_NAME] [--reset_waste_ink] [-d]
                           [--write-first-ti-received-time YEAR MONTH DAY] [--write-poweroff-timer MINUTES]
                           [--dry-run] [-R ADDRESS_SET] [-W ADDRESS_VALUE_SET] [-e FIRST_ADDRESS LAST_ADDRESS]
                           [--detect-key] [-S SEQUENCE_STRING] [-t TIMEOUT] [-r RETRIES] [-c CONFIG_FILE]
                           [--simdata SIMDATA_FILE] [-P PICKLE_FILE] [-O]

optional arguments:
  -h, --help            show this help message and exit
  -m MODEL, --model MODEL
                        Printer model. Example: -m XP-205 (use ? to print all supported models)
  -a HOSTNAME, --address HOSTNAME
                        Printer host name or IP address. (Example: -a 192.168.1.87)
  -p PORT, --port PORT  Printer port (default is 161)
  -i, --info            Print all available information and statistics (default option)
  -q QUERY_NAME, --query QUERY_NAME
                        Print specific information. (Use ? to list all available queries)
  --reset_waste_ink     Reset all waste ink levels to 0
  -d, --debug           Print debug information
  --write-first-ti-received-time YEAR MONTH DAY
                        Change the first TI received time
  --write-poweroff-timer MINUTES
                        Update the poweroff timer. Use 0xffff or 65535 to disable it.
  --dry-run             Dry-run change operations
  -R ADDRESS_SET, --read-eeprom ADDRESS_SET
                        Read the values of a list of printer EEPROM addreses. Format is: address [, ...]
  -W ADDRESS_VALUE_SET, --write-eeprom ADDRESS_VALUE_SET
                        Write related values to a list of printer EEPROM addresses. Format is: address: value [, ...]
  -e FIRST_ADDRESS LAST_ADDRESS, --eeprom-dump FIRST_ADDRESS LAST_ADDRESS
                        Dump EEPROM
  --detect-key          Detect the read_key via brute force
  -S SEQUENCE_STRING, --write-sequence-to-string SEQUENCE_STRING
                        Convert write sequence of numbers to string.
  -t TIMEOUT, --timeout TIMEOUT
                        SNMP GET timeout (floating point argument)
  -r RETRIES, --retries RETRIES
                        SNMP GET retries (floating point argument)
  -c CONFIG_FILE, --config CONFIG_FILE
                        read a configuration file including the full log dump of a previous operation with '-d' flag
                        (instead of accessing the printer via SNMP)
  --simdata SIMDATA_FILE
                        write SNMP dictionary map to simdata file
  -P PICKLE_FILE, --pickle PICKLE_FILE
                        Load a pickle configuration archive saved by parse_devices.py
  -O, --override        Replace the default configuration with the one in the pickle file instead of merging (default
                        is to merge)

Epson Printer Configuration via SNMP (TCP/IP)
```

Examples:

```bash
# Print the status information (-i is not needed):
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 -i

# Reset all waste ink levels to 0:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 --reset_waste_ink

# Change the first TI received time to 31 December 2016:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 --write-first-ti-received-time 2016 12 31

# Change the power off timer to 15 minutes:
python3 epson_print_conf.py -a 192.168.1.87 -m XP-205 --write-poweroff-timer 15

# Detect the read_key via brute force:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 --detect-key

# Only print status information:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 -q printer_status

# Only print SNMP 'MAC Address' name:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 -q 'MAC Address'

# Only print SNMP 'Lang 5' name:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 -q 'Lang 5'

# Write value 1 to the EEPROM address 173 and value 0xDE to the EEPROM address 172:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 -W 173:1,172:0xde

# Read EEPROM address 173 and EEPROM address 172:
python3 epson_print_conf.py -m XP-205 -a 192.168.1.87 -R 173,172
```

## Creating an executable asset for the GUI

Alternatively to running the GUI via `python ui.py`, it is possible to build an executable file via *pyinstaller*.

Install *pyinstaller* with `pip install pyinstaller`.

The *epson_print_conf.spec* file helps building the executable program. Run it with the following command.

```bash
pip install pyinstaller  # if not yet installed
pyinstaller epson_print_conf.spec -- --default
```

Then run the executable file created in the *dist/* folder, which has the same options of `ui.py`.

It is also possible to automatically load a previously created configuration file that has to be named *epson_print_conf.pickle*, merging it with the program configuration. (See below the *parse_devices.py* utility.) To build the executable program with this file, run the following command:

```bash
pip install pyinstaller  # if not yet installed
curl -o devices.xml https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d
python3 parse_devices.py -a 192.168.178.29 -s XP-205 -p epson_print_conf.pickle  # use your default IP address and printer model as default settings for the GUI
pyinstaller epson_print_conf.spec
```

Same procedure using the Reinkpy's *epson.toml* file (in place of *devices.xml*):

```bash
pip install pyinstaller  # if not yet installed
curl -o epson.toml https://codeberg.org/atufi/reinkpy/raw/branch/main/reinkpy/epson.toml
python3 parse_devices.py -Ta 192.168.178.29 -s XP-205 -p epson_print_conf.pickle  # use your default IP address and printer model as default settings for the GUI
pyinstaller epson_print_conf.spec
```

When embedding *epson_print_conf.pickle*, the created program does not have options and starts with the default IP address and printer model defined in the build phase.

As mentioned in the [documentation](https://pyinstaller.org/en/stable/), PyInstaller supports Windows, MacOS X, Linux and other UNIX Operating Systems. It creates an executable file which is only compatible with the operating system that is used to build the asset.

This repository includes a Windows *epson_print_conf.exe* executable file which is automatically generated by a [GitHub Action](.github/workflows/build.yml). It is packaged in a ZIP file named *epson_print_conf.zip* and uploaded into the [Releases](https://github.com/Ircama/epson_print_conf/releases/latest) folder.

## Utilities and notes

### parse_devices.py

Within a [report](https://codeberg.org/atufi/reinkpy/issues/12#issue-716809) in repo <https://codeberg.org/atufi/reinkpy> there is an interesting [attachment](https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d) which includes an extensive XML database of Epson model features.

The program *parse_devices.py* transforms this XML DB into the dictionary that *epson_print_conf.py* can use. It is also able to accept the [TOML](https://toml.io/) input format used by [reinkpy](https://codeberg.org/atufi/reinkpy) in [epson.toml](https://codeberg.org/atufi/reinkpy/src/branch/main/reinkpy/epson.toml), if the `-T` option is used.

Here is a simple procedure to download the *devices.xml* DB and run *parse_devices.py* to search for the XP-205 model and produce the related PRINTER_CONFIG dictionary to the standard output:

```bash
curl -o devices.xml https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d
python3 parse_devices.py -i -m XP-205
```

Same procedure, processing the *epson.toml* file:

```bash
curl -o epson.toml https://codeberg.org/atufi/reinkpy/raw/branch/main/reinkpy/epson.toml
python3 parse_devices.py -T -i -m XP-205
```

After generating the related printer configuration, *epson_print_conf.py* shall be manually edited to copy/paste the output of *parse_devices.py* within its PRINTER_CONFIG dictionary. Alternatively, the program is able to create a *pickle* configuration file (check the `-p` lowercase option), which the other programs can load (with the `-P` uppercase option and in addition with the optional `-O` flag).

The `-m` option is optional and is used to filter the printer model in scope. If the produced output is not referred to the target model, use part of the model name as a filter (e.g., only the digits, like `parse_devices.py -i -m 315`) and select the appropriate model from the output.

Program usage:

```
usage: parse_devices.py [-h] [-m PRINTER_MODEL] [-T] [-l LINE_LENGTH] [-i] [-d] [-t] [-v] [-f] [-e]
                        [-c CONFIG_FILE] [-s DEFAULT_MODEL] [-a HOSTNAME] [-p PICKLE_FILE] [-I] [-N]
                        [-A] [-G] [-S] [-M]

optional arguments:
  -h, --help            show this help message and exit
  -m PRINTER_MODEL, --model PRINTER_MODEL
                        Filter printer model. Example: -m XP-205
  -T, --toml            Use the Reinkpy TOML input format instead of XML
  -l LINE_LENGTH, --line LINE_LENGTH
                        Set line length of the output (default: 120)
  -i, --indent          Indent output of 4 spaces
  -d, --debug           Print debug information
  -t, --traverse        Traverse the XML, dumping content related to the printer model
  -v, --verbose         Print verbose information
  -f, --full            Generate additional tags
  -e, --errors          Add last_printer_fatal_errors
  -c CONFIG_FILE, --config CONFIG_FILE
                        use the XML or the Reinkpy TOML configuration file to generate the configuration;
                        default is 'devices.xml', or 'epson.toml' if -T is used
  -s DEFAULT_MODEL, --default_model DEFAULT_MODEL
                        Default printer model. Example: -s XP-205
  -a HOSTNAME, --address HOSTNAME
                        Default printer host name or IP address. (Example: -a 192.168.1.87)
  -p PICKLE_FILE, --pickle PICKLE_FILE
                        Save a pickle archive for subsequent load by ui.py and epson_print_conf.py
  -I, --keep_invalid    Do not remove printers without write_key or without read_key
  -N, --keep_names      Do not replace original names with converted names and add printers for all
                        optional names
  -A, --no_alias        Do not add aliases for same printer with different names and remove aliased
                        printers
  -G, --no_aggregate_alias
                        Do not aggregate aliases of printers with same configuration
  -S, --no_same_as      Do not add "same-as" for similar printers with different names
  -M, --no_maint_level  Do not add "Maintenance required levelas" in "stats"

Generate printer configuration from devices.xml or from Reinkpy TOML
```

The program does not provide *printer_head_id* and *Power off timer*.

#### Example to integrate new printers

Suppose ET-4800 ia a printer already defined in the mentioned [attachment](https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d) with valid data, that you want to integrate.

```bash
curl -o devices.xml https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d
python3 parse_devices.py -m ET-4800 -p epson_print_conf.pickle
python3 ui.py -P epson_print_conf.pickle
```

or (operating *epson.toml*):

```bash
curl -o epson.toml https://codeberg.org/atufi/reinkpy/raw/branch/main/reinkpy/epson.toml
python3 parse_devices.py -T -m ET-4800 -p epson_print_conf.pickle
python3 ui.py -P epson_print_conf.pickle
```

If you also want to create an executable program:

```bash
pyinstaller epson_print_conf.spec
```

### find_printers.py

*find_printers.py* can be executed via `python find_printers.py` and prints the list of the discovered printers to the standard output. It is internally used as a library by *ui.py*.

Output example:

```
[{'ip': '192.168.178.29', 'hostname': 'EPSONDEFD03.fritz.box', 'name': 'EPSON XP-205 207 Series'}]
```

### Other utilities

```python
from epson_print_conf import EpsonPrinter
import pprint
printer = EpsonPrinter()

# Decode write_key:
printer.reverse_caesar(bytes.fromhex("48 62 7B 62 6F 6A 62 2B"))  # last 8 bytes
'Gazania*'

printer.reverse_caesar(b'Hpttzqjv')
'Gossypiu'

"".join(chr(b + 1) for b in b'Gossypiu')
'Hpttzqjv'

# Decode status:
pprint.pprint(printer.status_parser(bytes.fromhex("40 42 44 43 20 53 54 32 0D 0A ....")))

# Decode the level of ink waste
byte_sequence = "A4 2A"
divider = 62.06  # divider = ink_level / waste_percent
ink_level = int("".join(reversed(byte_sequence.split())), 16)
waste_percent = round(ink_level / divider, 2)

# Print the read key sequence in byte and hex formats:
printer = EpsonPrinter(model="ET-2700")
'.'.join(str(x) for x in printer.parm['read_key'])
" ".join('{0:02x}'.format(x) for x in printer.parm['read_key'])

# Print the write key sequence in byte and hex formats:
printer = EpsonPrinter(model="ET-2700")
printer.caesar(printer.parm['write_key'])
printer.caesar(printer.parm['write_key'], hex=True).upper()

# Print hex sequence of reading the value of EEPROM address 30 00:
" ".join('{0:02x}'.format(int(x)) for x in printer.eeprom_oid_read_address(oid=0x30).split(".")[15:]).upper()

# Print hex sequence of storing value 00 to EEPROM address 30 00:
" ".join('{0:02x}'.format(int(x)) for x in printer.eeprom_oid_write_address(oid=0x30, value=0x0).split(".")[15:]).upper()

# Print EEPROM write hex sequence of the raw ink waste reset:
for key, value in printer.parm["raw_waste_reset"].items():
    " ".join('{0:02x}'.format(int(x)) for x in printer.eeprom_oid_write_address(oid=key, value=value).split(".")[15:]).upper()
```

Generic query of the status of the printer (regardless of the model):

```python
from epson_print_conf import EpsonPrinter
import pprint
printer = EpsonPrinter(hostname="192.168.1.87")
pprint.pprint(printer.status_parser(printer.snmp_mib("1.3.6.1.4.1.1248.1.2.2.1.1.1.4.1")[1]))
```

### Byte sequences

Header:

```
1.3.6.1.4.1. [SNMP_OID_ENTERPRISE]
1248. [SNMP_EPSON]

1.2.2.44.1.1.2. [OID_PRV_CTRL]
1.
```

Full header sequence: `1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1.`

Read EEPROM (EPSON-CTRL), after the header:

```
124.124.7.0. [7C 7C 07 00]
<READ KEY (two bytes)>
65.190.160. [41 BE A0]
<LSB EEPROM ADDRESS (one byte)>.<MSB EEPROM ADDRESS (one byte)>
```

Example: `1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1.124.124.7.0.73.8.65.190.160.48.0`

Write EEPROM, after the header:

```
7C 7C 10 00 [124.124.16.0.]
<READ KEY (two bytes)>
42 BD 21 [66.189.33.]
<LSB EEPROM ADDRESS (one byte)>.<MSB EEPROM ADDRESS (one byte)>
<VALUE (one byte)>
<WRITE KEY (eight bytes)>
```

Example: `7C 7C 10 00 49 08 42 BD 21 30 00 1A 42 73 62 6F 75 6A 67 70`

Example of Read EEPROM (@BDC PS):

```
<01> @BDC PS <0d0a> EE:0032AC;
EE: = EEPROM Read
0032 = Memory address
AC = Value
```

## API Interface

### Specification

```python
EpsonPrinter(conf_dict, replace_conf, model, hostname, port, timeout, retries, dry_run)
```

- `conf_dict`: optional configuration file in place of the default PRINTER_CONFIG (optional, default to `{}`)
- `replace_conf`: (optional, default to False) set to True to replace PRINTER_CONFIG with `conf_dict` instead of merging it
- `model`: printer model
- `hostname`: IP address or network name of the printer
- `port`: SNMP port number (default is 161)
- `timeout`: printer connection timeout in seconds (float)
- `retries`: connection retries if error or timeout occurred
- `dry_run`: boolean (True if write dry-run mode is enabled)

### Exceptions

```
TimeoutError
ValueError
```

(And *pysnmp* exceptions.)

### Sample

```python
from epson_print_conf import EpsonPrinter
import logging

logging.basicConfig(level=logging.DEBUG, format="%(message)s")  # if logging is needed

printer = EpsonPrinter(model="XP-205", hostname="192.168.178.29")

if not printer.parm:
    print("Unknown printer")
    quit()

stats = printer.stats()
print("stats:", stats)

ret = printer.get_snmp_info()
print("get_snmp_info:", ret)
ret = printer.get_serial_number()
print("get_serial_number:", ret)
ret = printer.get_firmware_version()
print("get_firmware_version:", ret)
ret = printer.get_printer_head_id()
print("get_printer_head_id:", ret)
ret = printer.get_cartridges()
print("get_cartridges:", ret)
ret = printer.get_printer_status()
print("get_printer_status:", ret)
ret = printer.get_ink_replacement_counters()
print("get_ink_replacement_counters:", ret)
ret = printer.get_waste_ink_levels()
print("get_waste_ink_levels:", ret)
ret = printer.get_last_printer_fatal_errors()
print("get_last_printer_fatal_errors:", ret)
ret = printer.get_stats()
print("get_stats:", ret)

printer.reset_waste_ink_levels()
printer.brute_force_read_key()
printer.write_first_ti_received_time(2000, 1, 2)

# Dump all printer configuration parameters
from pprint import pprint
pprint(printer.parm)
```

[black](https://pypi.org/project/black/) way to dump all printer parameters:

```python
import textwrap, black
from epson_print_conf import EpsonPrinter
printer = EpsonPrinter(model="TX730WD", hostname="192.168.178.29")
mode = black.Mode(line_length=200, magic_trailing_comma=False)
print(textwrap.indent(black.format_str(f'"{printer.model}": ' + repr(printer.parm), mode=mode), 8*' '))

# Print status:
print(black.format_str(f'"{printer.model}": ' + repr(printer.stats()), mode=mode))
```

## Output example
Example of advanced printer status with an XP-205 printer:

```python
{'cartridge_information': [{'data': '0D081F172A0D04004C',
                            'ink_color': [1811, 'Black'],
                            'ink_quantity': 76,
                            'production_month': 8,
                            'production_year': 2013},
                           {'data': '15031D06230D080093',
                            'ink_color': [1814, 'Yellow'],
                            'ink_quantity': 69,
                            'production_month': 3,
                            'production_year': 2021},
                           {'data': '150317111905020047',
                            'ink_color': [1813, 'Magenta'],
                            'ink_quantity': 49,
                            'production_month': 3,
                            'production_year': 2021},
                           {'data': '14091716080501001D',
                            'ink_color': [1812, 'Cyan'],
                            'ink_quantity': 29,
                            'production_month': 9,
                            'production_year': 2020}],
 'cartridges': ['18XL', '18XL', '18XL', '18XL'],
 'firmware_version': 'RF11I5 11 May 2018',
 'ink_replacement_counters': {('Black', '1B', 1),
                              ('Black', '1L', 19),
                              ('Black', '1S', 2),
                              ('Cyan', '1B', 1),
                              ('Cyan', '1L', 8),
                              ('Cyan', '1S', 1),
                              ('Magenta', '1B', 1),
                              ('Magenta', '1L', 6),
                              ('Magenta', '1S', 1),
                              ('Yellow', '1B', 1),
                              ('Yellow', '1L', 10),
                              ('Yellow', '1S', 1)},
 'last_printer_fatal_errors': ['08', 'F1', 'F1', 'F1', 'F1', '10'],
 'printer_head_id': '...',
 'printer_status': {'cancel_code': 'No request',
                    'ink_level': [(1, 0, 'Black', 'Black', 76),
                                  (5, 3, 'Yellow', 'Yellow', 69),
                                  (4, 2, 'Magenta', 'Magenta', 49),
                                  (3, 1, 'Cyan', 'Cyan', 29)],
                    'jobname': 'Not defined',
                    'loading_path': 'fixed',
                    'maintenance_box_1': 'not full (0)',
                    'maintenance_box_2': 'not full (0)',
                    'maintenance_box_reset_count_1': 0,
                    'maintenance_box_reset_count_2': 0,
                    'paper_path': 'Cut sheet (Rear)',
                    'ready': True,
                    'status': (4, 'Idle'),
                    'unknown': [('0x24', b'\x0f\x0f')]},
 'serial_number': '...',
 'snmp_info': {'Descr': 'EPSON Built-in 11b/g/n Print Server',
               'EEPS2 firmware version': 'EEPS2 Hard Ver.1.00 Firm Ver.0.50',
               'Emulation 1': 'unknown',
               'Emulation 2': 'ESC/P2',
               'Emulation 3': 'BDC',
               'Emulation 4': 'other',
               'Emulation 5': 'other',
               'Epson Model': 'XP-205 207 Series',
               'IP Address': '192.168.1.87',
               'IPP_URL': 'http://192.168.1.87:631/Epson_IPP_Printer',
               'IPP_URL_path': 'Epson_IPP_Printer',
               'Lang 1': 'unknown',
               'Lang 2': 'ESCPL2',
               'Lang 3': 'BDC',
               'Lang 4': 'D4',
               'Lang 5': 'ESCPR1',
               'MAC Addr': '...',
               'MAC Address': '...',
               'Model': 'EPSON XP-205 207 Series',
               'Model short': 'XP-205 207 Series',
               'Name': '...',
               'Power Off Timer': '0.5 hours',
               'Print input': 'Auto sheet feeder',
               'Total printed pages': '0',
               'UpTime': '00:02:08',
               'WiFi': '...',
               'device_id': 'MFG:EPSON;CMD:ESCPL2,BDC,D4,D4PX,ESCPR1;MDL:XP-205 '
                            '207 Series;CLS:PRINTER;DES:EPSON XP-205 207 '
                            'Series;CID:EpsonRGB;FID:FXN,DPN,WFA,ETN,AFN,DAN;RID:40;'},
 'stats': {'First TI received time': '...',
           'Ink replacement cleaning counter': 78,
           'Maintenance required level of 1st waste ink counter': 94,
           'Maintenance required level of 2nd waste ink counter': 94,
           'Manual cleaning counter': 129,
           'Timer cleaning counter': 4,
           'Total print page counter': 11569,
           'Total print pass counter': 514602,
           'Total scan counter': 4973,
           'Power off timer': 30},
 'waste_ink_levels': {'borderless_waste': 4.72, 'main_waste': 90.8}}
 ```

## Resources

### snmpget

Installation with Linux:

```
sudo apt-get install snmp
```

There are also [binaries for Windows](https://netcologne.dl.sourceforge.net/project/net-snmp/net-snmp%20binaries/5.7-binaries/net-snmp-5.7.0-1.x86.exe?viasf=1) which include snmpget.exe, running with the same arguments.

Usage:

```
# Read address 173.0
snmpget -v1 -d -c public 192.168.1.87 1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1.124.124.7.0.25.7.65.190.160.173.0

# Read address 172.0
snmpget -v1 -d -c public 192.168.1.87 1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1.124.124.7.0.25.7.65.190.160.172.0

# Write 25 to address 173.0
snmpget -v1 -d -c public 192.168.1.87 1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1.124.124.16.0.25.7.66.189.33.173.0.25.88.98.108.98.117.112.99.106

# Write 153 to address 172.0
snmpget -v1 -d -c public 192.168.1.87 1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1.124.124.16.0.25.7.66.189.33.172.0.153.88.98.108.98.117.112.99.106
```

### References

epson-printer-snmp: <https://github.com/Zedeldi/epson-printer-snmp> (and <https://github.com/Zedeldi/epson-printer-snmp/issues/1>)

ReInkPy: <https://codeberg.org/atufi/reinkpy/>

ReInk: <https://github.com/lion-simba/reink> (especially <https://github.com/lion-simba/reink/issues/1>)

reink-net: <https://github.com/gentu/reink-net>

epson-l4160-ink-waste-resetter: <https://github.com/nicootto/epson-l4160-ink-waste-resetter>

epson-l3160-ink-waste-resetter: <https://github.com/k3dt/epson-l3160-ink-waste-resetter>

emanage x900: <https://github.com/abrasive/x900-otsakupuhastajat/>

### Other programs

- Epson One-Time Maintenance Ink Pad Reset Utility: <https://epson.com/Support/wa00369>
  - Epson Maintenance Reset Utility: <https://epson.com/epsonstorefront/orbeon/fr/us_regular_s03/us_ServiceInk_Pad_Reset/new>
  - Epson Ink Pads Reset Utility Terms and Conditions: <https://epson.com/Support/wa00370>
- Epson Adjustment Program (developed by EPSON)
- WIC-Reset: <https://www.wic.support/download/> / <https://www.2manuals.com/> (Use at your risk)
- PrintHelp: <https://printhelp.info/> (Use at your risk)

### Other resources

- <https://codeberg.org/attachments/147f41a3-a6ea-45f6-8c2a-25bac4495a1d>
- <https://codeberg.org/atufi/reinkpy/src/branch/main/reinkpy/epson.toml>
