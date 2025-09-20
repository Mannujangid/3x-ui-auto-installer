# 3X-UI Автоматический Установщик by Tsuev

[![GitHub](https://img.shields.io/badge/GitHub-Tsuev%2F3x--ui--auto--installer-blue)](https://github.com/Tsuev/3x-ui-auto-installer)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash-orange)](https://www.gnu.org/software/bash/)

Автоматический скрипт для установки и настройки панели управления 3X-UI с предустановленными параметрами.

> **Репозиторий**: [https://github.com/Tsuev/3x-ui-auto-installer](https://github.com/Tsuev/3x-ui-auto-installer)

## 📋 Описание

Этот скрипт автоматически устанавливает и настраивает панель управления 3X-UI с следующими предустановленными параметрами:

- **Endpoint**: `wayvpn`
- **Port**: `2053`
- **Login**: `admin`
- **Password**: `admin`

## 🚀 Быстрый старт

### Предварительные требования

- **Операционная система**: Ubuntu или Debian (скрипт автоматически проверяет совместимость)
- **Права доступа**: Сервер с правами root (sudo)
- **Сеть**: Интернет-соединение
- **Файрвол**: Открытый порт 2053 в файрволе

> ⚠️ **Важно**: Этот скрипт работает **только** на Ubuntu и Debian системах. При запуске на других дистрибутивах Linux скрипт автоматически остановится с сообщением об ошибке.

### Установка

#### Способ 1: Прямая установка (рекомендуется)
```bash
curl -Ls https://raw.githubusercontent.com/Tsuev/3x-ui-auto-installer/main/3xui-installer.sh | sudo bash
```

#### Способ 2: Скачивание и запуск
```bash
# Скачать скрипт
wget https://raw.githubusercontent.com/Tsuev/3x-ui-auto-installer/main/3xui-intaller.sh

# Сделать исполняемым
chmod +x 3xui-intaller.sh

# Запустить установку
sudo ./3xui-intaller.sh
```

#### Способ 3: Клонирование репозитория
```bash
# Клонировать репозиторий
git clone https://github.com/Tsuev/3x-ui-auto-installer.git
cd 3x-ui-auto-installer

# Запустить установку
sudo ./3xui-intaller.sh
```

## ✨ Особенности

- 🚀 **Автоматическая установка** - Один скрипт для полной настройки
- ⚙️ **Предустановленные параметры** - Готовые настройки для быстрого старта
- 🔒 **Безопасность** - Проверки системы и резервное копирование
- 🎨 **Красивый интерфейс** - Цветной вывод с подробной информацией
- 🛠️ **Обработка ошибок** - Автоматическое восстановление при проблемах
- 📊 **Мониторинг** - Проверка статуса службы и портов

## 📖 Подробное описание

### Что делает скрипт

1. **Проверки системы:**
   - Проверяет права root
   - **Проверяет совместимость ОС** (только Ubuntu/Debian)
   - Проверяет интернет-соединение
   - Проверяет наличие уже установленного 3X-UI

2. **Подготовка системы:**
   - Обновляет список пакетов
   - Устанавливает необходимые зависимости (wget, curl, unzip)

3. **Установка 3X-UI:**
   - Скачивает и запускает официальный скрипт установки
   - Создает резервную копию существующей конфигурации (если есть)

4. **Настройка параметров:**
   - Устанавливает логин: `admin` (через `/usr/local/x-ui/x-ui setting -username`)
   - Устанавливает пароль: `admin` (через `/usr/local/x-ui/x-ui setting -password`)
   - Настраивает порт: `2053` (через `/usr/local/x-ui/x-ui setting -port`)
   - Настраивает endpoint: `wayvpn` (через `/usr/local/x-ui/x-ui setting -webBasePath`)
   - Выполняет миграцию базы данных
   - Проверяет примененные настройки

5. **Запуск и проверка:**
   - Запускает службу 3X-UI
   - Включает автозапуск
   - Проверяет статус службы
   - Проверяет доступность порта

### Выходные данные

После успешной установки скрипт выводит:

```
========================================
    УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!     
========================================

Информация для доступа к панели:
URL: http://YOUR_SERVER_IP:2053/wayvpn
Логин: admin
Пароль: admin

Дополнительная информация:
• Endpoint: wayvpn
• Статус службы: active
• Автозапуск: enabled
```

## 🔧 Управление службой

### Основные команды

```bash
# Проверить статус службы
systemctl status x-ui

# Перезапустить службу
systemctl restart x-ui

# Остановить службу
systemctl stop x-ui

# Запустить службу
systemctl start x-ui

# Отключить автозапуск
systemctl disable x-ui

# Включить автозапуск
systemctl enable x-ui
```

### Просмотр логов

```bash
# Просмотр логов в реальном времени
journalctl -u x-ui -f

# Просмотр последних логов
journalctl -u x-ui -n 50

# Просмотр логов за определенный период
journalctl -u x-ui --since "2024-01-01" --until "2024-01-02"
```

## 🔒 Безопасность

### Рекомендации после установки

1. **Измените пароль администратора:**
   - Войдите в панель управления
   - Перейдите в настройки
   - Измените пароль на более сложный

2. **Настройте файрвол:**
```bash
# Разрешить только необходимые порты
ufw allow 2053/tcp
ufw enable
```

3. **Ограничьте доступ по IP (опционально):**
```bash
# Разрешить доступ только с определенных IP
ufw allow from YOUR_IP to any port 2053
```

## 🛠️ Устранение неполадок

### Частые проблемы

#### 1. Ошибка "Этот скрипт поддерживает только Ubuntu и Debian системы"
```bash
# Скрипт автоматически проверяет операционную систему
# Если вы видите эту ошибку, значит ваша система не поддерживается

# Поддерживаемые системы:
# - Ubuntu (все версии)
# - Debian (все версии)

# Неподдерживаемые системы:
# - CentOS/RHEL/Fedora
# - Arch Linux
# - openSUSE
# - Alpine Linux
# - Другие дистрибутивы

# Решение: Используйте Ubuntu или Debian сервер
```

#### 2. Ошибка "Permission denied"
```bash
# Убедитесь, что запускаете с правами root
sudo ./3xui-intaller.sh
```

#### 2. Порт 2053 недоступен
```bash
# Проверьте, не занят ли порт
netstat -tuln | grep 2053

# Проверьте настройки файрвола
ufw status
```

#### 3. Служба не запускается
```bash
# Проверьте логи службы
journalctl -u x-ui -n 50

# Проверьте конфигурацию
x-ui status
```

#### 4. Не удается подключиться к панели
```bash
# Проверьте IP адрес сервера
hostname -I

# Проверьте доступность порта
telnet YOUR_SERVER_IP 2053
```

#### 5. Неправильные настройки (логин, пароль, порт, endpoint)
```bash
# Проверьте текущие настройки
/usr/local/x-ui/x-ui setting -show true

# Измените настройки вручную
/usr/local/x-ui/x-ui setting -username admin -password admin -port 2053 -webBasePath /wayvpn

# Выполните миграцию
/usr/local/x-ui/x-ui migrate

# Перезапустите службу
systemctl restart x-ui
```

### Восстановление из резервной копии

Если что-то пошло не так, можно восстановить конфигурацию:

```bash
# Остановить службу
systemctl stop x-ui

# Восстановить из резервной копии
cp /usr/local/x-ui/x-ui.db.backup.YYYYMMDD_HHMMSS /usr/local/x-ui/x-ui.db

# Запустить службу
systemctl start x-ui
```

## 📁 Структура файлов

После установки файлы 3X-UI будут расположены в:

```
/usr/local/x-ui/
├── x-ui                    # Исполняемый файл
├── x-ui.db                 # База данных конфигурации
├── x-ui.db.backup.*        # Резервные копии
└── bin/                    # Дополнительные файлы
```

## 🔄 Обновление

Для обновления 3X-UI до последней версии:

```bash
# Остановить службу
systemctl stop x-ui

# Запустить официальный скрипт обновления
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# Запустить службу
systemctl start x-ui
```

## 📞 Поддержка

### Полезные ссылки

- 🔗 [Этот репозиторий](https://github.com/Tsuev/3x-ui-auto-installer) - Автоустановщик 3X-UI
- 🔗 [Официальный репозиторий 3X-UI](https://github.com/mhsanaei/3x-ui) - Исходный проект
- 🔗 [Документация 3X-UI](https://github.com/mhsanaei/3x-ui/wiki) - Официальная документация

### Получение помощи

Если у вас возникли проблемы:

1. 📋 **Проверьте логи службы**: `journalctl -u x-ui -f`
2. 🔌 **Убедитесь, что порт 2053 открыт** в файрволе
3. 🔐 **Проверьте права доступа** к файлам
4. 📚 **Обратитесь к документации** 3X-UI
5. 🐛 **Создайте Issue** в этом репозитории, если проблема связана с автоустановщиком

### Сообщить об ошибке

Если вы нашли ошибку в автоустановщике:

1. Перейдите в [Issues](https://github.com/Tsuev/3x-ui-auto-installer/issues)
2. Создайте новый Issue
3. Опишите проблему и приложите логи

## 📝 Лицензия

Этот проект распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для подробностей.

```
MIT License

Copyright (c) 2024 Tsuev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие этого проекта! Вот как вы можете помочь:

### Как внести вклад

1. 🍴 **Создайте форк** репозитория
2. 🌿 **Создайте ветку** для ваших изменений (`git checkout -b feature/amazing-feature`)
3. 💾 **Сохраните изменения** (`git commit -m 'Add some amazing feature'`)
4. 📤 **Отправьте в ветку** (`git push origin feature/amazing-feature`)
5. 🔄 **Создайте Pull Request**

### Типы вкладов

- 🐛 **Исправление ошибок**
- ✨ **Новые функции**
- 📚 **Улучшение документации**
- 🎨 **Улучшение интерфейса**
- ⚡ **Оптимизация производительности**

### Правила

- Следуйте существующему стилю кода
- Добавляйте комментарии к новому коду
- Обновляйте документацию при необходимости
- Тестируйте изменения перед отправкой PR

---

**Внимание**: После установки обязательно измените пароль администратора для обеспечения безопасности!
