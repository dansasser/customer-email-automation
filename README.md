
![cea-py](https://github.com/user-attachments/assets/9c1057e5-6e82-4fb7-9363-a3b2b8ca365a)

# Customer Email Automation
<hr>


This project includes three scripts designed to facilitate sending HTML emails with dynamic content:

1. **`send_html_email.py`**: This is the core Python script that reads an HTML template file, replaces placeholders with client-specific information, and sends the email via SMTP using your email credentials. It also converts sensitive data, such as passwords, into secure images.

2. **`mailer.bat`**: A Batch script for Windows that simplifies the email-sending process by prompting you to select a client email address and an HTML template. It then calls `send_html_email.py` to send the email.

3. **`mailer.sh`**: A Bash script for Unix-like systems that performs similar tasks as `mailer.bat`. It prompts you to choose a client email address and template, then executes `send_html_email.py` to handle the email sending.

This repo was designed to help automate the process of sending personalized HTML emails, making it easier to integrate this functionality into your automated systems such as web hosting and network administration. The project is open-source and can be extended for further customization.

## Requirements

Before using the script, make sure you have the following:

- **Python 3.12.x** (or any compatible version)
- **Required Packages**:
  - `smtplib` (built-in to Python)
  - `email` (built-in to Python)
  - `python-dotenv` for loading environment variables
  - `Pillow` for image processing

Before running the script, ensure that all required Python packages are installed. The `requirements.txt` file provided includes all necessary dependencies. 

To install the required packages, use the following command:

```bash
pip install -r requirements.txt
```

Alternatively, if you prefer installing packages manually, you can use:

```bash
pip install python-dotenv pillow
```
## Setup

### Step 1: Create the `.env` File

Create a `.env` file in the root of your project directory and add your email credentials and other settings:

```
SMTP_SERVER=smtp.yourserver.com
SMTP_PORT=587
EMAIL_USERNAME=your_email@gorombo.com
EMAIL_PASSWORD=your_email_password
CLIENT_INFO_FILE=client_info.json
```

### Step 2: Prepare the Client Info File

A sample `client_info.json` file is included with client details replace these details with your clients information. You can add as namy as you like just add them as an object in the array:

```json
{
  "clients": [
    {
      "email": "client@gorombo.com",
      "name": "Client Name",
      "userName": "clientuser",
      "host": "smtp.yourserver.com",
      "domain": "gorombo.com",
      "password": "temporarypassword"
    }
  ]
}
```

### Step 3: Save Your HTML Template

Place your HTML template files in a directory called `template` (or another directory of your choice but you will have to edit this location in the .sh and .bat files).

For example, save an HTML file called `welcome_email.html` in the `template/` directory.

### Step 4: Running the Script

Use the following command to run the script from the command line:

```bash
python send_html_email.py recipient@gorombo.com "Email Subject" template/welcome_email.html
```

- `recipient@gorombo.com`: The recipient's email address.
- `"Email Subject"`: The subject of your email.
- `template/welcome_email.html`: The path to your HTML template file.

### Example

```bash
python send_html_email.py user@gorombo.com "Welcome to Our Platform" template/welcome_email.html
```

This will send an email to `user@gorombo.com` with the subject "Welcome to Our Platform," using the HTML content from `welcome_email.html`.

### Error Handling

If the script encounters any issues (e.g., failure to connect to the SMTP server), it will print an error message.

**Success Output:**

```plaintext
Email successfully sent to user@gorombo.com
```

**Failure Output:**

```plaintext
Failed to send email to user@gorombo.com
```

## Project Structure

```
.
├── .env
├── client_info.json
├── README.md
├── send_html_email.py
├── mailer.bat
├── mailer.sh
└── template/
    └── welcome_email.html
```

## Script Details

### Password Image Generation

The script generates an image of the password using the Pillow library. Adjust the position and size of the text in the `generate_password_image` function.

### Template Placeholders

The script replaces the following placeholders in the HTML template:

- `{{name}}`: Client's name
- `{{userName}}`: Client's username
- `{{host}}`: Host information
- `{{domain}}`: Domain information
- `{{temporaryPassword}}`: The password image

## Batch Script for Windows

The Windows batch script `mailer.bat` simplifies the process of selecting a client and template from a list and sending the email.

### Prerequisites

1. Ensure you have Python installed.
2. Install `jq` if it is not already installed. The batch script will handle this.
3. Install `Pillow` if it is not already installed. The batch script will handle this.
### Running the Batch Script

1. Double-click `mailer.bat` or run it from the Command Prompt.

2. Follow the prompts:

   - **Select a client email:**
     ```
     Select a client email:
     1: user1@gorombo.com
     2: user2@gorombo.com
     Enter the number corresponding to the client email: 
     ```

   - **Select an email template:**
     ```
     Select an email template:
     1: welcome_email.html
     2: password_reset.html
     Enter the number corresponding to the template: 
     ```

   - **Enter the email subject:**
     ```
     Enter the email subject: Welcome!
     ```

**Success Output:**

```plaintext
Email successfully sent to user1@gorombo.com
```

**Failure Output:**

```plaintext
Failed to send email to user1@gorombo.com
```

## Shell Script for Unix-like Systems

The Unix-like shell script `send_email.sh` is used to perform similar operations as the batch script but on Linux or macOS systems.

### Prerequisites

1. Ensure you have Python installed.
2. Install `jq`. The script will check and install `jq` if it is not present.

### Running the Shell Script

1. Make the script executable:

   ```bash
   chmod +x send_email.sh
   ```

2. Run the script:

   ```bash
   ./send_email.sh
   ```

3. Follow the prompts:

   - **Select a client email:**
     ```
     Select a client email:
     1: user1@gorombo.com
     2: user2@gorombo.com
     Enter the number corresponding to the client email: 
     ```

   - **Select an email template:**
     ```
     Select an email template:
     1: welcome_email.html
     2: password_reset.html
     Enter the number corresponding to the template: 
     ```

   - **Enter the email subject:**
     ```
     Enter the email subject: Welcome!
     ```

**Success Output:**

```plaintext
Email successfully sent to user1@gorombo.com
```

**Failure Output:**

```plaintext
Failed to send email to user1@gorombo.com
```

## Contribution

This is an open-source project designed to integrate into your existing automated systems such as web hosting and network administration. It provides a basic framework that can be extended for further customization.

We welcome contributions to enhance this script. If you have ideas, improvements, or bug fixes, please consider submitting a pull request or opening an issue on GitHub. Your input will help make this a more robust and versatile tool.

## License

This project is licensed under the MIT License.

For more insights on web development tools, asset management, and the Astro SSR SPA Template, visit [Dan Sasser’s Blog](https://dansasser.me) and explore [The Astro SSR SPA Template](https://astro-ssr-spa.org).

## **Resources**

- [dev.to](https://dev.to/dansasser/) - a link to my dev.to profile
- [LinkedIn](https://www.linkedin.com/in/dansasser/) - a link to my LinkedIn profile
- [GitHub](https://github.com/dansasser) - a link to my GitHub profile
- [Medium](https://medium.com/@dansasser) - a link to my current Medium profile

## Support My Work

If you enjoy my projects and want to support my work, consider buying me a coffee!

<a href="https://www.buymeacoffee.com/dansasser" target="_blank">
    <img src="https://img.buymeacoffee.com/button-api/?text=Buy%20Me%20a%20Coffee&emoji=&slug=dansasser&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" alt="Buy Me a Coffee" />
</a>

