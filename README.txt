This is for building and decrypting a signal encrypted backup

Build the application:
./build.sh 

Run the Backup

Simple:
./decrypt_signal_backup.sh -p 123451234512345123451234512345
Assuming the backups are in ./signal_backups
and the output will be in ./signal_backups_decrypted/

or specify source and destination as you like:

./decrypt_signal_backup.sh -f /home/user/backups/Signal/signal-2021-01-15-12-34-12.backup -d $(pwd)/here -p 123451234512345123451234512345


Then you can process the output using tools like sqlite3 oder sqlitebrowser

Example:
sqlite3 ./signal_backups_decrypted/2021-01-16/signal_backup.db -csv <misc/query_chats.sql

The misc-folder contains an example query wich exports the chats, ordered by threads and date