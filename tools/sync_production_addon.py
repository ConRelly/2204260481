"""Update the Workshop Tools production addon from the workshop workspace."""

import argparse
import filecmp
import os
from pathlib import Path
import shutil
import stat
from tempfile import NamedTemporaryFile, gettempdir

import msvcrt


WORKSPACE = Path(r"D:\SteamLibrary\steamapps\workshop\content\570\2204260481\2204260481")
PRODUCTION = Path(r"D:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\hero_attack_on_gods")
WORKSPACE_ONLY = {"npc vanilla", ".git", ".gitattributes", "agents.md"}
TOOLS_CACHES = {"tools_asset_info.bin", "tools_thumbnail_cache.sqlite3"}


def checked_directory(path):
    for folder in (*reversed(path.parents), path):
        if folder.lstat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:
            raise ValueError(f"Linked folder in the addon path: {folder}")
    if not path.is_dir():
        raise ValueError(f"Expected an addon directory: {path}")
    return path.resolve(strict=True)


def inventory(root, excluded):
    directories = set()
    files = {}
    pending = [Path()]
    while pending:
        directory = pending.pop()
        # Windows supplies the file sizes and timestamps with the directory listing.
        with os.scandir(root / directory) as entries:
            for entry in entries:
                if not directory.parts and entry.name.casefold() in excluded:
                    continue
                info = entry.stat(follow_symlinks=False)
                relative = directory / entry.name
                if info.st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:
                    raise ValueError(f"Linked entry in the addon: {root / relative}")
                if stat.S_ISDIR(info.st_mode):
                    directories.add(relative)
                    pending.append(relative)
                else:
                    files[relative] = (info.st_size, info.st_mtime_ns)
    return directories, files


def copy_file(source, target):
    # Stage beside the target so an interrupted copy leaves the old file intact.
    with NamedTemporaryFile(dir=target.parent, prefix=".aoh-copy-", delete=False) as handle:
        staged = Path(handle.name)
    try:
        shutil.copy2(source, staged)
        staged.replace(target)
    finally:
        staged.unlink(missing_ok=True)


def remove_entries(root, directories, paths):
    for relative in sorted(paths, key=lambda path: len(path.parts), reverse=True):
        path = root / relative
        resolved = path.resolve(strict=True)
        if root not in resolved.parents or resolved != path:
            raise ValueError(f"Unexpected path while removing an obsolete entry: {path}")
        if relative in directories:
            path.rmdir()
        else:
            path.unlink()


def sync_addon(source, target, check=False, verify=False):
    source = checked_directory(source)
    target = checked_directory(target)
    if source.is_relative_to(target) or target.is_relative_to(source):
        raise ValueError("Expected separate workspace and production directories.")

    source_directories, source_files = inventory(source, WORKSPACE_ONLY | TOOLS_CACHES)
    if Path("addoninfo.txt") not in source_files:
        raise ValueError(f"Missing addoninfo.txt in the workspace: {source}")
    target_directories, target_files = inventory(target, TOOLS_CACHES)

    conflicting = (source_files.keys() & target_directories) | (target_files.keys() & source_directories)
    obsolete = (target_files.keys() - source_files.keys()) | (target_directories - source_directories)
    blockers = {path for path in obsolete if path in conflicting or conflicting.intersection(path.parents)}
    filecmp.clear_cache()
    copies = [
        path for path, metadata in source_files.items()
        if path not in target_files or (
            (verify or metadata != target_files[path])
            and not filecmp.cmp(source / path, target / path, shallow=False)
        )
    ]
    new_directories = source_directories - target_directories

    if check:
        print(f"Would copy {len(copies)} files, create {len(new_directories)} directories, "
              f"and remove {len(obsolete)} obsolete entries.")
        return

    # A path that changed between a file and a directory must be cleared up front.
    remove_entries(target, target_directories, blockers)
    for path in sorted(new_directories, key=lambda relative: len(relative.parts)):
        (target / path).mkdir()
    for path in copies:
        copy_file(source / path, target / path)
    remove_entries(target, target_directories, obsolete - blockers)
    print(f"Production addon is up to date. Copied {len(copies)} files and removed {len(obsolete)} obsolete entries.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Show planned changes without updating production")
    parser.add_argument("--verify", action="store_true", help="Compare contents even when size and modified time match")
    args = parser.parse_args()
    try:
        if args.check:
            sync_addon(WORKSPACE, PRODUCTION, check=True, verify=args.verify)
        else:
            print("Updating the production addon...", flush=True)
            lock = Path(gettempdir()) / "hero_attack_on_gods_production_sync.lock"
            with lock.open("a+b") as handle:
                handle.seek(0)
                try:
                    msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
                except OSError as error:
                    raise ValueError("A production sync is already running.") from error
                sync_addon(WORKSPACE, PRODUCTION, verify=args.verify)
    except (OSError, ValueError) as error:
        print(f"Production sync failed: {error}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
