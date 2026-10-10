# 🖼️ Установщик расширений для изображений и видео

![GitHub Release](https://img.shields.io/github/v/release/frostbittenbull/Image-and-Video-Extensions?style=flat-square&color=success)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/frostbittenbull/Image-and-Video-Extensions/release.yml?style=flat-square&label=Auto-Update)
![Update Frequency](https://img.shields.io/badge/Updates-Daily-blue?style=flat-square)

Простой установщик кодеков для современных форматов изображений и видео на Windows 10/11.

> [!TIP]
> Репозиторий автоматически проверяет наличие новых версий расширений в Microsoft Store каждые 24 часа. Если выходит обновление — создается новый релиз.

| Расширение | Формат | Минимальная | Средняя | Максимальная |
|-----------|--------|:-----------:|:-------:|:------------:|
| [HEIF Image Extension](https://apps.microsoft.com/detail/9pmmsr1cgpwg) | `.heic` / `.heif` / `.hif` | ✅ | ✅ | ✅ |
| [WEBP Image Extension](https://apps.microsoft.com/detail/9pg2dk419drg) | `.webp` | ✅ | ✅ | ✅ |
| [AV1 Video Extension](https://apps.microsoft.com/detail/9mvzqvxjbq9v) | `.avif` / `.av1` | | ✅ | ✅ |
| [JPEG XL Image Extension](https://apps.microsoft.com/detail/9mzprth5c0tb) | `.jxl` | | ✅ | ✅ |
| [Raw Image Extension](https://apps.microsoft.com/detail/9nctdw2w1bh8) | `.3fr` / `.arw` / `.cr2` / `.cr3` /<br>`.crw` / `.dng` / `.iiq` / `.nef` /<br>`.nrw` / `.orf` / `.pef` / `.raf` /<br>`.raw` / `.rw2` / `.rwl` / `.rwz` /<br>`.sr2` / `.srf` и др. | | ✅ | ✅ |
| [HEVC Video Extension](https://apps.microsoft.com/detail/9nmzlz57r3t7) | `.h265` / `.hevc` | | | ✅ |
| [MPEG2 Video Extension](https://apps.microsoft.com/detail/9n95q1zzpmh4) | `.mpg` / `.mpg2` / `.mpeg` /<br>`.mpeg2` / `.m2ts` / `.m2v` / `.ts` | | | ✅ |
| [VP9 Video Extensions](https://apps.microsoft.com/detail/9n4d0msmp0pt) | `.vp9` / `.webm` | | | ✅ |
| [Web Media Extensions](https://apps.microsoft.com/detail/9n5tdp8vcmhs) | `.oga` / `.ogg` / `.ogv` | | | ✅ |

> [!NOTE]
> Raw Image Extension предназначен для форматов фотоаппаратов производителей Canon, Nikon, Sony, Fujifilm, Panasonic, Olympus, Pentax, Leica и других.
> 
> Кроме готовых наборов, в установщике есть вариант **«На выбор»**: можно отметить любые расширения из списка (кроме Dolby Audio Extensions и AVC Encoder Video Extension, у них отдельные пункты меню). Подробности в разделах [Установка на выбор](#-установка-на-выбор) и [Отдельные расширения](#-отдельные-расширения).

Отдельные расширения (не входят в наборы `1`–`3`, ставятся своими пунктами меню):

| Расширение | Назначение | Пункт меню |
|-----------|------------|:----------:|
| [Dolby Audio Extensions](https://www.free-codecs.com/dolby-audio-extensions_download.htm) | Декодер звука Dolby Digital (`.ac3`) и Dolby Digital Plus (`.eac3`) | `5` |
| [AVC Encoder Video Extension](https://apps.microsoft.com/detail/9pb0trcnrhfx) | Кодировщик видео H.264 (AVC) | `6` |

> [!NOTE]
> Начиная с Windows 10 LTSC 2019 версии 1809 и обновления Windows 11 версии 24H2, компания Microsoft убрала встроенный системный декодер AC-3 по умолчанию. Расширение Dolby Audio Extensions возвращает поддержку данного кодека в стандартные плееры и приложения Windows, которые используют системные библиотеки.
> 
> Расширение AVC Encoder Video Extension позволяет приложениям в Windows 11 кодировать видео в формат AVC (H.264) видеокодирования. Расширение использует API кодирования DirectX 12, если это возможно, с использованием аппаратных возможностей на более новых устройствах.

| Операционная система | RAW 2.4.x.x<br>Web Media 1.2.x.x<br>Dolby Audio | Web Media 2.x.x.x | RAW 2.5.x.x | JPEG XL<br>AVC Encoder |
|---|:---:|:---:|:---:|:---:|
| Windows 10 1809+ (≥ 17763) | ✅ | ❌ | ❌ | ❌ |
| Windows 11 21H2+ (≥ 22000) | ✅ | ✅ | ❌ | ❌ |
| Windows 11 22H2+ (≥ 22621) | ✅ | ✅ | ✅ | ❌ |
| Windows 11 24H2+ (≥ 26100) | ✅ | ✅ | ✅ | ✅ |

> [!WARNING]
> Актуальные версии "RAW Image Extension" (начиная с 2.5.x.x) на Windows 10 не устанавливаются — Add-AppxPackage завершается ошибкой `0x80073CFD` ("не удалось выполнить необходимое условие для установки"), так как пакет требует ОС версии 10.0.22621.0 (Windows 11 22H2) и выше. Поэтому на всех системах ставится резервная версия из ветки `2.4.x.x` (она тоже обновляется автоматически), а более новая — только на Windows 11 22H2 и новее.
>
> Актуальные версии "Web Media Extensions" (начиная с 2.x.x.x) на Windows 10 не устанавливаются — Add-AppxPackage завершается ошибкой `0x80080204` ("ошибка проверки манифеста, `0xC00CE015`"), так как манифест использует более новую схему, которую понимает только Windows 11. Поэтому на всех системах ставится резервная версия из ветки `1.2.x.x` (она тоже обновляется автоматически), а более новая версия дополнительно устанавливается только на Windows 11.
>
> Кодек "JPEG XL Image Extension" на Windows 10 не устанавливается — Add-AppxPackage завершается ошибкой `0x80073CFD` ("не удалось выполнить необходимое условие для установки"), так как пакет требует ОС версии 10.0.26100.0 (Windows 11 24H2) и выше. Поэтому установщик ставит его только на Windows 11 24H2 и новее.
>
> Расширение "AVC Encoder Video Extension" (версии 1.1.21.0 и 1.1.47.0) на Windows 10 не устанавливается — Add-AppxPackage завершается ошибкой `0x80073CFD` ("не удалось выполнить необходимое условие для установки"), так как пакет требует ОС версии 10.0.26100.0 (Windows 11 24H2) и выше. Поэтому установщик ставит его только на Windows 11 24H2 и новее. В репозитории хранится только самая новая версия.

## 🚀 Использование

1. Перейдите в раздел [Releases](https://github.com/frostbittenbull/Image-and-Video-Extensions/releases/latest) и скачайте архив `Image and Video Extensions.zip`
2. Распакуйте архив
3. Запустите `Install.bat` **от имени администратора**
4. Выберите нужный вариант установки:
   - `1` — Минимальная установка (4 основных расширения изображений)
   - `2` — Средняя установка (все расширения изображений)
   - `3` — Максимальная установка (все расширения изображений и видео)
   - `4` — На выбор (вы сами выбираете нужные расширения из списка)
   - `5` — Установка Dolby Audio Extensions (декодер звука `.ac3` и `.eac3`)
   - `6` — Установка AVC Encoder Video Extension (кодирование видео H.264, только Windows 11 24H2 и новее)

## 🎯 Установка на выбор

Пункт `4` показывает список расширений из папки `Extensions` (без `Microsoft_VCLibs`, а также без Dolby Audio Extensions и AVC Encoder Video Extension, у которых отдельные пункты меню), которые подходят вашей версии Windows. Для каждого расширения в списке одна версия, та, что будет установлена именно на вашей системе. JPEG XL появляется в списке только на Windows 11 24H2 и новее.

Введите номера нужных расширений (например: `1578`) и нажмите Enter. Пустой ввод возвращает в меню. Сначала автоматически ставится `Microsoft VCLibs`, затем выбранные расширения.

Пример списка для Windows 10:

```text
1 - AV1 Video Extension 2.0.35.0
2 - HEIF Image Extension 1.2.57.0
3 - HEVC Video Extension 2.4.110.0
4 - MPEG2 Video Extension 1.2.32.0
5 - RAW Image Extension 2.4.43.0
6 - VP9 Video Extensions 1.2.20.0
7 - WEB Media Extensions 1.2.29.0
8 - WEBP Image Extension 1.2.31.0
```

На Windows 11 список отличается версиями: Web Media Extensions 2.x.x.x с билда 22000, RAW Image Extension 2.5.x.x с билда 22621, а с билда 26100 добавляется JPEG XL Image Extension.

## 🧩 Отдельные расширения

Пункты `5` и `6` ставят расширения, которые не входят в наборы `1`–`3` и не показываются в варианте «На выбор». Перед каждым из них автоматически ставится `Microsoft VCLibs`.

- `5` — **Dolby Audio Extensions**: декодер звука Dolby Digital (`.ac3`) и Dolby Digital Plus (`.eac3`). Версия закреплена (`1.0.61521.0`) и автоматически не обновляется, файл просто лежит в архиве.
- `6` — **AVC Encoder Video Extension**: кодировщик видео H.264 (AVC) для приложений, которые записывают видео через системный кодек. Работает только на Windows 11 24H2 и новее, на более старых системах установщик покажет строку `Пропущено`. Обновляется автоматически.

## 🧾 Вывод установщика

Для каждого расширения установщик показывает результат отдельной строкой:

- 🟢 `Установлено` — пакет успешно установлен (или такая же/более новая версия уже есть в системе).
- 🟡 `Пропущено` — пакет не подходит по версии Windows и не устанавливался. Это не ошибка. Такие строки появляются в готовых наборах (`1`, `2`, `3`) и при установке AVC Encoder Video Extension (пункт `6`) на устаревшей Windows, а в режиме «На выбор» неподходящие версии просто не попадают в список.
- 🔴 `Ошибка` — установка не удалась, рядом указан код ошибки.

Пометка `(Установлено вместо …)` означает, что новая версия пакета не подошла по версии Windows (строка `Пропущено` выше), и вместо неё поставлена резервная версия (ветка `2.4.x.x` для RAW или `1.2.x.x` для Web Media).

Пример для Windows 10 22H2 (максимальная установка):

```text
Установлено: Microsoft VCLibs 140.00 14.0.33519.0
Установлено: AV1 Video Extension 2.0.35.0
Установлено: HEIF Image Extension 1.2.57.0
Установлено: HEVC Video Extension 2.4.110.0
Пропущено: JPEG XL Image Extension 1.2.50.0 (Ваша версия Windows устарела, требуется минимум Windows 11 24H2 26100)
Установлено: MPEG2 Video Extension 1.2.32.0
Пропущено: RAW Image Extension 2.5.42.0 (Ваша версия Windows устарела, требуется минимум Windows 11 22H2 22621)
Установлено: RAW Image Extension 2.4.43.0 (Установлено вместо 2.5.42.0)
Установлено: VP9 Video Extensions 1.2.20.0
Пропущено: WEB Media Extensions 2.1.51.0 (Ваша версия Windows устарела, требуется минимум Windows 11 21H2 22000)
Установлено: WEB Media Extensions 1.2.29.0 (Установлено вместо 2.1.51.0)
Установлено: WEBP Image Extension 1.2.31.0
```

## 📁 Структура проекта

<!-- TREE_START -->
```text
Image and Video Extensions/
├── Install.bat
└── Extensions/
    ├── AV1_Video_Extension_2.0.35.0.AppxBundle
    ├── AVC_Encoder_Video_Extension_1.1.47.0.AppxBundle
    ├── Dolby_Audio_Extensions_1.0.61521.0.Appx
    ├── HEIF_Image_Extension_1.2.62.0.AppxBundle
    ├── HEVC_Video_Extension_2.4.151.0.AppxBundle
    ├── JPEG_XL_Image_Extension_1.2.50.0.AppxBundle
    ├── MPEG2_Video_Extension_1.2.32.0.AppxBundle
    ├── Microsoft_VCLibs_140.00_14.0.33519.0.Appx
    ├── RAW_Image_Extension_2.4.43.0.AppxBundle
    ├── RAW_Image_Extension_2.5.42.0.AppxBundle
    ├── VP9_Video_Extensions_1.2.20.0.AppxBundle
    ├── WEBP_Image_Extension_1.2.31.0.AppxBundle
    ├── WEB_Media_Extensions_1.2.42.0.AppxBundle
    └── WEB_Media_Extensions_2.1.51.0.AppxBundle
```
<!-- TREE_END -->

## ⚙️ Требования

- Windows 10 или Windows 11
- PowerShell (встроен в Windows)
- Права администратора

---
*Developed by [#frostbittenbull](https://github.com/frostbittenbull)*

От кофеёчка я бы не отказался 😁:<br>
[![Donate](https://img.shields.io/badge/Donate-Boosty-F55123?logo=ko-fi)](https://boosty.to/prodbyinstinct/donate)
