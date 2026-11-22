# repo-playbook

Skill workflow per fase (PRD → PLAN → fase → DoD → review) yang dipakai bersama oleh Claude Code, Codex, Google Antigravity, dan Muse Code, termasuk saat dijalankan lewat T3 Code.

Satu set `SKILL.md` disalin ke dua lokasi di setiap project:

| Lokasi di project | Dibaca oleh |
|---|---|
| `.agents/skills/<nama>/SKILL.md` | Codex, Antigravity, Muse Code |
| `.claude/skills/<nama>/SKILL.md` | Claude Code (Muse juga membacanya) |
| `AGENTS.md` (blok `repo-playbook`) | Semua agent; menunjuk ke skill jika tidak termuat otomatis |
| `CLAUDE.md` (`@AGENTS.md`) | Claude Code |

Skill disalin, bukan symlink, agar project tetap berfungsi saat di-clone di Windows.

## Skill

| Skill | Kapan dipakai |
|---|---|
| `phase-setup-new` | PRD.md dan PLAN.md sudah ada, belum ada kode |
| `phase-setup-existing` | Project sudah berjalan, belum memakai struktur fase |
| `phase-start` | Memulai satu fase (`P3`, atau fase berikutnya) |
| `phase-resume` | Melanjutkan fase yang terhenti (sesi putus, usage limit, ganti provider) |
| `phase-status` | Laporan status read-only maksimal 10 baris |
| `phase-routing` | Aturan delegate ke provider lain dan fallback saat limit (dipakai skill lain) |

Setiap skill berhenti di gate dan bertanya jika ada yang ambigu. Jika semua syarat terpenuhi, skill lanjut otomatis. `phase-start` dan `phase-resume` tidak pernah melanjutkan ke fase berikutnya.

## Install ke project

Sekali per mesin:

```bash
git clone https://github.com/brendatamaar/repo-playbook.git ~/repo-playbook
```

Sekali per project, lalu commit hasilnya:

```bash
bash ~/repo-playbook/install.sh /path/ke/project        # Linux, macOS, Git Bash
powershell -ExecutionPolicy Bypass -File ~/repo-playbook/install.ps1 C:\path\ke\project   # Windows tanpa bash

cd /path/ke/project
git add .agents .claude AGENTS.md CLAUDE.md
git commit -m "chore: install repo-playbook"
```

Atau tempel `prompts/install.md` ke agent di T3 Code.

Project yang skill-nya sudah di-commit tidak perlu install lagi: cukup clone project-nya.

### Apa yang diubah installer

- Folder skill milik repo-playbook ditimpa. Skill lain di `.agents/skills` atau `.claude/skills` tidak disentuh.
- `.agents/playbook/formats.md` dan `VERSION` ditimpa.
- `.agents/playbook/routing.md` hanya dibuat jika belum ada, karena file ini milik project.
- `AGENTS.md`:
  - belum ada: dibuat
  - sudah ada: hanya blok `<!-- repo-playbook:start -->`…`<!-- repo-playbook:end -->` yang ditambah atau diganti
- `CLAUDE.md`:
  - belum ada: dibuat berisi `@AGENTS.md`
  - sudah ada: baris `@AGENTS.md` ditambahkan di atas jika belum ada

## Update

```bash
git -C ~/repo-playbook pull
bash ~/repo-playbook/install.sh /path/ke/project   # lalu commit
```

## Tes

Buka thread baru di T3 Code untuk setiap provider (Claude, Codex, Antigravity, Muse), lalu tempel `prompts/test.md`. Tes ini read-only.

## Mengubah skill

1. Edit di `skills/`, `shared/`, atau `templates/` di repo ini.
2. Commit dan push.
3. Jalankan install ulang di project yang ingin diperbarui.

Gunakan frontmatter `SKILL.md` minimal (`name`, `description`), karena hanya dua field ini yang dikenali semua provider.
