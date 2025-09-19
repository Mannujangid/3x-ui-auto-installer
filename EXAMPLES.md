# 📚 Примеры использования 3X-UI Автоустановщика

## 🎯 Сценарии использования

### 1. Первичная установка на новый сервер

```bash
# Подключитесь к серверу по SSH
ssh root@your-server-ip

# Запустите автоустановщик
sudo bash <(curl -Ls https://raw.githubusercontent.com/Tsuev/3x-ui-auto-installer/main/3xui-intaller.sh)

# После установки откройте браузер
# http://your-server-ip:2053/wayvpn
# Логин: admin, Пароль: admin
```

### 2. Установка с проверкой логов

```bash
# Запуск с выводом логов в реальном времени
sudo bash <(curl -Ls https://raw.githubusercontent.com/Tsuev/3x-ui-auto-installer/main/3xui-intaller.sh) 2>&1 | tee install.log

# Просмотр логов установки
cat install.log
```

### 3. Установка на сервер с существующим 3X-UI

```bash
# Скрипт автоматически создаст резервную копию
sudo bash <(curl -Ls https://raw.githubusercontent.com/Tsuev/3x-ui-auto-installer/main/3xui-intaller.sh)

# Восстановление из резервной копии (если нужно)
sudo systemctl stop x-ui
sudo cp /usr/local/x-ui/x-ui.db.backup.20240101_120000 /usr/local/x-ui/x-ui.db
sudo systemctl start x-ui
```

## 🔧 Настройка после установки

### Изменение пароля администратора

```bash
# Через командную строку
x-ui setting -username admin -password new_secure_password

# Или через веб-интерфейс
# 1. Войдите в панель
# 2. Перейдите в "Настройки" → "Параметры панели"
# 3. Измените пароль
```

### Настройка файрвола

```bash
# Ubuntu/Debian с UFW
sudo ufw allow 2053/tcp
sudo ufw enable

# CentOS/RHEL с firewalld
sudo firewall-cmd --permanent --add-port=2053/tcp
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p tcp --dport 2053 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

### Настройка SSL сертификата

```bash
# Установка certbot
sudo apt install certbot

# Получение сертификата
sudo certbot certonly --standalone -d your-domain.com

# Настройка в 3X-UI панели
# 1. Войдите в панель
# 2. Перейдите в "Настройки" → "Параметры панели"
# 3. Включите SSL и укажите путь к сертификатам
```

## 📊 Мониторинг и обслуживание

### Проверка статуса системы

```bash
# Создайте скрипт для мониторинга
cat > /usr/local/bin/check-3xui.sh << 'EOF'
#!/bin/bash
echo "=== Статус 3X-UI ==="
systemctl status x-ui --no-pager
echo ""
echo "=== Использование портов ==="
netstat -tuln | grep 2053
echo ""
echo "=== Использование диска ==="
du -sh /usr/local/x-ui/
echo ""
echo "=== Последние логи ==="
journalctl -u x-ui -n 5 --no-pager
EOF

chmod +x /usr/local/bin/check-3xui.sh

# Запуск проверки
/usr/local/bin/check-3xui.sh
```

### Автоматическое резервное копирование

```bash
# Создайте скрипт резервного копирования
cat > /usr/local/bin/backup-3xui.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/3x-ui"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Создание резервной копии базы данных
cp /usr/local/x-ui/x-ui.db $BACKUP_DIR/x-ui_$DATE.db

# Удаление старых резервных копий (старше 30 дней)
find $BACKUP_DIR -name "x-ui_*.db" -mtime +30 -delete

echo "Резервная копия создана: $BACKUP_DIR/x-ui_$DATE.db"
EOF

chmod +x /usr/local/bin/backup-3xui.sh

# Добавьте в crontab для ежедневного резервного копирования
echo "0 2 * * * /usr/local/bin/backup-3xui.sh" | crontab -
```

### Настройка уведомлений

```bash
# Установка mailutils для отправки уведомлений
sudo apt install mailutils

# Создание скрипта уведомлений
cat > /usr/local/bin/notify-3xui.sh << 'EOF'
#!/bin/bash
if ! systemctl is-active --quiet x-ui; then
    echo "3X-UI служба остановлена!" | mail -s "3X-UI Alert" admin@yourdomain.com
    systemctl start x-ui
fi
EOF

chmod +x /usr/local/bin/notify-3xui.sh

# Добавьте в crontab для проверки каждые 5 минут
echo "*/5 * * * * /usr/local/bin/notify-3xui.sh" | crontab -
```

## 🚨 Устранение неполадок

### Проблема: Не удается подключиться к панели

```bash
# 1. Проверьте статус службы
systemctl status x-ui

# 2. Проверьте логи
journalctl -u x-ui -f

# 3. Проверьте порт
netstat -tuln | grep 2053

# 4. Проверьте файрвол
ufw status

# 5. Перезапустите службу
systemctl restart x-ui
```

### Проблема: Ошибка "Port already in use"

```bash
# Найдите процесс, использующий порт 2053
sudo lsof -i :2053

# Остановите процесс или измените порт
# Для изменения порта:
x-ui setting -port 2054
systemctl restart x-ui
```

### Проблема: Не удается войти в панель

```bash
# Сброс пароля через командную строку
x-ui setting -username admin -password admin

# Проверьте конфигурацию
cat /usr/local/x-ui/x-ui.db
```

## 🔄 Обновление и миграция

### Обновление до новой версии

```bash
# 1. Создайте резервную копию
/usr/local/bin/backup-3xui.sh

# 2. Остановите службу
systemctl stop x-ui

# 3. Запустите обновление
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# 4. Запустите службу
systemctl start x-ui

# 5. Проверьте статус
systemctl status x-ui
```

### Миграция на другой сервер

```bash
# На старом сервере
systemctl stop x-ui
tar -czf 3x-ui-backup.tar.gz /usr/local/x-ui/

# На новом сервере
sudo bash <(curl -Ls https://raw.githubusercontent.com/Tsuev/3x-ui-auto-installer/main/3xui-intaller.sh)
systemctl stop x-ui
tar -xzf 3x-ui-backup.tar.gz -C /
systemctl start x-ui
```

## 📈 Оптимизация производительности

### Настройка системных параметров

```bash
# Увеличение лимитов файлов
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# Оптимизация сетевых параметров
cat >> /etc/sysctl.conf << 'EOF'
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF

sysctl -p
```

### Мониторинг ресурсов

```bash
# Создание скрипта мониторинга
cat > /usr/local/bin/monitor-3xui.sh << 'EOF'
#!/bin/bash
echo "=== Использование CPU ==="
top -bn1 | grep "Cpu(s)"

echo "=== Использование памяти ==="
free -h

echo "=== Использование диска ==="
df -h /usr/local/x-ui/

echo "=== Активные соединения ==="
netstat -an | grep :2053 | wc -l
EOF

chmod +x /usr/local/bin/monitor-3xui.sh
```

---

💡 **Совет**: Регулярно создавайте резервные копии и мониторьте логи для предотвращения проблем!

🔗 **Ссылки**:
- [Основная документация](README.md)
- [Быстрый старт](QUICK_START.md)
- [Репозиторий на GitHub](https://github.com/Tsuev/3x-ui-auto-installer)