# Сборка Luma через GitHub

## Быстрый вариант: проверить сборку

1. Создайте новый GitHub repository.
2. Загрузите **все файлы и папки из этой директории**, включая `.github`, `project.yml`, `MessengerApp` и `GoogleService-Info.plist`.
3. Откройте вкладку **Actions**.
4. Запустите workflow **iOS build** вручную через **Run workflow**.
5. После завершения скачайте artifact `luma-ios-simulator`.

Этот workflow проверяет, что приложение собирается на macOS, но simulator `.app` нельзя установить на обычный iPhone.

## Настоящий IPA для iPhone

Для IPA нужны Apple Developer signing certificate и provisioning profile. Не загружайте `.p12`, `.mobileprovision` или пароль в репозиторий. Используйте GitHub Actions Secrets или собирайте локально в Xcode.

На Mac:

```bash
brew install xcodegen
xcodegen generate
open Luma.xcodeproj
```

В Xcode:

1. Выберите target `Luma`.
2. Укажите свою Apple Developer Team.
3. Проверьте Bundle Identifier. Для текущего Firebase-файла используется `com.apple.flow`.
4. Включите `Push Notifications` и `Background Modes` при настройке APNs.
5. Выберите `Any iOS Device (arm64)`.
6. Выполните `Product > Archive`.
7. В Organizer выберите `Distribute App`.

## Firebase

В Firebase Console должны быть включены:

- Authentication → Email/Password;
- Firestore Database;
- Storage;
- Cloud Messaging для push.

`GoogleService-Info.plist` уже лежит в корне проекта и подключается как ресурс через `project.yml`. Если вы меняете Bundle Identifier, скачайте новый plist из Firebase Console.

## Что уже работает в приложении

- регистрация и вход через Firebase Authentication;
- сохранение Firebase-сессии;
- локальное сохранение чатов и сообщений;
- отправка текста;
- reply, реакции, редактирование и удаление;
- выбор фото, видео и файлов;
- профиль, уведомления и тёмная тема;
- поиск чатов и пользователей.

Синхронизация сообщений между разными аккаунтами, Firestore-правила, Storage upload и APNs требуют отдельного production-этапа с настройкой вашей Firebase-проектной схемы. Они не подменяются фиктивным локальным UI.
