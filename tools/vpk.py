"""Read paths and file contents from Valve VPK archives."""

from dataclasses import dataclass
from pathlib import Path
import struct
import zlib


DIRECTORY_ARCHIVE = 0x7FFF
ENTRY_HEADER = struct.Struct("<IHHIIH")


@dataclass(frozen=True)
class VpkEntry:
    path: str
    crc: int
    preload: bytes
    archive_index: int
    offset: int
    length: int

    def read(self, archive: Path) -> bytes:
        contents = self.preload
        if self.length:
            data_file = archive
            if self.archive_index != DIRECTORY_ARCHIVE:
                prefix = archive.stem.removesuffix("_dir")
                data_file = archive.with_name(f"{prefix}_{self.archive_index:03d}.vpk")
            with data_file.open("rb") as handle:
                handle.seek(self.offset)
                contents += handle.read(self.length)
        if len(contents) != len(self.preload) + self.length or zlib.crc32(contents) != self.crc:
            raise ValueError(f"VPK entry failed validation: {self.path}")
        return contents


def vpk_entries(archive: Path):
    with archive.open("rb") as handle:
        header = handle.read(12)
        if len(header) != 12:
            raise ValueError(f"Incomplete VPK header: {archive}")
        signature, version, tree_size = struct.unpack("<III", header)
        if signature != 0x55AA1234 or version not in (1, 2):
            raise ValueError(f"Unsupported VPK: {archive}")
        if version == 2:
            handle.seek(16, 1)
        tree = handle.read(tree_size)
        if len(tree) != tree_size:
            raise ValueError(f"Incomplete VPK directory: {archive}")
        data_offset = handle.tell()
    at = 0

    def read_string():
        nonlocal at
        end = tree.find(b"\0", at)
        if end < 0:
            raise ValueError(f"Unterminated VPK directory field: {archive}")
        value = tree[at:end].decode("utf-8")
        at = end + 1
        return value

    while extension := read_string():
        while directory := read_string():
            while name := read_string():
                if at + ENTRY_HEADER.size > len(tree):
                    raise ValueError(f"Incomplete VPK directory entry: {archive}")
                crc, preload_size, archive_index, offset, length, terminator = ENTRY_HEADER.unpack_from(tree, at)
                at += ENTRY_HEADER.size
                if terminator != 0xFFFF or at + preload_size > len(tree):
                    raise ValueError(f"Invalid VPK directory entry: {archive}")
                preload = tree[at:at + preload_size]
                at += preload_size
                prefix = "" if directory == " " else directory + "/"
                path = f"{prefix}{name}.{extension}".lower()
                if archive_index == DIRECTORY_ARCHIVE:
                    offset += data_offset
                yield VpkEntry(path, crc, preload, archive_index, offset, length)


def vpk_paths(archive: Path):
    """List paths without opening any of the archive's data chunks."""
    return (entry.path for entry in vpk_entries(archive))
