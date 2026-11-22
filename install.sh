#!/usr/bin/env bash
# Pasang skill repo-playbook ke sebuah project.
# Pemakaian: bash install.sh <path-project>
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"
START_MARK='<!-- repo-playbook:start'
END_MARK='<!-- repo-playbook:end -->'

if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
  echo "Pemakaian: bash install.sh <path-project>" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if [ "$TARGET" = "$SRC" ]; then
  echo "Error: target tidak boleh repo-playbook itu sendiri." >&2
  exit 1
fi
if [ ! -d "$TARGET/.git" ]; then
  echo "Peringatan: $TARGET bukan root repo git. Lanjut tetap memasang." >&2
fi

# 1. Skill: salin ke .agents/skills (Codex, Antigravity, Muse) dan .claude/skills (Claude Code).
#    Hanya folder skill milik repo-playbook yang ditimpa; skill lain tidak disentuh.
for dest in ".agents/skills" ".claude/skills"; do
  mkdir -p "$TARGET/$dest"
  for skill_dir in "$SRC"/skills/*/; do
    name="$(basename "$skill_dir")"
    rm -rf "${TARGET:?}/$dest/$name"
    cp -R "$skill_dir" "$TARGET/$dest/$name"
  done
done

# 2. File pendukung.
mkdir -p "$TARGET/.agents/playbook"
cp "$SRC/shared/formats.md" "$TARGET/.agents/playbook/formats.md"
if [ ! -f "$TARGET/.agents/playbook/routing.md" ]; then
  cp "$SRC/shared/routing.md" "$TARGET/.agents/playbook/routing.md"
  routing_note="dibuat"
else
  routing_note="dipertahankan (milik project)"
fi
version="$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo unknown)"
printf '%s\n' "$version" > "$TARGET/.agents/playbook/VERSION"

# 3. AGENTS.md: buat jika belum ada; jika ada, ganti/tambah blok repo-playbook saja.
SECTION="$SRC/templates/agents-section.md"
AGENTS="$TARGET/AGENTS.md"
if [ ! -f "$AGENTS" ]; then
  {
    printf '# Agent rules\n\n'
    printf '<!-- Stack, perintah test/lint/build, dan konvensi: diisi oleh skill phase-setup-new / phase-setup-existing. -->\n\n'
    cat "$SECTION"
  } > "$AGENTS"
  agents_note="dibuat"
elif grep -qF "$START_MARK" "$AGENTS"; then
  if ! grep -qF "$END_MARK" "$AGENTS"; then
    echo "Error: AGENTS.md punya penanda start tanpa penanda end. Perbaiki manual dulu." >&2
    exit 1
  fi
  tmp="$(mktemp)"
  awk -v secfile="$SECTION" -v start="$START_MARK" -v end="$END_MARK" '
    BEGIN { while ((getline line < secfile) > 0) sec = sec line "\n" }
    index($0, start) == 1 { printf "%s", sec; skip = 1; next }
    skip && index($0, end) == 1 { skip = 0; next }
    !skip { print }
  ' "$AGENTS" > "$tmp"
  cat "$tmp" > "$AGENTS"
  rm -f "$tmp"
  agents_note="blok repo-playbook diperbarui"
else
  { printf '\n'; cat "$SECTION"; } >> "$AGENTS"
  agents_note="blok repo-playbook ditambahkan di akhir (isi lama dipertahankan)"
fi

# 4. CLAUDE.md: pastikan mengimpor AGENTS.md.
CLAUDE="$TARGET/CLAUDE.md"
if [ ! -f "$CLAUDE" ]; then
  printf '@AGENTS.md\n' > "$CLAUDE"
  claude_note="dibuat"
elif grep -qx '@AGENTS.md' "$CLAUDE"; then
  claude_note="sudah mengimpor AGENTS.md"
else
  tmp="$(mktemp)"
  { printf '@AGENTS.md\n\n'; cat "$CLAUDE"; } > "$tmp"
  cat "$tmp" > "$CLAUDE"
  rm -f "$tmp"
  claude_note="baris @AGENTS.md ditambahkan di atas (isi lama dipertahankan)"
fi

skills="$(ls "$SRC/skills" | tr '\n' ' ')"
cat <<EOF
repo-playbook $version terpasang di $TARGET
  skills      : $skills
  lokasi      : .agents/skills/ dan .claude/skills/
  routing.md  : $routing_note
  AGENTS.md   : $agents_note
  CLAUDE.md   : $claude_note

Berikutnya:
  1. Review perubahan: git -C "$TARGET" status && git -C "$TARGET" diff
  2. Commit: git -C "$TARGET" add .agents .claude AGENTS.md CLAUDE.md && git -C "$TARGET" commit -m "chore: install repo-playbook $version"
  3. Jalankan skill phase-setup-new (project baru) atau phase-setup-existing (project berjalan).
EOF
