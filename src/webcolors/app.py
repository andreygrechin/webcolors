"""A simple Flask app."""

import argparse
import logging
import os
import random
import socket
import sys
import typing as t
from dataclasses import dataclass
from typing import ClassVar

from flask import Flask, make_response, render_template, request
from flask.wrappers import Response
from jinja2 import select_autoescape

import webcolors
from webcolors._help import print_help

logging.basicConfig(
    format="%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s",
    level=logging.INFO,
    handlers=[
        logging.StreamHandler(),
    ],
)

HOST: str = os.getenv("WEBCOLORS_HOST", "localhost")
PORT: int = int(os.getenv("WEBCOLORS_PORT", "8080"))


@dataclass
class Colors:
    """Class to store color data."""

    names: ClassVar[dict[str, str]] = {
        "red": "DarkRed",
        "blue": "DodgerBlue",
        "gold": "Gold",
        "green": "ForestGreen",
        "pink": "HotPink",
        "grey": "DarkGrey",
    }
    default_name: str = "grey"
    active_name: str = default_name


colors = Colors()


def create_app(test_config: t.Mapping[str, t.Any] | None = None) -> Flask:
    """Create and configure the app.

    Returns:
        Flask : An instance of the Flask app.
    """
    app = Flask(__name__, instance_relative_config=True)
    app.jinja_env.autoescape = select_autoescape(
        enabled_extensions=("html", "htm", "xml", "xhtml", "svg", "j2"),
        default_for_string=True,
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile("config.py", silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    @app.route(
        "/",
        methods=[
            "GET",
        ],
    )
    def index() -> Response:
        """Render a template.

        Returns:
            flask.wrappers.Response
        """
        params: dict[str, str] = {
            "Version tag": os.environ.get("VERSION_TAG", default="N/A"),
            "Source code version": webcolors.__version__,
            "Background color": f"{colors.active_name} ({colors.names[colors.active_name]})",
            "Supported colors": ", ".join(colors.names.keys()),
            "GitHub Actions is running the workflow": os.environ.get("GITHUB_ACTIONS", default="false"),
            "Commit number": os.environ.get("GITHUB_SHA", default="N/A"),
            "Short commit number": os.environ.get("GITHUB_SHA", default="N/A")[:7],
            "Tag ref that triggered the workflow": os.environ.get("GITHUB_REF", default="N/A"),
            "Created on OS": os.environ.get("RUNNER_OS", default="N/A"),
            "Created on arch": os.environ.get("RUNNER_ARCH", default="N/A"),
            "Server hostname": socket.gethostname(),
            "Server socket": str(request.server),
            "Client IP address": str(request.remote_addr),
            "Request headers": str(request.headers).replace("\r\n", "\n"),
            "Request method": str(request.method),
            "Request URL": str(request.url),
        }
        resp = make_response(
            render_template("hello.html.j2", bgcolor=colors.names[colors.active_name], params=params),
            200,
        )
        resp.headers["Content-Security-Policy"] = "default-src 'self'; style-src 'self' 'unsafe-inline'"
        resp.headers["X-Frame-Options"] = "SAMEORIGIN"
        resp.headers["X-Content-Type-Options"] = "nosniff"
        return resp

    return app


def main() -> None:
    """Initialize the app."""
    app = create_app()
    print_help(app.logger, ", ".join(colors.names.keys()), HOST, PORT)
    parser = argparse.ArgumentParser()
    parser.add_argument("--color", required=False, help="Color name", type=str)
    parser.add_argument("--debug", action="store_true", help="Enable Flask debug mode")
    args = parser.parse_args()

    if args.color:
        app.logger.info(f"Getting a color from command line arguments = {args.color.lower()}")
        colors.active_name = args.color.lower()
    else:
        app.logger.info(
            f"Getting a color from env var. Default color ({colors.default_name}) will be used, if not defined."
        )
        colors.active_name = os.environ.get("COLOR", default=colors.default_name)

    if colors.active_name == "random":
        app.logger.info("A random color was selected.")
        colors.active_name = random.choice(list(colors.names))  # nosec # noqa: S311

    if colors.active_name not in colors.names:
        app.logger.info(f"An unsupported color was used, supported colors: {', '.join(colors.names.keys())}")
        sys.exit(1)

    app.logger.info(f"Finally, {colors.active_name} color will be used.\n")

    # Run Flask
    app.run(host=HOST, port=PORT, debug=args.debug)  # nosec


if __name__ == "__main__":
    main()
