Perbarui repo-playbook di project ini ke versi terbaru.

1. Cek versi:
   - terpasang: isi `.agents/playbook/VERSION`
   - terbaru: jalankan `git -C ~/repo-playbook pull --ff-only`, lalu `git -C ~/repo-playbook rev-parse --short HEAD`

   Jika ~/repo-playbook belum ada, clone dulu: `git clone https://github.com/brendatamaar/repo-playbook.git ~/repo-playbook`.
   Jika versinya sama, laporkan "sudah terbaru" dan selesai.
2. Cek `git status`. Perubahan uncommitted milik pekerjaan lain BOLEH ada dan JANGAN disentuh.
   Namun jika AGENTS.md, CLAUDE.md, `.agents/`, atau `.claude/` sendiri punya perubahan uncommitted: BERHENTI dan laporkan.
3. Jalankan installer dari root project ini:
   - Linux, macOS, atau Git Bash: `bash ~/repo-playbook/install.sh .`
   - Windows tanpa bash: `powershell -ExecutionPolicy Bypass -File ~/repo-playbook/install.ps1 .`
4. Periksa `git diff -- AGENTS.md CLAUDE.md`:
   - hanya blok `repo-playbook:start/end` yang boleh berubah
   - isi di luar blok harus utuh
   - `.agents/playbook/routing.md` tidak boleh berubah

   Jika ada yang dilanggar, BERHENTI dan laporkan.
5. Commit HANYA file playbook:
   `git add .agents .claude AGENTS.md CLAUDE.md && git commit -m "chore: update repo-playbook <versi lama> -> <versi baru>"`
   Jangan ikut meng-commit perubahan lain.
6. Laporan maksimal 10 baris:
   - versi lama dan versi baru
   - skill yang berubah: `git -C ~/repo-playbook log --oneline <versi lama>..<versi baru>`
   - konfirmasi bahwa routing.md dan isi AGENTS.md di luar blok tetap utuh

Skill versi baru terbaca oleh thread yang dibuka SETELAH update.
