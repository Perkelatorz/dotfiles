"""Sample Python: pyright + ruff format / organize imports on save."""

from __future__ import annotations


def greet(name: str = "nvim") -> str:
    return f"Hello, {name}!"


if __name__ == "__main__":
    print(greet())
