#!/usr/bin/env python3
"""Graft translated <target> elements from a repo XLIFF into a freshly exported one.

Usage: merge_xliff.py <fresh.xliff> <translated.xliff>

The fresh file (straight out of `xcodebuild -exportLocalizations`) is the skeleton,
so the importer always sees the structure it expects; only <target> content comes
from the translated file.
"""

import copy
import sys
import xml.etree.ElementTree as ET

NS_URI = "urn:oasis:names:tc:xliff:document:1.2"
NS = {"x": NS_URI}
TRANS_UNIT = f"{{{NS_URI}}}trans-unit"

ET.register_namespace("", NS_URI)
ET.register_namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")


def has_content(target):
    if target is None:
        return False
    # len() > 0 keeps inline markup such as <g>/<x/> in formatted strings
    return bool((target.text or "").strip()) or len(target) > 0


def index_translations(path):
    """Index by (file original, unit id), plus an id-only fallback."""
    exact, by_id, ambiguous = {}, {}, set()
    for file_el in ET.parse(path).getroot().findall("x:file", NS):
        original = file_el.get("original")
        for unit in file_el.iter(TRANS_UNIT):
            uid = unit.get("id")
            target = unit.find("x:target", NS)
            if uid is None or not has_content(target):
                continue  # untranslated: leave whatever the fresh export has
            exact[(original, uid)] = target
            if uid in by_id:
                ambiguous.add(uid)
            else:
                by_id[uid] = target
    return exact, by_id, ambiguous


def merge(fresh_path, translated_path):
    exact, by_id, ambiguous = index_translations(translated_path)
    tree = ET.parse(fresh_path)
    applied = fuzzy = 0

    for file_el in tree.getroot().findall("x:file", NS):
        original = file_el.get("original")
        for unit in file_el.iter(TRANS_UNIT):
            uid = unit.get("id")
            new_target = exact.get((original, uid))
            if new_target is None:
                if uid not in by_id or uid in ambiguous:
                    continue
                new_target = by_id[uid]
                fuzzy += 1

            old = unit.find("x:target", NS)
            if old is not None:
                unit.remove(old)
            source = unit.find("x:source", NS)
            pos = list(unit).index(source) + 1 if source is not None else 0
            unit.insert(pos, copy.deepcopy(new_target))
            applied += 1

    tree.write(fresh_path, encoding="utf-8", xml_declaration=True)
    unmatched = max(len(exact) - applied, 0)
    print(f"{translated_path}: {applied} applied "
          f"({fuzzy} by id only), {unmatched} unmatched")


if __name__ == "__main__":
    merge(sys.argv[1], sys.argv[2])
