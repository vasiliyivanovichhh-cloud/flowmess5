# Luma Messenger

Конфигурация для автоматической генерации Xcode-проекта находится в [project.yml](./project.yml), а инструкция загрузки и сборки через GitHub — в [GITHUB_BUILD.md](./GITHUB_BUILD.md).

Нативный iOS-мессенджер на SwiftUI. В проекте есть локально работающие регистрация/вход с валидацией, сохранение сессии, чаты, поиск пользователей по имени и `@username`, аватары, статусы онлайн, непрочитанные сообщения, профиль, тёмная тема, настройки уведомлений, отправка текста, reply, emoji-реакции, редактирование, удаление и выбор фото/видео/файла через системный picker. Сообщения и состояние сохраняются в `UserDefaults` и не исчезают после перезапуска.

## Текущая граница

Без Firebase-проекта приложение работает как локальный single-device клиент: данные не синхронизируются между пользователями, а push-уведомления не отправляются. Это намеренно не маскируется фиктивным real-time. Следующий production-этап — заменить методы `AppSession` на Firebase Auth/Firestore/Storage и добавить FCM/APNs.

## Сборка настоящей версии

Для полноценной серверной работы подключите Firebase:

1. На Mac установите Xcode 16+ и создайте iOS App с bundle ID вроде `app.luma.messenger`.
2. Добавьте в проект файлы из папки `MessengerApp`.
3. В Firebase Console включите Authentication (Email/Password), Firestore и Storage.
4. Скачайте `GoogleService-Info.plist` и добавьте его в Xcode-проект.
5. Добавьте Firebase SDK через Swift Package Manager: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseMessaging`.
6. В проект уже добавлена инициализация `FirebaseApp.configure()` и реальные вызовы Firebase Authentication для регистрации, входа и выхода.
7. Добавьте APNs key в Apple Developer и Firebase Cloud Messaging для push-уведомлений.

## IPA

IPA требует macOS, Xcode и Apple Developer signing certificate. На Windows этот файл нельзя корректно собрать и подписать. На Mac откройте проект в Xcode, выберите Team, затем `Product > Archive > Distribute App`. Для установки на физический iPhone нужен Developer Mode и действующий профиль подписи.
