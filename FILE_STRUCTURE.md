# Loyiha Fayl Tuzilmasi (File Structure)

Ushbu hujjat loyihaning fayl tuzilmasini va har bir papka qanday maqsadlarda ishlatilishini tushuntirib beradi. Loyiha **Clean Architecture** yoki **Feature-Based** (xususiyatlarga asoslangan) arxitektura tamoyillariga yaqinlashtirilgan bo'lib, GetX yordamida state management (holat boshqaruvi) amalga oshiriladi.

## Umumiy Tuzilma

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── services/
│   └── utils/
├── features/
│   └── recorder/
│       ├── controllers/
│       ├── models/
│       ├── views/
│       └── widgets/
└── l10n/
```

## Papkalar va Fayllar Tavsifi

### 1. Root Fayllar

*   **`lib/main.dart`**
    *   **Vazifasi:** Ilovaning kirish nuqtasi (Entry Point).
    *   **Logika:** `main()` funksiyasi shu yerda joylashadi. Kerakli xizmatlarni (Services) ishga tushirish (initialization) va `runApp` orqali ilovani start qilish shu yerda bajariladi.

*   **`lib/app.dart`**
    *   **Vazifasi:** Ilovaning asosiy vidjeti (Root Widget).
    *   **Logika:** `GetMaterialApp` shu yerda sozlanadi.
    *   **Nimalar kiradi:**
        *   Routing (sahifalar yo'nalishi).
        *   Theme (mavzular).
        *   Localization (til sozlamalari, `localizationsDelegates`).
        *   Initial Bindings (dastlabki bog'lanishlar).

### 2. Core (O'zak)
`core` papkasi butun ilova bo'ylab ishlatiladigan umumiy kodlarni o'z ichiga oladi. Bu yerdagi kodlar ma'lum bir feature (xususiyat)ga bog'liq bo'lmasligi kerak.

*   **`lib/core/services/`**
    *   **Vazifasi:** Ilova darajasidagi xizmatlar (Services). Masalan, fayl tizimi bilan ishlash, API chaqiriqlar, ma'lumotlar bazasi va h.k.
    *   **`recorder_service.dart`**: Ovoz yozish funksionalini bajaruvchi xizmat. Agar veb (Web) yoki mobil uchun farqli logika bo'lsa, shu yerda (masalan `kIsWeb` yordamida) ajratiladi.
    *   **`file_service.dart`**: Fayllarni saqlash, o'qish va yo'llarini (paths) aniqlash uchun yordamchi xizmat.

*   **`lib/core/utils/`**
    *   **Vazifasi:** Yordamchi funksiyalar (Helper functions).
    *   **`platform_utils.dart`**: Platformaga oid tekshiruvlar yoki kichik yordamchi funksiyalar.

### 3. Features (Xususiyatlar)
Har bir funksional modul alohida papkada saqlanadi. Hozirda bizda faqat `recorder` xususiyati mavjud.

*   **`lib/features/recorder/`** - Ovoz yozish va eshitish bilan bog'liq barcha narsalar shu yerda.

    *   **`controllers/` (State Management)**
        *   **`recorder_controller.dart`**: `GetxController` dan meros oladi.
        *   **Logika:** UI va Biznes logic o'rtasidagi ko'prik.
            *   Ovoz yozishni boshlash/to'xtatish buyruqlarini beradi (Service'ga murojaat qiladi).
            *   Taymerni boshqaradi.
            *   UI'dagi o'zgaruvchilarni (masalan: `isRecording`, `duration`) saqlaydi va yangilaydi (`.obs`).
            *   ViewModel rolini o'ynaydi.

    *   **`models/` (Data Models)**
        *   **`audio_file.dart`**: Ma'lumotlar tuzilmasi.
        *   **Logika:** Ovoz fayli haqidagi ma'lumotlarni saqlash uchun class (masalan: fayl nomi, davomiyligi, yaratilgan vaqti). Logic code yozilmaydi, faqat ma'lumotlar turlari (fields) va konstruktorlar bo'ladi.

    *   **`views/` (UI Pages)**
        *   **`recorder_page.dart`**: Foydalanuvchi ko'radigan to'liq ekran (Page).
        *   **Logika:** `Scaffold` shu yerda bo'ladi. Controllerdagi ma'lumotlarni ekranda ko'rsatadi (`Obx` yordamida). UI chizishdan boshqa murakkab logika bo'lmasligi kerak.

    *   **`widgets/` (Reusable Widgets)**
        *   Faqat ushbu feature ichida ishlatiladigan kichik UI elementlari.
        *   **`record_button.dart`**: Ovoz yozish tugmasi dizayni va animatsiyasi.
        *   **`audio_list_item.dart`**: Ro'yxatdagi bitta ovoz faylining ko'rinishi.

### 4. L10n (Localization)
Ilovani ko'p tilli qilish uchun resurslar.

*   **`lib/l10n/`**
    *   **`intl_en.arb`**: Ingliz tili uchun tarjimalar.
    *   **`intl_uz.arb`**: O'zbek tili uchun tarjimalar.
    *   **Logika:** Bu yerda kod yozilmaydi, faqat `{ "key": "value" }` formatidagi JSON'ga o'xshash ma'lumotlar saqlanadi. Flutter bu fayllardan avtomatik ravishda Dart kodlarini generatsiya qiladi.

---

### Xulosa: Qanday ishlash kerak?

1.  **Yangi Feature qo'shganda:** `features/` ichida yangi papka oching (masalan `features/settings/`) va ichida `controllers`, `views` kabi tuzilmani takrorlang.
2.  **Umumiy logika yozganda:** Agar logika faqat bitta featurega tegishli bo'lmasa, uni `core/video` yoki `core/utils` ga oling.
3.  **UI o'zgartirganda:** `views` yoki `widgets` papkasiga kiring.
4.  **Logika o'zgartirganda:** `controllers` ga kiring.
5.  **Ma'lumotlar bilan ishlashda (save/load):** `core/services` dagi service'lardan foydalaning, lekin ularni `Controller` orqali chaqiring. UI to'g'ridan-to'g'ri Service'ga murojaat qilmasligi maqsadga muvofiq.
