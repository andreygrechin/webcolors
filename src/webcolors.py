"""Simple webapp."""
import argparse
import logging
import os
import random
import socket
import sys

from flask import Flask, render_template, request

logging.basicConfig(
    format="%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s",
    level=logging.INFO,
    handlers=[
        logging.FileHandler(filename="logs/webcolors.log"),
        logging.StreamHandler(),
    ],
)
os.getcwd()
app = Flask(__name__)

COLORS: dict[str, str] = {
    "red": "DarkRed",
    "blue": "DodgerBlue",
    "gold": "Gold",
    "green": "ForestGreen",
    "pink": "HotPink",
    "grey": "DarkGrey",
}

DEFAULT_COLOR_NAME: str = "grey"
SUPPORTED_COLORS: str = ", ".join(COLORS.keys())


@app.route(
    "/",
    methods=[
        "GET",
    ],
)
def main():
    """Render a template.

    Returns
    -------
    str
        Rendered HTML page
    """
    params: dict[str, str] = {
        "Version tag": os.environ.get("VERSION_TAG", default="N/A"),
        "Background color": f"{COLOR_NAME} ({COLORS[COLOR_NAME]})",
        "GitHub Actions is running the workflow": os.environ.get("GITHUB_ACTIONS", default="false"),
        "Commit number": os.environ.get("GITHUB_SHA", default="N/A"),
        "Short commit number": os.environ.get("GITHUB_SHA", default="N/A")[:7],
        "Tag ref that triggered the workflow": os.environ.get("GITHUB_REF", default="N/A"),
        "Created on OS": os.environ.get("RUNNER_OS", default="N/A"),
        "Created on arch": os.environ.get("RUNNER_ARCH", default="N/A"),
        "Server hostname": socket.gethostname(),
        "Server socket": request.server,
        "Client IP address": request.remote_addr,
        "Client User-Agent": request.user_agent.string,
    }

    return render_template("hello.html.j2", bgcolor=COLORS[COLOR_NAME], params=params)


def print_help():
    """Print a help message."""
    app.logger.info(  # pylint:disable=no-member
        f"""
        This is a sample dockerized web application that displays one page
        with a colored background. A color can be specified in a few ways,
        in order of priority:

            1. As a command line argument `--color`.
            2. As an environment variable `COLOR`.
            3. If none of the above then the gray color will be used.

        Supported colors: {SUPPORTED_COLORS}
        Also you may choose a `random` as an option.

        To open the page from docker container, use `open http://localhost:8080/`.

        """
    )


if __name__ == "__main__":
    print_help()
    parser = argparse.ArgumentParser()
    parser.add_argument("--color", required=False)
    args = parser.parse_args()

    if args.color:
        app.logger.info(f"Getting a color from command line arguments = {args.color}")
        COLOR_NAME = args.color
    else:
        app.logger.info(
            "Getting a color from env var. "
            f"Default color ({DEFAULT_COLOR_NAME}) will be used, if not defined."
        )
        COLOR_NAME = os.environ.get("COLOR", default=DEFAULT_COLOR_NAME)

    if COLOR_NAME == "random":
        app.logger.info("A random color was selected.")
        COLOR_NAME = random.choice(list(COLORS))  # nosec

    if COLOR_NAME not in COLORS:
        app.logger.info(f"An unsupported color was used, supported colors: {SUPPORTED_COLORS}")
        sys.exit(1)

    app.logger.info(f"Finally, {COLOR_NAME} color will be used.\n")

    # Run Flask
    app.run(host="0.0.0.0", port=8080)  # nosec
