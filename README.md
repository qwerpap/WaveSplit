# 🎵 Wave Split

Кроссплатформенное мобильное приложение для разделения музыкальных композиций на составляющие дорожки с использованием глубокого обучения.

## 🚀 Возможности

- **Загрузка аудиофайлов**: Поддержка различных форматов
- **Два режима разделения**:
  - **2 Stems**: Вокал + Аккомпанемент
  - **4 Stems**: Вокал + Барабаны + Бас + Другие инструменты
- **Воспроизведение результатов**: Прослушивание каждого stem отдельно
- **Контроль громкости**: Индивидуальная настройка громкости для каждого stem
- **История треков**: Просмотр ранее обработанных файлов
- **Современный UI**: Красивый и интуитивный интерфейс

## 🛠 Технологии

- **Flutter 3.x**: Кроссплатформенная разработка
- **Dart**: Язык программирования
- **BLoC Pattern**: Управление состоянием
- **Go Router**: Навигация
- **Dio**: HTTP клиент
- **AudioPlayers**: Воспроизведение аудио
- **File Picker**: Выбор файлов
- **Get It**: Dependency Injection

## 📱 Поддерживаемые платформы

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (Ubuntu 18.04+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

## 🏗 Архитектура

Приложение построено с использованием Clean Architecture и BLoC pattern:

```
lib/
├── core/                    # Основные компоненты
│   ├── bloc/               # Глобальные BLoC провайдеры
│   ├── navigation/         # Система навигации
│   ├── services/           # Сервисы (логирование)
│   ├── shared/             # Общие виджеты
│   └── theme/              # Тема приложения
├── constants/              # Константы
├── features/               # Функциональные модули
│   ├── home/              # Главная страница
│   ├── separation/        # Разделение аудио
│   ├── history/           # История треков
│   └── profile/           # Профиль пользователя
└── main.dart              # Точка входа
```

### Модуль Separation

```
separation/
├── data/                   # Слой данных
│   ├── datasources/       # Источники данных (API)
│   ├── models/            # Модели данных
│   └── repositories/      # Реализация репозиториев
├── domain/                # Бизнес-логика
│   └── repositories/      # Интерфейсы репозиториев
└── presentation/          # UI слой
    ├── bloc/              # BLoC для управления состоянием
    ├── models/            # UI модели
    ├── view/              # Экраны
    └── widgets/           # UI компоненты
```

## 🚀 Установка и запуск

### Предварительные требования

1. **Flutter SDK** (3.0+)
2. **Dart SDK** (3.0+)
3. **Android Studio** / **Xcode** (для мобильной разработки)
4. **Запущенный бэкенд** на http://localhost:8000

### Установка

1. **Клонируйте репозиторий**
   ```bash
   git clone <repository-url>
   cd wave_split
   ```

2. **Установите зависимости**
   ```bash
   flutter pub get
   ```

3. **Настройте API URL** (если нужно)
   ```bash
   # Для локальной разработки (по умолчанию)
   flutter run --dart-define=API_BASE_URL=http://localhost:8000
   
   # Для Android эмулятора
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
   
   # Для iOS симулятора с IP хоста
   flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000
   ```

4. **Запустите приложение**
   ```bash
   # Для разработки
   flutter run
   
   # Для конкретной платформы
   flutter run -d chrome        # Web
   flutter run -d macos         # macOS
   flutter run -d windows       # Windows
   flutter run -d linux         # Linux
   ```

## 🔧 Конфигурация

### API Constants

Измените `lib/constants/api_constants.dart` для настройки базового URL:

```dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL', 
    defaultValue: 'http://localhost:8000'
  );
}
```

### Поддерживаемые форматы файлов

Приложение поддерживает загрузку следующих аудиоформатов:
- MP3
- WAV  
- FLAC
- M4A
- OGG
- AAC

## 🎨 UI/UX

### Главный экран

- **Upload Track**: Загрузка аудиофайла
- **Separation Mode**: Выбор режима разделения (2 или 4 stems)
- **Recent Tracks**: История обработанных треков

### Экран результатов

- **Track Info**: Информация о треке
- **Separated Tracks**: Список разделенных дорожек
- **Audio Player**: Воспроизведение с контролем громкости
- **Play/Pause**: Управление воспроизведением

### Цветовая схема

- **Primary**: Синий (#007AFF)
- **Background**: Светло-серый (#F8F9FA)
- **Cards**: Белый (#FFFFFF)
- **Text**: Темно-серый (#1C1C1E)

## 🧪 Тестирование

### Запуск тестов

```bash
# Все тесты
flutter test

# Тесты с покрытием
flutter test --coverage

# Интеграционные тесты
flutter drive --target=test_driver/app.dart
```

### Тестирование на устройствах

```bash
# Список подключенных устройств
flutter devices

# Запуск на конкретном устройстве
flutter run -d <device-id>
```

## 📦 Сборка для продакшена

### Android

```bash
# APK
flutter build apk --release

# App Bundle (рекомендуется для Google Play)
flutter build appbundle --release
```

### iOS

```bash
# iOS приложение
flutter build ios --release

# Для App Store
flutter build ipa --release
```

### Desktop

```bash
# macOS
flutter build macos --release

# Windows  
flutter build windows --release

# Linux
flutter build linux --release
```

### Web

```bash
# Web приложение
flutter build web --release
```

## 🔍 Отладка

### Логирование

Приложение использует Talker для логирования:

```dart
// Доступ к логам через секретный жест
// Тапните 7 раз по логотипу или "Recent Tracks"
```

### Диагностика

```bash
# Информация о Flutter
flutter doctor

# Анализ производительности
flutter analyze

# Проверка зависимостей
flutter pub deps
```

## 🚨 Известные проблемы

1. **Web CORS**: Убедитесь, что бэкенд настроен для CORS
2. **iOS Permissions**: Добавьте разрешения для микрофона в Info.plist
3. **Android Network**: Добавьте `android:usesCleartextTraffic="true"` для HTTP

## 🤝 Вклад в проект

1. Fork проекта
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Создайте Pull Request

## 📝 Лицензия

MIT License

## 📞 Поддержка

Если у вас есть вопросы или проблемы:

1. Проверьте [Issues](../../issues)
2. Создайте новый Issue с подробным описанием
3. Приложите логи и скриншоты