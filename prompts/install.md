Pasang repo-playbook ke project ini.

1. Cek `git status`. Jika working tree tidak bersih, BERHENTI dan laporkan file yang berubah.
2. Siapkan repo playbook di `~/repo-playbook`:
   - belum ada: `git clone https://github.com/brendatamaar/repo-playbook.git ~/repo-playbook`
   - sudah ada: `git -C ~/repo-playbook pull --ff-only`
3. Jalankan installer dari root project ini:
   - Linux, macOS, atau Git Bash: `bash ~/repo-playbook/install.sh .`
   - Windows tanpa bash: `powershell -ExecutionPolicy Bypass -File ~/repo-playbook/install.ps1 .`
4. Periksa hasilnya: `git status` dan `git diff -- AGENTS.md CLAUDE.md`.
   Pastikan tidak ada baris lama AGENTS.md atau CLAUDE.md yang hilang. Jika ada yang hilang, BERHENTI dan laporkan.
5. Commit: `git add .agents .claude AGENTS.md CLAUDE.md && git commit -m "chore: install repo-playbook <isi .agents/playbook/VERSION>"`.
6. Laporan maksimal 10 baris:
   - versi yang terpasang
   - file yang ditambah atau diubah
   - langkah berikutnya: skill phase-setup-new (belum ada kode) atau phase-setup-existing (project sudah berjalan)
