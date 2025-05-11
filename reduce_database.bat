@echo off
:: Configure encoding to correctly display accented characters
chcp 65001 > nul

:: Display a greeting message
echo ================================================
echo      Welcome to the MySQL dump script     
echo ================================================
echo.

:: Use global environment variable for username
set USERNAME=%DB_USERNAME%
set PASSWORD=%DB_PASSWORD%

:: Verifying credentials
echo Testing MySQL connection...
mysql -u %USERNAME% -p%PASSWORD% -e "SELECT VERSION();" > nul 2> error_log.txt
if errorlevel 1 (
    echo Error: Unable to connect to MySQL. Please check your credentials in the environment variables.
    type error_log.txt
    del error_log.txt
    exit /b
)
del error_log.txt
echo Connection successful!
echo.

:: List available databases
echo List of available databases:
echo --------------------------------------------
mysql -u %USERNAME% -p%PASSWORD% -e "SHOW DATABASES;" | findstr /v "information_schema" | findstr /v "mysql" | findstr /v "performance_schema" > temp_databases.txt

:: Display the databases with numbering
setlocal enabledelayedexpansion
set count=0
for /f "skip=1 tokens=*" %%a in (temp_databases.txt) do (
    set /a count+=1
    echo !count!. %%a
)

:: Loop for a valid choice
:choose_database
echo.
set /p CHOICE=Choose a database (by number): 

set DATABASE=
set /a index=0
for /f "skip=1 tokens=*" %%a in (temp_databases.txt) do (
    set /a index+=1
    if !index! == %CHOICE% set DATABASE=%%a
)

if "%DATABASE%"=="" (
    echo Invalid choice. Please try again!
    goto choose_database
)

:: Display the chosen database
echo You have chosen the database: %DATABASE%
echo.

if exist temp_databases.txt del temp_databases.txt

:: Ask for output filename
set /p OUTPUT_FILENAME=Enter the output filename (without extension): 

:: Specify the storage folder
set OUTPUT_DIR=C:\Users\algeb\OneDrive\Desktop\DB_TO_SEND

:: List tables to ignore
set IGNORE_TABLES=--ignore-table=%DATABASE%.prefile_holderbyoperationtypehistory_ ^ 
--ignore-table=%DATABASE%.prefile_prefile_commisionbyoperationtypehistory_ ^ 
--ignore-table=%DATABASE%.prefile_prefile_documentbyprefilehistory_ ^ 
--ignore-table=%DATABASE%.prefile_prefile_operationtypebyprefilehistory_ ^ 
--ignore-table=%DATABASE%.prefile_prefile_otherpaiementsbyoperationtypehistory_ ^ 
--ignore-table=%DATABASE%.prefile_propertybyoperationtypehistory_ ^ 
--ignore-table=%DATABASE%.tools_requestmonotoring_ ^ 
--ignore-table=%DATABASE%.prefile_prefile_prefilehistory_

:: Perform the SQL dump
echo Backing up database %DATABASE%...
mysqldump -u %USERNAME% -p %DATABASE% %IGNORE_TABLES% > "%OUTPUT_DIR%\%OUTPUT_FILENAME%.sql"
if errorlevel 1 (
    echo Error: Database backup failed.
    exit /b
)

:: Calculate and display the size of the generated SQL file
for %%f in ("%OUTPUT_DIR%\%OUTPUT_FILENAME%.sql") do set FILESIZE_SQL=%%~zf
echo Generated SQL file: %OUTPUT_DIR%\%OUTPUT_FILENAME%.sql
echo SQL file size (bytes): %FILESIZE_SQL% 
echo.

:: Compress into RAR
echo Compressing file into RAR...
"C:\Program Files\WinRAR\rar.exe" a -ep1 -inul "%OUTPUT_DIR%\%OUTPUT_FILENAME%.rar" "%OUTPUT_DIR%\%OUTPUT_FILENAME%.sql"
if errorlevel 1 (
    echo Error: RAR compression failed.
    exit /b
)

:: Delete the SQL file
del "%OUTPUT_DIR%\%OUTPUT_FILENAME%.sql"

:: Calculate and display the size of the generated RAR file
REM for %%f in ("%OUTPUT_DIR%\%OUTPUT_FILENAME%.rar") do set FILESIZE_RAR=%%~zf
REM echo Generated RAR file: %OUTPUT_DIR%\%OUTPUT_FILENAME%.rar
REM echo RAR file size (bytes): %FILESIZE_RAR% 
REM echo.

:cleanup
if exist error_log.txt del error_log.txt

:: Final result
echo ================================================
echo The RAR file has been created here:
echo %OUTPUT_DIR%\%OUTPUT_FILENAME%.rar
echo  %FILESIZE_SQL% bytes ---> %FILESIZE_RAR% bytes
echo ================================================
pause
