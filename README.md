#Script Instalasi dan Uninstalasi WordPress

Tersedia dua script Bash untuk memudahkan proses instalasi dan uninstalasi WordPress di server berbasis Linux. Script-script ini dirancang untuk menyederhanakan dan mengotomatisasi pengelolaan instalasi WordPress dengan mengatur server Apache, database MariaDB/MySQL, serta konfigurasi file WordPress.

1. wp_install.sh - Script Instalasi WordPress
   
Deskripsi:
Script ini digunakan untuk menginstal WordPress di server Linux, mengonfigurasi database MariaDB, serta mengatur server Apache untuk menjalankan WordPress. Script ini juga akan mengunduh dan mengekstrak file WordPress, mengatur izin file yang tepat, serta mengonfigurasi virtual host Apache agar WordPress dapat diakses melalui server.

Penggunaan:

Copy kedua script ke server Anda.
Buka terminal, lalu buat dan edit file wp_install.sh menggunakan perintah:
bash
Salin
Edit
nano wp_install.sh
Tambahkan kode script yang sudah disiapkan ke dalam file wp_install.sh.
Beri izin eksekusi pada script dengan menjalankan perintah:
bash
Salin
Edit
chmod +x wp_install.sh
Jalankan script untuk mulai menginstal WordPress:
bash
Salin
Edit
./wp_install.sh
2. wp_uninstall.sh - Script Uninstalasi WordPress
Deskripsi:
Script ini digunakan untuk menghapus seluruh instalasi WordPress dari server, termasuk menghapus database, file instalasi, serta konfigurasi virtual host Apache. Script ini juga akan menghapus aturan firewall untuk HTTP dan HTTPS serta mengembalikan konfigurasi default Apache setelah penghapusan WordPress.

Penggunaan:

Copy kedua script ke server Anda.
Buka terminal, lalu buat dan edit file wp_uninstall.sh menggunakan perintah:
bash
Salin
Edit
nano wp_uninstall.sh
Tambahkan kode script yang sudah disiapkan ke dalam file wp_uninstall.sh.
Beri izin eksekusi pada script dengan menjalankan perintah:
bash
Salin
Edit
chmod +x wp_uninstall.sh
Jalankan script untuk menghapus WordPress:
bash
Salin
Edit
./wp_uninstall.sh
