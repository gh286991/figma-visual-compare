#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/gh286991/figma-visual-compare.git"
ZIP_URL="https://github.com/gh286991/figma-visual-compare/archive/refs/heads/main.zip"
SKILL_RELATIVE_PATH="skills/figma-visual-compare"
DEST_DIR="${HOME}/.codex/skills"
DEST_SKILL_DIR="${DEST_DIR}/figma-visual-compare"

temp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${temp_dir}"
}
trap cleanup EXIT

mkdir -p "${DEST_DIR}"

if [ -e "${DEST_SKILL_DIR}" ]; then
  rm -rf "${DEST_SKILL_DIR}"
fi

echo "Installing figma-visual-compare into ${DEST_SKILL_DIR}"

if command -v git >/dev/null 2>&1; then
  git clone --depth 1 "${REPO_URL}" "${temp_dir}/repo" >/dev/null 2>&1
else
  archive_path="${temp_dir}/repo.zip"
  extracted_path="${temp_dir}/extracted"
  mkdir -p "${extracted_path}"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${ZIP_URL}" -o "${archive_path}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${archive_path}" "${ZIP_URL}"
  else
    echo "Error: git, curl, or wget is required to install this skill." >&2
    exit 1
  fi

  if ! command -v unzip >/dev/null 2>&1; then
    echo "Error: unzip is required when git is not available." >&2
    exit 1
  fi

  unzip -q "${archive_path}" -d "${extracted_path}"
  repo_dir="$(find "${extracted_path}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  mv "${repo_dir}" "${temp_dir}/repo"
fi

cp -R "${temp_dir}/repo/${SKILL_RELATIVE_PATH}" "${DEST_DIR}/"

echo "Installed successfully."
echo "Restart Codex to pick up new skills."
