@echo off
setlocal enabledelayedexpansion

:: Set paths
set CLIENT_INFO_FILE=client_info.json
set TEMPLATES_DIR=templates
set PYTHON_SCRIPT=send_html_email.py
set JQ_PATH=%~dp0jq.exe
set JQ_DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
cls
echo.
echo Welcome to the Mailer!
echo Starting Mailer...
echo 
:: Function to check for jq
:CHECK_JQ
echo Checking for jq...
where jq >nul 2>&1
if %errorlevel% neq 0 (
    if not exist %JQ_PATH% (
        echo jq not found. Downloading jq...
        powershell -Command "Invoke-WebRequest -Uri %JQ_DOWNLOAD_URL% -OutFile jq.exe"
        if exist jq.exe (
            echo jq successfully downloaded.
        ) else (
            echo Error: Failed to download jq. Exiting.
            exit /b 1
        )
    ) else (
        echo jq found locally.
    )
) else (
    echo jq is already installed.
)
goto :NEXT
:NEXT
echo Checking for client_info.json...
:: Check if client_info.json exists
if not exist %CLIENT_INFO_FILE% (
    echo Error: %CLIENT_INFO_FILE% not found!
    exit /b 1
)
echo Checking for templates directory...
:: Check if templates directory exists
if not exist %TEMPLATES_DIR% (
    echo Error: %TEMPLATES_DIR% directory not found!
    exit /b 1
)
echo.
echo You will now be prompted to select a client email and a template.
echo.
:: Parse client emails from the JSON file using jq
echo Select a client email:
for /f "tokens=*" %%A in ('jq -r ".clients[] | .email" %CLIENT_INFO_FILE%') do (
    set /a count+=1
    set client_email[!count!]=%%A
    echo !count!: %%A
)

:: Prompt user to select client email
set /p email_choice="Enter the number corresponding to the client email: "
set selected_email=!client_email[%email_choice%]!
if not defined selected_email (
    echo Invalid selection. Exiting.
    exit /b 1
)

:: List available templates in the templates directory
echo Select an email template:
setlocal enabledelayedexpansion
set count=0
for /f "tokens=*" %%A in ('dir /b %TEMPLATES_DIR%') do (
    set /a count+=1
    set template[!count!]=%%A
    echo !count!: %%A
)

:: Prompt user to select template
set /p template_choice="Enter the number corresponding to the template: "
set selected_template=!template[%template_choice%]!
if not defined selected_template (
    echo Invalid selection. Exiting.
    exit /b 1
)

:: Prompt user for subject
set /p subject="Enter the email subject: "

:: Run the Python script
echo Sending email...
python %PYTHON_SCRIPT% %selected_email% "%subject%" "%TEMPLATES_DIR%\%selected_template%"

:: Capture and display Python script’s response
if %errorlevel%==0 (
    echo Email successfully sent to %selected_email% using template %selected_template%.
) else (
    echo Failed to send email.
)
pause
