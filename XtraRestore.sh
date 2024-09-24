#!/bin/bash

# Настройки
BACKUP_DIR="/path/to/backup"  # Укажите путь к каталогу с резервными копиями
MYSQL_USER="your_user"        # Укажите имя пользователя MySQL
MYSQL_PASSWORD="your_password"  # Укажите пароль пользователя MySQL

# Функция для подготовки полного бэкапа
prepare_full_backup() {
    FULL_BACKUP_DIR="$1"
    echo "Подготовка полного бэкапа из: $FULL_BACKUP_DIR"

    # Применение изменений и подготовка полного бэкапа
    xtrabackup --prepare --target-dir="$FULL_BACKUP_DIR"
}

# Функция для применения инкрементального бэкапа
apply_incremental_backup() {
    INCREMENTAL_BACKUP_DIR="$1"
    BASE_BACKUP_DIR="$2"
    echo "Применение инкрементального бэкапа из: $INCREMENTAL_BACKUP_DIR к $BASE_BACKUP_DIR"

    # Применение инкрементального бэкапа к полному бэкапу
    xtrabackup --prepare --target-dir="$BASE_BACKUP_DIR" --incremental-dir="$INCREMENTAL_BACKUP_DIR"
}

# Функция для копирования подготовленных файлов в MySQL
restore_backup() {
    BACKUP_DIR="$1"
    echo "Копирование файлов бэкапа в каталог данных MySQL"

    # Копирование файлов бэкапа
    xtrabackup --copy-back --target-dir="$BACKUP_DIR"
    chown -R mysql:mysql /var/lib/mysql
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

# Подготовка полного бэкапа
prepare_full_backup "$FULL_BACKUP_DIR"

# Применение инкрементальных бэкапов (при наличии)
if [ -d "$INCREMENTAL_BACKUP_DIR" ]; then
    echo "Применение инкрементальных бэкапов..."
    apply_incremental_backup "$INCREMENTAL_BACKUP_DIR" "$FULL_BACKUP_DIR"
else
    echo "Инкрементальный бэкап не найден, пропускаем этот шаг."
fi

# Окончательная подготовка полного бэкапа
echo "Окончательная подготовка полного бэкапа..."
xtrabackup --prepare --target-dir="$FULL_BACKUP_DIR"

# Копирование подготовленного бэкапа в каталог данных MySQL
restore_backup "$FULL_BACKUP_DIR"

# Запуск MySQL-сервера
echo "Запуск MySQL-сервера..."
sudo systemctl start mysql

echo "Восстановление завершено."

