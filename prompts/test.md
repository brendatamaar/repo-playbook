Tes instalasi repo-playbook di project ini. READ-ONLY: jangan mengubah, membuat, atau meng-commit file apa pun.

1. Sebutkan provider dan model yang sedang kamu jalankan.
2. Deteksi skill otomatis: sebutkan skill yang termuat untukmu TANPA membuka folder apa pun. Lalu cek folder `.agents/skills/` dan `.claude/skills/`.
   Bandingkan dengan daftar ini: phase-setup-new, phase-setup-existing, phase-start, phase-resume, phase-status, phase-routing.
3. Instruksi project: tanpa membuka file, kutip satu aturan dari bagian "Workflow per fase" di AGENTS.md (untuk Claude, termuat lewat CLAUDE.md). Jika tidak bisa, nyatakan bahwa AGENTS.md tidak termuat otomatis.
4. Jalankan skill phase-status. Jika belum ada `docs/PLAN.md`, hasil yang benar adalah laporan bahwa project belum di-setup.
5. Routing (tanpa delegate): baca `.agents/playbook/routing.md`, lalu sebutkan kandidat review silang jika penulis kodenya adalah kamu.
6. Hasil dalam tabel `cek | lulus/gagal | catatan`, untuk cek 2-5.
   - Cek 2 dan 3 dianggap lulus jika skill atau aturan termuat otomatis.
   - Jika tidak termuat otomatis tetapi file-nya ada, tandai "lulus via file". Workflow tetap berjalan karena AGENTS.md menunjuk ke `.agents/skills/`.

Tutup dengan 1 baris: perlu tindakan atau tidak, dan apa tindakannya.
