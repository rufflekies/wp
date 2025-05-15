<h1> Script Instalasi dan Uninstalasi WordPress </h1>
   Tersedia dua script Bash untuk memudahkan proses instalasi dan uninstalasi WordPress di server berbasis Linux. Script-script ini dirancang untuk menyederhanakan dan mengotomatisasi pengelolaan instalasi WordPress dengan mengatur server Apache, database MariaDB/MySQL, serta konfigurasi file WordPress.
<h2> 1. wp_install.sh - Script Instalasi WordPress</h2>
Deskripsi:
Script ini digunakan untuk menginstal WordPress di server Linux, mengonfigurasi database MariaDB, serta mengatur server Apache untuk menjalankan WordPress. Script ini juga akan mengunduh dan mengekstrak file WordPress, mengatur izin file yang tepat, serta mengonfigurasi virtual host Apache agar WordPress dapat diakses melalui server.
<h3>Penggunaan:</h3>

1. Copy script ke clipboard Anda

2. Buka cli, lalu buat dan edit file wp_install.sh menggunakan perintah:
           
       nano wp_install.sh
3. Tambahkan kode script yang sudah disiapkan ke dalam file wp_install.sh.
4. Beri izin eksekusi pada script dengan menjalankan perintah:

       chmod +x wp_install.sh
5. Jalankan script untuk mulai menginstal WordPress:

       ./wp_install.sh
<h2> 2. wp_uninstall.sh - Script Uninstalasi WordPress</h2>
Deskripsi:
Script ini digunakan untuk menghapus seluruh instalasi WordPress dari server, termasuk menghapus database, file instalasi, serta konfigurasi virtual host Apache. Script ini juga akan menghapus aturan firewall untuk HTTP dan HTTPS serta mengembalikan konfigurasi default Apache setelah penghapusan WordPress.
<h3>Penggunaan:</h3>

1. Copy script ke clipboard Anda

2. Buka cli, lalu buat dan edit file wp_uninstall.sh menggunakan perintah:
           
       nano wp_uninstall.sh
3. Tambahkan kode script yang sudah disiapkan ke dalam file wp_uninstall.sh.
4. Beri izin eksekusi pada script dengan menjalankan perintah:

       chmod +x wp_uninstall.sh
5. Jalankan script untuk mulai menginstal WordPress:

       ./wp_uninstall.sh
