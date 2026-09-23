#!/usr/bin/env bash

# ==============================================================================
# Flowy Web-Bridge Deploy Script (dihwn/flowy -> GitHub Pages)
# ==============================================================================
# Данный скрипт автоматически развертывает веб-мост для deep-линков Flowy.
# Результат: доступность страницы по адресу https://dihwn.github.io/flowy/
# ==============================================================================

set -e

# Цвета для вывода в терминал
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REPO_OWNER="dihwn"
REPO_NAME="flowy"
REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
REMOTE_URL="https://github.com/${REPO_FULL}.git"
BRANCH="main"

echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}   🚀 РАЗВЕРТЫВАНИЕ ВЕБ-МОСТА FLOWY НА GITHUB PAGES   ${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "Целевой репозиторий: ${YELLOW}${REPO_FULL}${NC}"
echo -e "Будущий URL моста:  ${GREEN}https://${REPO_OWNER}.github.io/${REPO_NAME}/${NC}\n"

# 1. Проверка наличия Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Ошибка: Git не установлен. Пожалуйста, установите git.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git обнаружен.${NC}"

# 2. Проверка наличия GitHub CLI (gh)
HAS_GH=true
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) не найден в системе.${NC}"
    HAS_GH=false
else
    echo -e "${GREEN}✓ GitHub CLI (gh) обнаружен.${NC}"
    # Проверка авторизации в gh
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub CLI не авторизован. Выполните 'gh auth login' или используйте Git токен.${NC}"
        HAS_GH=false
    else
        echo -e "${GREEN}✓ Авторизация GitHub CLI активна.${NC}"
    fi
fi

# 3. Подготовка рабочей директории и файлов
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ Файл index.html не найден в текущей директории ($SCRIPT_DIR).${NC}"
    exit 1
fi

echo -e "\n${BLUE}📦 Инициализация Git-репозитория...${NC}"
if [ ! -d ".git" ]; then
    git init -b "$BRANCH"
else
    git checkout -B "$BRANCH"
fi

# Настройка remote origin
if git remote | grep -q "^origin$"; then
    git remote set-url origin "$REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
fi
echo -e "${GREEN}✓ Remote origin настроен на ${REMOTE_URL}${NC}"

# 4. Создание коммита
echo -e "\n${BLUE}📝 Подготовка коммита...${NC}"
git add index.html
if [ -f "README.md" ]; then
    git add README.md
fi

git commit -m "Deploy Flowy Web-Bridge for Deep Links handling" || {
    echo -e "${YELLOW}ℹ️  Нет изменений для коммита или коммит уже создан.${NC}"
}

# 5. Проверка существования репозитория на GitHub и Push
echo -e "\n${BLUE}🌐 Синхронизация с GitHub...${NC}"

if [ "$HAS_GH" = true ]; then
    # Проверяем, существует ли репозиторий на GitHub
    if gh repo view "$REPO_FULL" &> /dev/null; then
        echo -e "${GREEN}✓ Репозиторий ${REPO_FULL} существует на GitHub. Выполняем push...${NC}"
        git push -u origin "$BRANCH" --force
    else
        echo -e "${YELLOW}⚡ Репозиторий ${REPO_FULL} не найден на GitHub. Создаем публичный репозиторий...${NC}"
        gh repo create "$REPO_FULL" --public --source=. --remote=origin --push
    fi

    # 6. Включение GitHub Pages через GitHub CLI / API
    echo -e "\n${BLUE}⚙️  Настройка и активация GitHub Pages...${NC}"
    
    # Пытаемся создать страницу через API
    PAGE_CREATE_RES=$(gh api -X POST "repos/${REPO_FULL}/pages" \
        -f build_type="legacy" \
        -f source="{\"branch\":\"${BRANCH}\",\"path\":\"/\"}" 2>&1 || true)

    if echo "$PAGE_CREATE_RES" | grep -q "already exists"; then
        echo -e "${GREEN}✓ GitHub Pages уже активирован для данного репозитория.${NC}"
        # Обновляем источник на случай, если ветка была другой
        gh api -X PUT "repos/${REPO_FULL}/pages" \
            -f build_type="legacy" \
            -f source="{\"branch\":\"${BRANCH}\",\"path\":\"/\"}" &> /dev/null || true
    else
        echo -e "${GREEN}✓ Запрос на создание GitHub Pages успешно отправлен!${NC}"
    fi

else
    # Сценарий без GitHub CLI: стандартный git push
    echo -e "${YELLOW}ℹ️  Используем прямой Git push...${NC}"
    git push -u origin "$BRANCH" --force || {
        echo -e "${RED}❌ Не удалось отправить коммит в репозиторий.${NC}"
        echo -e "${YELLOW}Убедитесь, что репозиторий https://github.com/${REPO_FULL} создан на GitHub и у вас есть права доступа.${NC}"
        exit 1
    }

    echo -e "\n${YELLOW}⚠️  GitHub CLI не был доступен для автоматического включения Pages.${NC}"
    echo -e "Пожалуйста, включите GitHub Pages вручную в браузере:"
    echo -e "1. Перейдите в: ${CYAN}https://github.com/${REPO_FULL}/settings/pages${NC}"
    echo -e "2. В разделе 'Build and deployment' -> 'Source' выберите: ${YELLOW}Deploy from a branch${NC}"
    echo -e "3. В поле 'Branch' выберите: ${YELLOW}${BRANCH}${NC} и папку ${YELLOW}/ (root)${NC}"
    echo -e "4. Нажмите ${GREEN}Save${NC}."
fi

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}   ✨ ВЕБ-МОСТ УСПЕШНО РАЗВЕРНУТ!                     ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Публичный URL моста: ${CYAN}https://${REPO_OWNER}.github.io/${REPO_NAME}/?track={id}${NC}"
echo -e "Проверить статус деплоя: ${YELLOW}https://github.com/${REPO_FULL}/actions${NC}"
echo -e "Обычно активация Pages занимает от 30 до 90 секунд.\n"
