#!/bin/bash

# Настройки
BACKUP_DIR="/path/to/backup"  # Укажите путь к каталогу с резервными копиями
MYSQL_USER="your_user"          # Укажите имя пользователя MySQL
MYSQL_PASSWORD="your_password"  # Укажите пароль пользователя MySQL

# Функция для восстановления полного бэкапа
restore_full_backup() {
    FULL_BACKUP_DIR="$1"
    echo "Восстановление полного бэкапа из: $FULL_BACKUP_DIR"
    
    xtrabackup --copy-back --target-dir="$FULL_BACKUP_DIR"
    chown -R mysql:mysql /var/lib/mysql
}

# Функция для восстановления инкрементального бэкапа
restore_incremental_backup() {
    INCREMENTAL_BACKUP_DIR="$1"
    BASE_BACKUP_DIR="$2"
    echo "Применение инкрементального бэкапа из: $INCREMENTAL_BACKUP_DIR"

    xtrabackup --apply-log --target-dir="$INCREMENTAL_BACKUP_DIR" --incremental-dir="$BASE_BACKUP_DIR"
}

# Основная логика
if [ $# -lt 2 ]; then
    echo "Использование: $0 <full_backup_dir> <incremental_backup_dir>"
    exit 1
fi

FULL_BACKUP_DIR="$1"
INCREMENTAL_BACKUP_DIR="$2"

# Остановка MySQL-сервера
echo "Остановка MySQL-сервера..."
sudo systemctl stop mysql

# Восстановление полного бэкапа
restore_full_backup "$FULL_BACKUP_DIR"

# Восстановление инкрементального бэкапа
restore_incremental_backup "$INCREMENTAL_BACKUP_DIR" "$FULL_BACKUP_DIR"

# Запуск MySQL-сервера
echo "Запуск MySQL-сервера..."
sudo systemctl start mysql

echo "Восстановление завершено."

