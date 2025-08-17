# ruff: noqa: D100 D103 S101 ANN001
import logging

from webcolors._help import print_help  # noqa: PLC2701


def test_print_help(caplog) -> None:
    logger = logging.getLogger(__name__)
    test_colors = "red, green"

    with caplog.at_level(logging.INFO):
        print_help(logger, test_colors, "127.0.0.1", 8080)

    assert f"Supported colors: {test_colors}" in caplog.text
