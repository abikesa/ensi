#!/bin/bash

set -euo pipefail

# Prompt for repo paths
read -rp "🗂️  Enter OLD repo name (e.g., peer-review): " OLD_REPO
read -rp "🆕 Enter NEW repo name (e.g., hologram): " NEW_REPO

echo "🚧 Cleaning $OLD_REPO/, preserving kitabo/ensi (no overwrites)..."

# Step 1: Move kitabo/ensi to a temp location
mkdir -p temp_preserve
cp -a "$OLD_REPO/kitabo/ensi" temp_preserve/ensi

# Step 2: Delete everything else in OLD_REPO/
rm -rf "$OLD_REPO"/*
mkdir -p "$OLD_REPO/kitabo"

# Step 3: Copy everything from NEW_REPO/ to OLD_REPO/ EXCEPT kitabo/ensi
rsync -a --exclude 'kitabo/ensi/' "$NEW_REPO"/ "$OLD_REPO"/

# Step 4: Restore preserved ensi
cp -a temp_preserve/ensi "$OLD_REPO/kitabo/"

# Step 5: Add *only* new files/dirs from NEW_REPO/kitabo/ensi
echo "📁 Merging new files into $OLD_REPO/kitabo/ensi (no overwrites)..."
find "$NEW_REPO/kitabo/ensi" -mindepth 1 -print0 | while IFS= read -r -d '' src_path; do
    rel_path="${src_path#$NEW_REPO/kitabo/ensi/}"
    dest_path="$OLD_REPO/kitabo/ensi/${rel_path}"
    if [ ! -e "$dest_path" ]; then
        if [ -d "$src_path" ]; then
            mkdir -p "$dest_path"
            echo "📂 New dir: $rel_path"
        else
            mkdir -p "$(dirname "$dest_path")"
            cp -a "$src_path" "$dest_path"
            echo "📄 New file: $rel_path"
        fi
    fi
done

# Step 6: Clean up
rm -rf temp_preserve

echo "✅ Done. All preexisting ensi files preserved. Only new files added."
