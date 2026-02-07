"""Print a help message."""

from logging import Logger


def print_help(logger: Logger, supported_colors: str, host: str, port: int) -> None:
    """Print a help message."""
    logger.info(  # pylint:disable=no-member
        f"""

        This is a sample containerized web application that displays one page
        with a colored background. A color can be specified in a few ways,
        in order of priority:

            1. As a command line argument `--color`.
            2. As an environment variable `COLOR`.
            3. If none of the above then the gray color will be used.

        Supported colors: {supported_colors}
        Also you may choose a `random` as an option.

        For debug use `--debug` flag.

        To open the page from docker container, use: open
            http://{host}:{port}/

        """
    )
