# /// script
# requires-python = ">=3.13"
# dependencies = []
# ///

import subprocess
from pathlib import Path
from itertools import product


def get_output_path(attr: str, version: str) -> Path:
    return Path(f"{attr}.{version}.profile")


def profile_version(attr: str, version: str, output_folder: Path):
    command = [
        "nix",
        "eval",
        f".#{attr}",
        "--impure",
        "--override-input",
        "test_nixpkgs",
        f"github:NixOS/nixpkgs/release-{version}",
        "--eval-profiler",
        "flamegraph",
        "--eval-profile-file",
        f"{str(output_folder / get_output_path(attr, version))}",
    ]
    subprocess.run(command)


def main() -> None:
    versions = [
        "14.12",
        "15.09",
        "16.03",
        "16.09",
        "17.03",
        "17.09",
        "18.03",
        "18.09",
        "19.03",
        "19.09",
        "20.03",
        "20.09",
        "21.05",
        "21.11",
        "22.05",
        "22.11",
        "23.05",
        "23.11",
        "24.05",
        "24.11",
        "25.05",
    ]
    attrs = ["ec2", "kde", "lapp", "stdenv"]
    for attr, version in product(attrs, versions):
        output_folder = Path("outputs")
        if (output_folder / get_output_path(attr, version)).exists():
            print(f"Already profiled {attr} on release version {version}.")
            continue
        print(f"Profiling {attr} attribute on release version {version}.")
        profile_version(attr, version, Path("outputs"))


if __name__ == "__main__":
    main()
