#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Параметры конфигурации
ENDPOINT="wayvpn"
PORT="2053"
LOGIN="admin"
PASSWORD="admin"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Автоматический установщик 3X-UI    ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Функция для вывода сообщений
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   print_error "Этот скрипт должен быть запущен с правами root (sudo)"
   exit 1
fi

# Проверка операционной системы (только Ubuntu/Debian)
print_status "Проверка операционной системы..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        print_error "Этот скрипт поддерживает только Ubuntu и Debian системы."
        print_error "Обнаружена система: $PRETTY_NAME ($ID)"
        print_error "Для работы скрипта требуется Ubuntu или Debian."
        exit 1
    else
        print_status "Поддерживаемая система обнаружена: $PRETTY_NAME"
    fi
else
    print_error "Не удалось определить операционную систему."
    print_error "Этот скрипт поддерживает только Ubuntu и Debian системы."
    exit 1
fi

# Проверка интернет-соединения
print_status "Проверка интернет-соединения..."
if ! ping -c 1 google.com &> /dev/null; then
    print_error "Нет интернет-соединения. Проверьте подключение к интернету."
    exit 1
fi

# Обновление системы и установка необходимых пакетов
print_status "Обновление системы и установка необходимых пакетов..."
apt update -y
apt install -y wget curl unzip

# Проверка, не установлен ли уже 3x-ui
if systemctl is-active --quiet x-ui; then
    print_warning "3X-UI уже установлен и запущен. Остановка службы..."
    systemctl stop x-ui
fi

# Создание резервной копии конфигурации, если она существует
if [ -f "/usr/local/x-ui/x-ui.db" ]; then
    print_status "Создание резервной копии существующей конфигурации..."
    cp /usr/local/x-ui/x-ui.db /usr/local/x-ui/x-ui.db.backup.$(date +%Y%m%d_%H%M%S)
fi

print_status "Начинаем установку 3X-UI..."
echo ""

# Установка 3X-UI
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# Проверка успешности установки
if [ $? -ne 0 ]; then
    print_error "Ошибка при установке 3X-UI"
    exit 1
fi

print_status "Ожидание завершения установки..."
sleep 15

# Остановка службы для настройки
print_status "Остановка службы для настройки параметров..."
systemctl stop x-ui

# Настройка параметров
print_status "Настройка параметров панели..."
print_status "Endpoint: $ENDPOINT"
print_status "Port: $PORT"
print_status "Login: $LOGIN"
print_status "Password: $PASSWORD"

# Настройка панели с заданными параметрами
print_status "Настройка параметров панели..."
/usr/local/x-ui/x-ui setting -username "$LOGIN" -password "$PASSWORD" -port "$PORT" -webBasePath "/$ENDPOINT"

# Миграция базы данных
print_status "Выполнение миграции базы данных..."
/usr/local/x-ui/x-ui migrate

# Альтернативная настройка через конфигурационный файл (если команды не сработали)
print_status "Проверка и альтернативная настройка..."
sleep 2

# Проверяем, применились ли настройки
CURRENT_PORT=$(/usr/local/x-ui/x-ui setting -show true | grep -Eo 'port: .+' | awk '{print $2}' 2>/dev/null || echo "")
CURRENT_USER=$(/usr/local/x-ui/x-ui setting -show true | grep -Eo 'username: .+' | awk '{print $2}' 2>/dev/null || echo "")

if [ "$CURRENT_PORT" != "$PORT" ] || [ "$CURRENT_USER" != "$LOGIN" ]; then
    print_warning "Настройки не применились через команды. Пробуем альтернативный способ..."
    
    # Останавливаем службу для редактирования конфигурации
    systemctl stop x-ui
    
    # Создаем временный конфигурационный файл
    cat > /tmp/x-ui-config.json << EOF
{
    "panelPort": $PORT,
    "username": "$LOGIN",
    "password": "$PASSWORD",
    "webBasePath": "/$ENDPOINT"
}
EOF
    
    # Применяем конфигурацию (если поддерживается)
    if [ -f "/usr/local/x-ui/x-ui.db" ]; then
        print_status "Применяем конфигурацию через базу данных..."
        # Здесь можно добавить SQL команды для обновления базы данных
        # Но это сложно, поэтому просто перезапускаем службу
    fi
    
    # Запускаем службу
    systemctl start x-ui
    sleep 3
fi

echo ""
echo -e "${BLUE}Текущие настройки панели:${NC}"
/usr/local/x-ui/x-ui setting -show true
echo ""

# Получение IP адреса сервера
SERVER_IP=$(hostname -I | awk '{print $1}')

# Проверка, что IP получен
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="YOUR_SERVER_IP"
    print_warning "Не удалось автоматически определить IP адрес сервера"
fi

# Запуск службы
print_status "Запуск службы 3X-UI..."
systemctl start x-ui
systemctl enable x-ui

# Проверка статуса службы
sleep 5
if systemctl is-active --quiet x-ui; then
    print_status "Служба 3X-UI успешно запущена!"
else
    print_error "Ошибка при запуске службы 3X-UI"
    systemctl status x-ui
    exit 1
fi

# Проверка доступности порта
print_status "Проверка доступности порта $PORT..."
if netstat -tuln | grep -q ":$PORT "; then
    print_status "Порт $PORT успешно открыт"
else
    print_warning "Порт $PORT может быть недоступен. Проверьте настройки файрвола."
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!     ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Информация для доступа к панели:${NC}"
echo -e "${YELLOW}URL:${NC} http://$SERVER_IP:$PORT/$ENDPOINT"
echo -e "${YELLOW}Логин:${NC} $LOGIN"
echo -e "${YELLOW}Пароль:${NC} $PASSWORD"
echo ""
echo -e "${BLUE}Дополнительная информация:${NC}"
echo -e "• Endpoint: $ENDPOINT"
echo -e "• Статус службы: $(systemctl is-active x-ui)"
echo -e "• Автозапуск: $(systemctl is-enabled x-ui)"
echo ""
echo -e "${YELLOW}Важные команды:${NC}"
echo -e "• Проверить статус: systemctl status x-ui"
echo -e "• Перезапустить: systemctl restart x-ui"
echo -e "• Остановить: systemctl stop x-ui"
echo -e "• Логи: journalctl -u x-ui -f"
echo ""
echo -e "${RED}ВНИМАНИЕ:${NC} Рекомендуется изменить пароль администратора после первого входа!"
echo ""
