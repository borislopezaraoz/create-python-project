#!/usr/bin/env bash
set -euo pipefail

# Check if project name is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME="$1"
TEMPLATE_DIR="template"
TARGET_DIR="$PROJECT_NAME"
PLACEHOLDER="{{project}}"

# Check required tools
for cmd in git make perl; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: '$cmd' is not installed or not in PATH."
    exit 1
  fi
done

# Check template directory
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Error: Template directory '$TEMPLATE_DIR' not found."
  exit 1
fi

# Copy template to target project
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"

# Rename all files/directories containing the placeholder
find "$TARGET_DIR" -depth -name "*$PLACEHOLDER*" -print0 | while IFS= read -r -d '' path; do
  new_path="${path//$PLACEHOLDER/$PROJECT_NAME}"
  mv "$path" "$new_path"
done

# Replace placeholder in all file contents
find "$TARGET_DIR" -type f -print0 | xargs -0 perl -pi -e "s/$PLACEHOLDER/$PROJECT_NAME/g"

# Initialize Git repository
cd "$TARGET_DIR"
git init -q
git add .
git commit -q -m "Initial scaffold for $PROJECT_NAME"

# Run build/test commands
if ! make test; then
  echo "❌ Tests failed."
  exit 1
fi

if ! make run; then
  echo "❌ Run failed."
  exit 1
fi

# Done
echo "✅ Project '$PROJECT_NAME' scaffolded and tested."
