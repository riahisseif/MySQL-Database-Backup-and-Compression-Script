# MySQL-Database-Backup-and-Compression-Script

This script backs up a MySQL database, excludes specified tables, and compresses the dump into a RAR file.

## Features

- Connects to MySQL using environment variables for credentials.
- Lists available databases and allows the user to choose one.
- Excludes specific tables from the backup.
- Saves the SQL dump to a user-specified location.
- Compresses the SQL dump into a RAR file.
- Deletes the original SQL dump after compression.

## Requirements

- MySQL installed on your system.
- WinRAR installed for compression.

## Usage

1. Set your MySQL credentials in environment variables (`DB_USERNAME` and `DB_PASSWORD`).
2. Run the script.
3. Choose the database to back up.
4. Specify the output filename and folder.
5. The backup will be compressed into a RAR file.

## Notes

- Tables to be excluded from the dump are predefined in the script.
- Ensure the path to WinRAR (`rar.exe`) is correct in the script.

## License

This script is open source. Feel free to modify and use it as needed.
