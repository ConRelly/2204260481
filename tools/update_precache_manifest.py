"""Build the explicit local-play precache list from Lua and active KV includes.

Run with --write after adding effects; without it, check that the list is current.
Only resources compiled in this addon or the installed Dota/core files are added.
Existing explicit entries are retained for resources constructed dynamically.
"""

import argparse
from pathlib import Path
import re
import struct


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "scripts/vscripts/hack/precache_lua_res.lua"
KV_ROOTS = (
    "npc_units_custom.txt", "npc_abilities_custom.txt", "npc_heroes_custom.txt",
    "npc_items_custom.txt", "npc_abilities_override.txt",
)
RESOURCE = re.compile(
    r"^(?:particles|models|soundevents|sounds)/[^\r\n]+\.(?:vpcf|vmdl|vsndevts|vsnd)$"
)
LUA_TOKENS = re.compile(
    r'--\[(=*)\[.*?\]\1\]|--[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', re.S
)
KV_TOKENS = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|[^\s{}"]+', re.S)


def literals(text, lua=False):
    """Read quoted values without interpreting comments or collapsing KV keys."""
    pattern = LUA_TOKENS if lua else KV_TOKENS
    for match in pattern.finditer(text):
        token = match.group()
        if token.startswith(('"', "'")):
            yield token[1:-1]


def resource_paths(text, lua=False):
    for value in literals(text, lua):
        path = re.sub(r"/+", "/", value.replace("\\", "/").strip()).lower()
        if RESOURCE.fullmatch(path):
            yield path


def vpk_paths(filename):
    """Read the directory tree only; never extract/scan whole particle folders."""
    with filename.open("rb") as handle:
        header = handle.read(12)
        signature, version, tree_size = struct.unpack("<III", header)
        if signature != 0x55AA1234 or version not in (1, 2):
            raise ValueError(f"Unsupported VPK: {filename}")
        if version == 2:
            handle.read(16)
        tree = handle.read(tree_size)
    at = 0

    def string():
        nonlocal at
        end = tree.index(0, at)
        result = tree[at:end].decode("utf-8")
        at = end + 1
        return result

    while True:
        extension = string()
        if not extension:
            return
        while True:
            directory = string()
            if not directory:
                break
            while True:
                name = string()
                if not name:
                    break
                _, preload, _, _, _, terminator = struct.unpack_from("<IHHIIH", tree, at)
                if terminator != 0xFFFF:
                    raise ValueError(f"Invalid VPK directory entry: {filename}")
                at += 18 + preload
                prefix = "" if directory == " " else directory + "/"
                yield (prefix + name + "." + extension).lower()


def kv_sources():
    pending = [ROOT / "scripts/npc" / name for name in KV_ROOTS]
    seen = set()
    while pending:
        filename = pending.pop().resolve()
        if filename in seen:
            continue
        # Includes must belong to the addon, not an unrelated checkout.
        filename.relative_to(ROOT)
        text = filename.read_text(encoding="utf-8-sig")
        seen.add(filename)
        tokens = [m.group() for m in KV_TOKENS.finditer(text)
                  if not m.group().startswith(("//", "/*"))]
        for index, token in enumerate(tokens[:-1]):
            if token.lower() in ("#base", "#include"):
                pending.append(filename.parent / tokens[index + 1].strip('"'))
        yield filename, text


def collect_paths():
    paths = set()
    # Preserve curated entries, including dynamically selected particle names.
    if MANIFEST.is_file():
        paths.update(resource_paths(MANIFEST.read_text(encoding="utf-8-sig"), lua=True))
    for filename in sorted((ROOT / "scripts/vscripts").rglob("*.lua")):
        if filename == MANIFEST or filename == ROOT / "scripts/vscripts/precache.lua":
            continue  # Legacy precache.lua is inactive.
        paths.update(resource_paths(filename.read_text(encoding="utf-8-sig"), lua=True))
    for _, text in kv_sources():
        paths.update(resource_paths(text))
    # PopupNumbers constructs these paths at runtime rather than as literals.
    for kind in ("damage", "damage_crit", "heal", "gold", "miss", "block", "evade", "deny", "poison"):
        paths.add(f"particles/msg_fx/msg_{kind}.vpcf")
    return paths


def render(paths):
    lines = [
        "-- Verified individual resources for local/tools play; never use particle_folder.",
        "-- Updated by: python tools/update_precache_manifest.py --write",
        "-- Includes Lua literals and active KV includes, preserving repeated precache keys.",
        "", "local lua_resources = {",
    ]
    for name, extensions in (("particles", (".vpcf",)), ("models", (".vmdl",)),
                             ("sounds", (".vsndevts", ".vsnd"))):
        lines.append(f"    {name} = {{")
        lines.extend(f'        "{path}",' for path in sorted(paths) if path.endswith(extensions))
        lines.append("    },")
        lines.append("")
    lines.extend(["}", "", "return lua_resources", ""])
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game-dir", type=Path, help="Dota game/dota directory")
    parser.add_argument("--write", action="store_true", help="Update the generated Lua manifest")
    parser.add_argument("--report-missing", action="store_true", help="List unavailable references")
    args = parser.parse_args()
    game = args.game_dir
    if game is None:
        game = next((parent / "common/dota 2 beta/game/dota" for parent in ROOT.parents
                     if (parent / "common/dota 2 beta/game/dota/pak01_dir.vpk").is_file()), None)
    if game is None or not (game / "pak01_dir.vpk").is_file():
        parser.error("Pass --game-dir with the installed Dota game/dota directory")
    mounted = (game, game.parent / "core")
    available = set()
    for directory in mounted:
        archive = directory / "pak01_dir.vpk"
        if archive.is_file():
            available.update(vpk_paths(archive))
    candidates = collect_paths()
    valid = {path for path in candidates
             if path + "_c" in available or any((directory / (path + "_c")).is_file()
                                               for directory in (ROOT, *mounted))}
    if args.report_missing:
        for path in sorted(candidates - valid):
            print("UNAVAILABLE:", path)
    generated = render(valid)
    print(f"Verified {len(valid)} resources; excluded {len(candidates - valid)} unavailable references.")
    previous = MANIFEST.read_text(encoding="utf-8-sig") if MANIFEST.is_file() else ""
    if previous == generated:
        print("Precache manifest is current.")
        return 0
    if args.write:
        MANIFEST.write_text(generated, encoding="utf-8", newline="\n")
        print("Updated", MANIFEST.relative_to(ROOT))
        return 0
    print("Precache manifest is stale; rerun with --write.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
