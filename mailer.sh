#!/bin/bash

CLIENT_INFO_FILE="client_info.json"
TEMPLATES_DIR="templates"
PYTHON_SCRIPT="send_html_email.py"

# Function to check for jq
check_jq() {
  if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing jq..."
    
    # Check the OS and install jq using the appropriate package manager
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y jq
      elif command -v yum &> /dev/null; then
        sudo yum install -y jq
      elif command -v dnf &> /dev/null; then
        sudo dnf install -y jq
      else
        echo "Error: Unsupported package manager on Linux. Please install jq manually."
        exit 1
      fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      if command -v brew &> /dev/null; then
        brew install jq
      else
        echo "Error: Homebrew not found. Please install Homebrew or jq manually."
        exit 1
      fi
    else
      echo "Error: Unsupported OS. Please install jq manually."
      exit 1
    fi
  else
    echo "jq is already installed."
  fi
}
clear
echo "Welcome to the Gorombo Client Email Sender!"
echo "-----------------------------------------"
printf "\n"
printf "Checking for jq..."
printf "\n"
# Check if jq is installed
check_jq
printf "\n"
printf "Checking for client_info.json..."
printf "\n"
# Check if client_info.json exists
if [[ ! -f "$CLIENT_INFO_FILE" ]]; then
  echo "Error: $CLIENT_INFO_FILE not found!"
  exit 1
fi
printf "\n"
printf "Checking for templates directory..."
printf "\n"
# Check if templates directory exists
if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: $TEMPLATES_DIR directory not found!"
  exit 1
fi
printf "\n"
printf "Checking for send_html_email.py..."
printf "\n"
# Check if send_html_email.py exists
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
  echo "Error: $PYTHON_SCRIPT not found!"
  exit 1
fi
printf "\n"
printf "All dependencies are satisfied. Proceeding with the script..."
printf "\n"
printf "-----------------------------------------"
printf "\n"
printf "You will now be prompted to select a client email and a template."
printf "\n"
printf "-----------------------------------------"
printf "\n"
# Parse client emails from the JSON file using jq
echo "Select a client email:"
printf "\n"
mapfile -t client_emails < <(jq -r '.clients[] | .email' "$CLIENT_INFO_FILE")

for i in "${!client_emails[@]}"; do
  echo "$((i+1)): ${client_emails[i]}"
done

# Prompt user to select client email
read -p "Enter the number corresponding to the client email: " email_choice
selected_email="${client_emails[$((email_choice-1))]}"

if [[ -z "$selected_email" ]]; then
  echo "Invalid selection. Exiting."
  exit 1
fi

# List available templates in the templates directory
echo "Select an email template:"
mapfile -t templates < <(ls -1 "$TEMPLATES_DIR")

for i in "${!templates[@]}"; do
  echo "$((i+1)): ${templates[i]}"
done

# Prompt user to select a template
read -p "Enter the number corresponding to the template: " template_choice
selected_template="${templates[$((template_choice-1))]}"

if [[ -z "$selected_template" ]]; then
  echo "Invalid selection. Exiting."
  exit 1
fi

# Prompt user for subject
read -p "Enter the email subject: " subject

# Run the Python script
echo "Sending email..."
python3 "$PYTHON_SCRIPT" "$selected_email" "$subject" "$TEMPLATES_DIR/$selected_template"

# Capture and display Python script’s response
if [[ $? -eq 0 ]]; then
  echo "Email successfully sent to $selected_email using template $selected_template."
else
  echo "Failed to send email."
fi
