# Flowy Web-Bridge (GitHub Pages)

Веб-мост для перехвата ссылок из мессенджеров (Telegram, VK, WhatsApp) и соцсетей с автоматическим запуском Android-приложения Flowy через Deep Links (`flowy://track/{id}`) и Android Intent (`intent://track/{id}#Intent;scheme=flowy;package=ru.flowy.music;end;`).

---

## 🚀 Быстрый запуск и деплой

### Вариант 1: Автоматический деплой через скрипт (Linux / macOS / Git Bash)
```bash
cd web-bridge
chmod +x deploy_bridge.sh
./deploy_bridge.sh
```

### Вариант 2: Ручной деплой через Git (без GitHub CLI)
```bash
cd web-bridge
git init -b main
git remote add origin https://github.com/dihwn/flowy.git
git add index.html README.md
git commit -m "Deploy Flowy Web-Bridge"
git push -u origin main --force
```
После пуша перейдите в [GitHub Pages Settings](https://github.com/dihwn/flowy/settings/pages) и включите:
- **Source**: `Deploy from a branch`
- **Branch**: `main` / `root`
- Нажмите **Save**.

---

## 🔗 Тестирование ссылок
- Основной URL: `https://dihwn.github.io/flowy/`
- Ссылка на трек: `https://dihwn.github.io/flowy/?track=12345678`
