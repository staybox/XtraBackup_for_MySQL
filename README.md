# XtraBackup_for_MySQL

Скрипт XtraBackup.sh выполняет полный и инкрементальный бэкап.

Как использовать?

1. Выполнить команду crontab -e
2. Вставить 0 * * * * /path/to/XtraBackup.sh incremental (или 0 * * * * /path/to/XtraBackup.sh full)


Скрипт XtraRestore.sh выполняет полное и инкрементальное восстновление

Как использовать?

1. Выполнить команду crontab -e
2. Восстановить /path/to/XtraRestore.sh /path/to/full_backup /path/to/incremental_backup


У всех скрипт должно быть право на выполнение (chmod +x /path/to/XtraRestore.sh)


