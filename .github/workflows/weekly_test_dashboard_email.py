#! /usr/bin/env python3
#
# Send the weekly dashboard through the SMTP configuration supplied by Actions.
#
## NOTE: Initial dashboard email delivery facilitated by GitHub Copilot (GPT-5.6 Terra).

"""Send the weekly test dashboard email through SMTP STARTTLS."""

# Standard modules
import argparse
import os
import smtplib
import ssl
from email.message import EmailMessage
from email.utils import formatdate, make_msgid
from pathlib import Path


REQUIRED_ENVIRONMENT = (
    "SMTP_HOST",
    "SMTP_PORT",
    "SMTP_USERNAME",
    "SMTP_PASSWORD",
    "SMTP_FROM",
    "SMTP_TO",
)


def get_smtp_settings():
    """Return SMTP settings or exit with the missing variable names."""
    missing = [name for name in REQUIRED_ENVIRONMENT if not os.environ.get(name)]
    if missing:
        raise SystemExit(
            f"Missing required email configuration: {', '.join(missing)}")
    return {name: os.environ[name] for name in REQUIRED_ENVIRONMENT}


def build_message(settings, body):
    """Return the dashboard EmailMessage built from SETTINGS and BODY."""
    message = EmailMessage()
    message["Subject"] = "Weekly shell-scripts test dashboard"
    message["From"] = settings["SMTP_FROM"]
    message["To"] = settings["SMTP_TO"]
    message["Date"] = formatdate(localtime=False)
    message["Message-ID"] = make_msgid()
    message.set_content(body)
    return message


def send_message(settings, message):
    """Submit MESSAGE through the configured SMTP server and return refusals."""
    recipients = [address.strip() for address in settings["SMTP_TO"].split(",")
                  if address.strip()]
    if not recipients:
        raise ValueError("SMTP_TO must contain at least one recipient")
    with smtplib.SMTP(
            settings["SMTP_HOST"], int(settings["SMTP_PORT"]), timeout=30) as smtp:
        smtp.ehlo()
        smtp.starttls(context=ssl.create_default_context())
        smtp.ehlo()
        smtp.login(settings["SMTP_USERNAME"], settings["SMTP_PASSWORD"])
        return smtp.send_message(
            message, from_addr=settings["SMTP_FROM"], to_addrs=recipients)


def main():
    """Read the dashboard body and submit the configured weekly email."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--body-file", type=Path, required=True,
        help="Markdown or text file to use as the email body")
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Validate configuration and render the message without sending it")
    args = parser.parse_args()
    settings = get_smtp_settings()
    message = build_message(settings, args.body_file.read_text(encoding="utf-8"))
    if args.dry_run:
        print(
            "SMTP email validated for "
            f"{len([entry for entry in settings['SMTP_TO'].split(',') if entry.strip()])} "
            f"recipient(s); message-id={message['Message-ID']}")
        return

    refused = send_message(settings, message)
    if refused:
        raise RuntimeError(f"SMTP refused recipient(s): {sorted(refused)}")
    print(
        "SMTP submission accepted for "
        f"{len([entry for entry in settings['SMTP_TO'].split(',') if entry.strip()])} "
        f"recipient(s); message-id={message['Message-ID']}")


if __name__ == "__main__":
    main()
