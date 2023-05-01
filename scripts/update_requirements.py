"""Extract requirements from pyproject.toml and write them to requirements.txt.

Required for backwards compatibility with Snyk that doesn't support PEP 621.
"""
import tomllib  # type: ignore

with open("pyproject.toml", "rb") as toml_f:
    pyproject = tomllib.load(toml_f)
    with open("requirements.txt", "w", encoding="UTF-8") as req_f:
        req_f.write("# Use pyproject.toml to specify dependencies\n")
        for v in pyproject["project"]["dependencies"]:
            req_f.write(f"{v}\n")
