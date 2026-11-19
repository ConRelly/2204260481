"""Refresh the NPC vanilla reference text files from the installed Dota VPK."""

import argparse
from pathlib import Path
from tempfile import NamedTemporaryFile

from vpk import vpk_entries


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "NPC vanilla"
INSTALL_ARCHIVE = Path("common/dota 2 beta/game/dota/pak01_dir.vpk")
HERO_DIR = "scripts/npc/heroes/"
REFERENCE_FILES = {
    "resource/localization/abilities_english.txt": "abilities_english.txt",
    "scripts/items/items_game.txt": "items_game.txt",
    "scripts/npc/items.txt": "items.txt",
    "scripts/npc/neutral_items.txt": "neutral_items.txt",
    "scripts/npc/npc_abilities.txt": "npc_abilities.txt",
    "scripts/npc/npc_heroes.txt": "npc_heroes.txt",
    "scripts/npc/npc_units.txt": "npc_units.txt",
}


def read_reference(archive):
    destinations = REFERENCE_FILES.copy()
    contents = {}
    for entry in vpk_entries(archive):
        if entry.path.startswith(HERO_DIR) and entry.path.endswith(".txt"):
            destinations[entry.path] = entry.path
        if entry.path in destinations:
            contents[destinations[entry.path]] = entry.read(archive)

    missing = sorted(set(REFERENCE_FILES.values()) - contents.keys())
    if missing:
        raise ValueError(f"Reference files missing from the VPK: {', '.join(missing)}")
    if not any(path.startswith(HERO_DIR) for path in contents):
        raise ValueError("Hero text files are missing from the VPK")
    return contents


def replace_file(path, contents):
    path.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile(dir=path.parent, delete=False) as handle:
        staged = Path(handle.name)
    try:
        staged.write_bytes(contents)
        staged.replace(path)
    finally:
        staged.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vpk", type=Path, help="Path to pak01_dir.vpk for a separate Steam installation")
    parser.add_argument("--check", action="store_true", help="Verify the reference files without writing")
    args = parser.parse_args()
    archive = args.vpk or next((parent / INSTALL_ARCHIVE for parent in ROOT.parents
                                if (parent / INSTALL_ARCHIVE).is_file()), None)
    if archive is None:
        parser.error("Could not find Dota. Pass --vpk with the installed pak01_dir.vpk path.")

    try:
        contents = read_reference(archive)
        changed = []
        for filename, data in sorted(contents.items()):
            path = REFERENCE / filename
            if not path.is_file() or path.read_bytes() != data:
                changed.append((path, data))
        print(f"Read {len(contents)} reference text files from {archive}")
        if args.check:
            for path, _ in changed:
                print("OUTDATED", path.relative_to(ROOT))
            print(f"{len(changed)} files differ from the VPK.")
            return bool(changed)
        for path, data in changed:
            replace_file(path, data)
        print(f"Refreshed {len(changed)} files. {len(contents) - len(changed)} already matched.")
        return 0
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    raise SystemExit(main())
