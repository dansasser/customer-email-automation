import os
import json
import base64
from dotenv import load_dotenv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from smtplib import SMTP
from PIL import Image, ImageDraw, ImageFont
import io
import sys
from email.utils import formataddr
import re
import html

# Load environment variables
load_dotenv()

SMTP_SERVER = os.getenv('SMTP_SERVER')
SMTP_PORT = int(os.getenv('SMTP_PORT'))  # Ensure port is an integer
USERNAME = os.getenv('EMAIL_USERNAME')
PASSWORD = os.getenv('EMAIL_PASSWORD')
CLIENT_INFO_FILE = os.getenv('CLIENT_INFO_FILE', 'client_info.json')
cc_address = 'contact@yourdomain.com'  # Your CC email address

# Function to format email addresses with display names
def address_formatter(name, email):
    """Formats an email address with a display name."""
    return formataddr((name, email))

# Function to convert password into an image
def generate_password_image(password):
    # Create a blank image with white background
    img_width = 400
    img_height = 100
    background_color = (255, 255, 255)  # White
    text_color = (0, 0, 0)  # Black

    img = Image.new('RGB', (img_width, img_height), color=background_color)
    draw = ImageDraw.Draw(img)

    # Define font size and path to a TrueType font file
    font_size = 24
    font_path = "arial.ttf"  # You can specify a path to a .ttf file
    try:
        font = ImageFont.truetype(font_path, font_size)
    except IOError:
        font = ImageFont.load_default()

    # Calculate text size and position
    bbox = draw.textbbox((0, 0), password, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_x = (img_width - text_width) // 2
    text_y = (img_height - text_height) // 2

    # Adjust text positioning and spacing
    letter_spacing = 5
    x = text_x
    for char in password:
        draw.text((x, text_y), char, font=font, fill=text_color)
        x += draw.textbbox((0, 0), char, font=font)[2] - draw.textbbox((0, 0), char, font=font)[0] + letter_spacing

    buffer = io.BytesIO()
    img.save(buffer, format="PNG")
    buffer.seek(0)
    return buffer.read()

# Function to embed the password image as base64 in HTML
def embed_password_image_as_base64(password):
    image_data = generate_password_image(password)
    encoded_image = base64.b64encode(image_data).decode('utf-8')
    return (
        f'<img src="data:image/png;base64,{encoded_image}" '
        'alt="Password Image" style="display: block; width: 100%; max-width: 400px;" '
        'width="400" height="100" />'
    )

# Function to convert HTML content to plain text
def html_to_plain_text(html_content):
    # Add newlines after specific tags (paragraphs, headers, divs, breaks)
    html_content = re.sub(r'(</p>|</h1>|</h2>|</div>|<br\s*/?>)', '\n', html_content)

    # Remove remaining HTML tags
    plain_text = re.sub(r'<[^>]+>', '', html_content)

    # Decode HTML entities (e.g., &nbsp;, &amp;, etc.)
    plain_text = html.unescape(plain_text)

    # Clean up extra spaces/newlines
    plain_text = plain_text.strip()

    # Ensure no extra newlines (e.g., multiple newlines in a row)
    plain_text = re.sub(r'\n\s*\n', '\n\n', plain_text)  # Keep double newlines for paragraphs

    return plain_text

# Function to send email with both HTML and plain-text content
def send_email_with_dynamic_content(to_address, subject, html_file_path, client_info):
    try:
        # Read the HTML file content
        with open(html_file_path, 'r') as html_file:
            html_content = html_file.read()

        # Replace placeholders with actual data
        html_content = html_content.replace('{{name}}', client_info.get('name', ''))
        html_content = html_content.replace('{{userName}}', client_info.get('userName', ''))
        html_content = html_content.replace('{{host}}', client_info.get('host', ''))
        html_content = html_content.replace('{{domain}}', client_info.get('domain', ''))
        html_content = html_content.replace('{{subDomain}}', client_info.get('subDomain', ''))
        html_content = html_content.replace('{{temporaryPassword}}', client_info.get('password', ''))

        # Replace password placeholder with the generated image
        # password_image_html = embed_password_image_as_base64(client_info.get('password', ''))
        # html_content = html_content.replace('{{temporaryPassword}}', password_image_html)

        # Create plain-text content from the HTML content
        plain_text_content = html_to_plain_text(html_content)

        # Create the MIME message
        msg = MIMEMultipart('alternative')

        # Set sender and recipient details
        sender_name = "Gorombo Support"
        sender_email = USERNAME
        recipient_name = client_info.get('name', 'Recipient')
        recipient_email = to_address

        msg['From'] = address_formatter(sender_name, sender_email)
        msg['To'] = address_formatter(recipient_name, recipient_email)
        msg['Cc'] = address_formatter("Support CC", cc_address)  # CC address if needed
        msg['Subject'] = subject

        # Attach both plain text and HTML content to the message
        msg.attach(MIMEText(plain_text_content, 'plain'))
        msg.attach(MIMEText(html_content, 'html'))

        # Send the email via SMTP
        with SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(USERNAME, PASSWORD)
            server.sendmail(sender_email, [to_address, cc_address], msg.as_string())

        return True
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False

# Function to load client information from a JSON file
def load_client_info(file_path):
    try:
        with open(file_path, 'r') as file:
            data = json.load(file)
        return data['clients']
    except Exception as e:
        print(f"Failed to load client info: {e}")
        sys.exit(1)

# Main function to handle command-line arguments
def main():
    if len(sys.argv) != 4:
        print("Usage: python send_html_email.py <email> <subject> <html_file_path>")
        sys.exit(1)

    to_address = sys.argv[1]
    subject = sys.argv[2]
    html_file_path = sys.argv[3]

    # Load client info and find the corresponding client details
    clients = load_client_info(CLIENT_INFO_FILE)
    client_info = next((client for client in clients if client['email'] == to_address), None)

    if client_info is None:
        print(f"No client found with email {to_address}")
        sys.exit(1)

    # Send email with the dynamic content
    success = send_email_with_dynamic_content(to_address, subject, html_file_path, client_info)

    if success:
        print(f"Email successfully sent to {to_address}")
    else:
        print(f"Failed to send email to {to_address}")

if __name__ == "__main__":
    main()
