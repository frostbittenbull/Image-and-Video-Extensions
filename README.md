# 🖼️ Установщик расширений для изображений и видео

![GitHub Release](https://img.shields.io/github/v/release/frostbittenbull/Image-and-Video-Extensions?style=flat-square&color=success)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/frostbittenbull/Image-and-Video-Extensions/release.yml?style=flat-square&label=Auto-Update)
![Update Frequency](https://img.shields.io/badge/Updates-Daily-blue?style=flat-square)

Простой установщик кодеков для современных форматов изображений и видео на Windows 10/11.

> [!TIP]
> Репозиторий автоматически проверяет наличие новых версий расширений в Microsoft Store каждые 24 часа. Если выходит обновление — создается новый релиз.

| Расширение | Формат | Минимальная | Средняя | Максимальная |
|-----------|--------|:-----------:|:-------:|:------------:|
| [HEIF Image Extension](https://apps.microsoft.com/detail/9pmmsr1cgpwg) | `.heic` / `.heif` | ✅ | ✅ | ✅ |
| [WEBP Image Extension](https://apps.microsoft.com/detail/9pg2dk419drg) | `.webp` | ✅ | ✅ | ✅ |
| [AV1 Video Extension](https://apps.microsoft.com/detail/9mvzqvxjbq9v) | `.avif` / `.av1` | | ✅ | ✅ |
| [JPEG XL Image Extension](https://apps.microsoft.com/detail/9mzprth5c0tb) | `.jxl` | | ✅ | ✅ |
| [Raw Image Extension](https://apps.microsoft.com/detail/9nctdw2w1bh8) | `.raw` / `.arw` / `.cr2` / `.nef` и др. | | ✅ | ✅ |
| [HEVC Video Extension](https://apps.microsoft.com/detail/9nmzlz57r3t7) | `.h265` / `.hevc` | | | ✅ |
| [MPEG2 Video Extension](https://apps.microsoft.com/detail/9n95q1zzpmh4) | `.mpg` / `.mpeg` / `.mpg2` / `.mpeg2` / `.m2v` | | | ✅ |
| [VP9 Video Extensions](https://apps.microsoft.com/detail/9n4d0msmp0pt) | `.vp9` / `.webm` | | | ✅ |
| [Web Media Extensions](https://apps.microsoft.com/detail/9n5tdp8vcmhs) | `.oga` / `.ogg` / `.ogv` | | | ✅ |

## 🚀 Использование

1. Перейдите в раздел [Releases](https://github.com/frostbittenbull/Image-and-Video-Extensions/releases/latest) и скачайте архив `Image and Video Extensions.zip`
2. Распакуйте архив
3. Запустите `Install.bat` **от имени администратора**
4. Выберите нужный вариант установки:
   - `1` — Минимальная установка (3 основных расширения изображений)
   - `2` — Средняя установка (все расширения изображений)
   - `3` — Максимальная установка (все расширения изображений и видео)

## 📁 Структура проекта

<!-- TREE_START -->
```text
Image and Video Extensions/
├── Install.bat
└── Extensions/
    ├── Microsoft_VCLibs_140.00_14.0.33519.0.Appx
    ├── AV1_Video_Extension_2.0.7.0.AppxBundle
    ├── HEIF_Image_Extension_1.2.30.0.AppxBundle
    ├── HEVC_Video_Extension_2.4.47.0.AppxBundle
    ├── JPEG_XL_Image_Extension_1.2.38.0.AppxBundle
    ├── MPEG2_Video_Extension_1.2.13.0.AppxBundle
    ├── RAW_Image_Extension_2.5.7.0.AppxBundle
    ├── VP9_Video_Extensions_1.2.13.0.AppxBundle
    ├── WEB_Media_Extensions_2.1.26.0.AppxBundle
    └── WEBP_Image_Extension_1.2.14.0.AppxBundle
```
<!-- TREE_END -->

## ⚙️ Требования

- Windows 10 или Windows 11
- PowerShell (встроен в Windows)
- Права администратора

---
*Developed by [#frostbittenbull](https://github.com/frostbittenbull)*
