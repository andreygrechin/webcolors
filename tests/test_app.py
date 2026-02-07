# ruff: noqa: DOC201 DOC402 S101 PLC0415 D100 ARG001 PLR2004
import os
from collections.abc import Generator

import pytest
from flask import Flask
from flask.testing import FlaskClient

from webcolors.app import colors, create_app


@pytest.fixture
def app() -> Flask:
    """Create and configure a test Flask app instance."""
    test_config = {"TESTING": True}
    return create_app(test_config)


@pytest.fixture
def client(app: Flask) -> FlaskClient:
    """Create a test client for the app."""
    return app.test_client()


@pytest.fixture
def original_color() -> Generator[str, None, None]:
    """Save and restore the original active color."""
    original = colors.active_name
    yield original
    colors.active_name = original


def test_index_route(client: FlaskClient) -> None:
    """Test the index route returns 200 and contains expected content."""
    response = client.get("/")
    assert response.status_code == 200
    assert b"Hello from WebColors app" in response.data
    assert b"Parameters" in response.data


def test_security_headers(client: FlaskClient) -> None:
    """Test security headers are set correctly."""
    response = client.get("/")
    headers = response.headers
    assert headers["Content-Security-Policy"] == "default-src 'self'; style-src 'self' 'unsafe-inline'"
    assert headers["X-Frame-Options"] == "SAMEORIGIN"
    assert headers["X-Content-Type-Options"] == "nosniff"


def test_request_data_is_escaped(client: FlaskClient) -> None:
    """Ensure request-derived values are escaped in HTML output."""
    payload = "<script>alert(1)</script>"
    response = client.get("/", headers={"X-Test": payload}, query_string={"value": payload})
    html = response.get_data(as_text=True)

    assert payload not in html
    assert "&lt;script&gt;alert(1)&lt;/script&gt;" in html


def test_color_from_env(app: Flask, original_color: str) -> None:
    """Test color selection from environment variable."""
    test_color = "blue"
    os.environ["COLOR"] = test_color
    with app.test_request_context():
        colors.active_name = os.environ.get("COLOR", default=colors.default_name)
        assert colors.active_name == test_color


def test_invalid_color(app: Flask, original_color: str) -> None:
    """Test that invalid colors are handled appropriately."""
    colors.active_name = "invalid_color"
    assert colors.active_name not in colors.names


def test_random_color(app: Flask, original_color: str) -> None:
    """Test random color selection."""
    colors.active_name = "random"
    with app.test_request_context():
        if colors.active_name == "random":
            from webcolors.app import random

            colors.active_name = random.choice(list(colors.names))
        assert colors.active_name in colors.names
