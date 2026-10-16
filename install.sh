#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# VPN PANEL — Bootstrap Installer
# Приватный репо: https://github.com/zotac85/vpn-panel
# ═══════════════════════════════════════════════════════════════
set -e
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запусти от root: sudo -i"
    exit 1
fi

clear
echo -e "\033[0;36m══════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  ⚡  VPN PANEL — УСТАНОВЩИК  ⚡\033[0m"
echo -e "\033[0;36m══════════════════════════════════════════════\033[0m"
echo ""

# ─── Проверка зависимостей ───
if ! command -v git >/dev/null 2>&1; then
    echo -e "\033[0;33m📦 Устанавливаем git...\033[0m"
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq git >/dev/null 2>&1
fi

# ─── Токен ───
TOKEN_FILE="/root/.vpn-panel.token"
GITHUB_TOKEN=""

if [ -f "$TOKEN_FILE" ]; then
    GITHUB_TOKEN=$(cat "$TOKEN_FILE" | tr -d ' \n\r')
    echo -e "\033[0;32m✅ Найден сохранённый токен\033[0m"
else
    echo -e "\033[0;33m🔑 Введи токен доступа к репозиторию\033[0m"
    echo -e "\033[0;90m(получи у @ArsenGuro)\033[0m"
    echo ""
    read -p "Токен: " GITHUB_TOKEN
    GITHUB_TOKEN=$(echo "$GITHUB_TOKEN" | tr -d ' \n\r')
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "\033[0;31m❌ Токен не может быть пустым\033[0m"
        exit 1
    fi
    echo "$GITHUB_TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo -e "\033[0;32m✅ Токен сохранён в $TOKEN_FILE\033[0m"
fi

echo ""

# ─── Клонируем приватный репо ───
SRC_DIR="/tmp/vpn-panel-src-$$"
[ -d "$SRC_DIR" ] && rm -rf "$SRC_DIR"

echo -e "\033[0;36m📦 Загрузка VPN Panel...\033[0m"
if ! git clone --depth 1 "https://${GITHUB_TOKEN}@github.com/zotac85/vpn-panel.git" "$SRC_DIR" >/dev/null 2>&1; then
    echo -e "\033[0;31m❌ Не удалось загрузить репозиторий\033[0m"
    echo -e "\033[0;33mПроверь:\033[0m"
    echo -e "  • Токен корректный и не истёк"
    echo -e "  • Есть доступ к репозиторию"
    echo -e "  • Интернет на сервере работает"
    rm -rf "$SRC_DIR" 2>/dev/null
    exit 1
fi
rm -rf "$SRC_DIR/.git"
echo -e "\033[0;32m✅ Загружено\033[0m"
echo ""

# ─── Запускаем основной установщик ───
cd "$SRC_DIR"
bash "$SRC_DIR/install.sh"

# ─── Чистим временный клон ───
[ -d "$SRC_DIR" ] && rm -rf "$SRC_DIR" 2>/dev/null || true
