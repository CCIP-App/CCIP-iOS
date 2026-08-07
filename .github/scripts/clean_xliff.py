#!/usr/bin/env python3
import argparse
import fnmatch
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

XLIFF_NS = "urn:oasis:names:tc:xliff:document:1.2"
XSI_NS = "http://www.w3.org/2001/XMLSchema-instance"
X = f"{{{XLIFF_NS}}}"

# Files whose entries are not worth sending to translators.
DEFAULT_EXCLUDE_FILES = ["*InfoPlist.strings"]

# trans-unit ids that are pure build metadata, never user-visible copy.
DEFAULT_EXCLUDE_IDS = [
    "CFBundleDisplayName",
    "CFBundleName",
    "CFBundleShortVersionString",
    "CFBundleVersion",
    "NSHumanReadableCopyright",
]


def matches_any(value, patterns):
    return any(fnmatch.fnmatch(value, p) for p in patterns)


def clean_tree(tree, opts):
    root = tree.getroot()
    removed_units = 0
    removed_files = 0

    for file_el in list(root.findall(f"{X}file")):
        original = file_el.get("original", "")

        if opts.include and not matches_any(original, opts.include):
            root.remove(file_el)
            removed_files += 1
            continue

        if matches_any(original, opts.exclude_files):
            root.remove(file_el)
            removed_files += 1
            continue

        body = file_el.find(f"{X}body")
        if body is None:
            root.remove(file_el)
            removed_files += 1
            continue

        for unit in list(body.findall(f"{X}trans-unit")):
            unit_id = unit.get("id", "")
            source = unit.find(f"{X}source")
            source_text = (source.text or "") if source is not None else ""

            drop = False
            if matches_any(unit_id, opts.exclude_ids):
                drop = True
            elif opts.drop_no_translate and unit.get("translate") == "no":
                drop = True
            elif opts.drop_empty_source and not source_text.strip():
                drop = True

            if drop:
                body.remove(unit)
                removed_units += 1

        if not body.findall(f"{X}trans-unit"):
            root.remove(file_el)
            removed_files += 1

    return removed_units, removed_files


def serialize(tree, path):
    ET.indent(tree, space="  ")
    xml_bytes = ET.tostring(tree.getroot(), encoding="unicode")
    # ET emits `<note />`; Xcode emits `<note/>`. Keep diffs stable.
    xml_bytes = re.sub(r"\s+/>", "/>", xml_bytes)
    path.write_text('<?xml version="1.0" encoding="UTF-8"?>\n' + xml_bytes + "\n",
                    encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="+", type=Path,
                    help="XLIFF files, or directories to scan for *.xliff")
    ap.add_argument("--include", action="append", default=[],
                    metavar="GLOB",
                    help="keep only <file original=...> matching this glob "
                         "(repeatable). e.g. '*.xcstrings'")
    ap.add_argument("--exclude-file", action="append", dest="exclude_files",
                    default=None, metavar="GLOB",
                    help=f"drop <file> matching glob. default: "
                         f"{' '.join(DEFAULT_EXCLUDE_FILES)}")
    ap.add_argument("--exclude-id", action="append", dest="exclude_ids",
                    default=None, metavar="GLOB",
                    help="drop trans-unit whose id matches glob")
    ap.add_argument("--keep-no-translate", action="store_false",
                    dest="drop_no_translate",
                    help='keep units marked translate="no"')
    ap.add_argument("--keep-empty-source", action="store_false",
                    dest="drop_empty_source",
                    help="keep units with an empty <source>")
    opts = ap.parse_args()

    if opts.exclude_files is None:
        opts.exclude_files = DEFAULT_EXCLUDE_FILES
    if opts.exclude_ids is None:
        opts.exclude_ids = DEFAULT_EXCLUDE_IDS

    ET.register_namespace("", XLIFF_NS)
    ET.register_namespace("xsi", XSI_NS)

    files = []
    for p in opts.paths:
        files.extend(sorted(p.rglob("*.xliff")) if p.is_dir() else [p])

    if not files:
        print("No .xliff files found.", file=sys.stderr)
        return 1

    for path in files:
        tree = ET.parse(path)
        units, drops = clean_tree(tree, opts)
        serialize(tree, path)
        print(f"{path}: removed {units} trans-unit(s), {drops} file section(s)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
