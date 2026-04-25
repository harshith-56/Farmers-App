"""
prepare_pest_dataset.py
=======================
Converts pesticide_dataset_one (YOLO format) into folder-per-class
format ready for MobileNetV2 training.

Run from: backend/ML_Training/
Output:   backend/ML_Training/prepared_pest_dataset/{class_name}/

Usage:
    python prepare_pest_dataset.py
    python prepare_pest_dataset.py --dry-run
"""

import shutil
import hashlib
import argparse
import yaml
from pathlib import Path
from collections import defaultdict

DATASET_DIR = Path("pesticide_dataset_one")
OUTPUT_DIR  = Path("prepared_pest_dataset")
VALID_EXTS  = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def file_hash(path: Path) -> str:
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def run(dry_run: bool = False):
    # ── Load class names from data.yaml ──────────────────────────────────
    yaml_path = DATASET_DIR / "data.yaml"
    if not yaml_path.exists():
        print(f"[ERROR] data.yaml not found at {yaml_path}")
        return

    with open(yaml_path) as f:
        meta = yaml.safe_load(f)

    class_names: list = meta.get("names", [])
    if not class_names:
        print("[ERROR] No 'names' found in data.yaml")
        return

    print(f"Classes ({len(class_names)}): {class_names}\n")

    # ── Process each split ────────────────────────────────────────────────
    stats           = defaultdict(int)
    skipped_no_label = 0
    skipped_dup      = 0
    seen_hashes      = set()

    if not dry_run:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for split in ["train", "valid", "test"]:
        img_dir   = DATASET_DIR / split / "images"
        label_dir = DATASET_DIR / split / "labels"

        if not img_dir.exists():
            continue

        for img_path in sorted(img_dir.iterdir()):
            if img_path.suffix.lower() not in VALID_EXTS:
                continue

            label_path = label_dir / (img_path.stem + ".txt")

            if not label_path.exists():
                skipped_no_label += 1
                continue

            # Read class ids from label file
            class_ids = []
            with open(label_path) as lf:
                for line in lf:
                    parts = line.strip().split()
                    if parts:
                        try:
                            class_ids.append(int(parts[0]))
                        except ValueError:
                            pass

            if not class_ids:
                skipped_no_label += 1
                continue

            # Use majority class
            majority_id = max(set(class_ids), key=class_ids.count)

            if majority_id >= len(class_names):
                print(f"  [WARN] class_id {majority_id} out of range — {img_path.name}")
                continue

            class_name = class_names[majority_id].lower()

            # Duplicate check
            h = file_hash(img_path)
            if h in seen_hashes:
                skipped_dup += 1
                continue
            seen_hashes.add(h)

            if not dry_run:
                dest_dir = OUTPUT_DIR / class_name
                dest_dir.mkdir(parents=True, exist_ok=True)

                new_name = f"{split}_{img_path.name}"
                dest = dest_dir / new_name
                counter = 1
                while dest.exists():
                    dest = dest_dir / f"{split}_{img_path.stem}_{counter}{img_path.suffix}"
                    counter += 1

                shutil.copy2(img_path, dest)

            stats[class_name] += 1

    # ── Report ────────────────────────────────────────────────────────────
    print("=" * 40)
    print(f"  {'DRY RUN — ' if dry_run else ''}DONE")
    print("=" * 40)
    print(f"  {'Class':<20} {'Images':>6}")
    print("-" * 40)
    for cls in sorted(stats):
        print(f"  {cls:<20} {stats[cls]:>6}")
    print("-" * 40)
    print(f"  {'TOTAL':<20} {sum(stats.values()):>6}")
    print(f"\n  Skipped (no label) : {skipped_no_label}")
    print(f"  Skipped (duplicate): {skipped_dup}")
    if not dry_run:
        print(f"\n  Output → {OUTPUT_DIR.resolve()}")
    print("=" * 40)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview without copying files.")
    args = parser.parse_args()
    run(dry_run=args.dry_run)