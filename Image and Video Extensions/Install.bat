cls
@echo off
chcp 1251 >nul
title Установка расширений для изображений и видео
cd /d "%~dp0"

for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "esc=%%b"
set "red=%esc%[91m"
set "green=%esc%[92m"
set "reset=%esc%[0m"

fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%Ошибка: Пожалуйста, запустите данный BAT-файл от имени Администратора.%reset%
    pause
    exit /b
)

if not exist "Extensions" (
    echo.
    echo %red%Ошибка: Папка "Extensions" не найдена!%reset%
    echo %red%Пожалуйста, убедитесь, что папка%reset% %green%"Extensions"%reset% %red%находится в той же директории, что и этот скрипт.%reset%
    echo.
    pause
    exit
)

:Menu
cls

set "win_ver=10"
for /f "tokens=2 delims==" %%I in ('wmic os get buildnumber /value') do set "build=%%I"
if %build% GEQ 22000 set "win_ver=11"
if %build% GEQ 26100 set "win_ver=11_24h2"

echo.
echo 1. В минимальную установку входят: .heic, .heif, и .webp
echo 2. В среднюю установку входят: .heic, .heif, .webp, .avif, .av1, .jxl, .raw, .arw, .cr2 и .nef
echo 3. В максимальную установку входят: .heic, .heif, .webp, .avif, .av1, .jxl, .raw, .arw, .cr2, .nef, .h265, .hevc, .mpg, .mpeg, .mpg2, .mpeg2, .m2v, .vp9, .webm .oga, .ogg и .ogv
echo.
echo 1 - Минимальная установка (3 основных расширения изображений)
echo 2 - Средняя установка (все расширения изображений)
echo 3 - Максимальная установка (все расширения изображений и видео)
echo.
echo 9 - О программе
echo 0 - Выход
echo.

choice /c 12390 /n /m "Выберите пункт: "
if errorlevel 5 goto eof
if errorlevel 4 goto About
if errorlevel 3 (
    cls
    echo.
    echo Выполняется максимальная установка расширений для изображений и видео…
    powershell -NoProfile -Command ^
        "Get-ChildItem 'Extensions\Microsoft_VCLibs_140.00*.Appx'                      | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\AV1_Video_Extension_*.AppxBundle'                   | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\HEIF_Image_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\HEVC_Video_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\MPEG2_Video_Extension_*.AppxBundle'                 | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Add-AppxPackage -Path 'Extensions\RAW_Image_Extension_2.4.24.0.AppxBundle';" ^
        "Get-ChildItem 'Extensions\VP9_Video_Extensions_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Add-AppxPackage -Path 'Extensions\WEB_Media_Extensions_1.2.29.0.AppxBundle';" ^
        "Get-ChildItem 'Extensions\WEBP_Image_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    if "%win_ver%"=="11" (
        powershell -NoProfile -Command ^
            "Get-ChildItem 'Extensions\RAW_Image_Extension_*.AppxBundle'               | Where-Object { $_.Name -notmatch '2\.4\.9\.0' } | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
            "Get-ChildItem 'Extensions\WEB_Media_Extensions_*.AppxBundle'              | Where-Object { $_.Name -notmatch '1\.2\.29\.0' } | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    )
    if "%win_ver%"=="11_24h2" (
        powershell -NoProfile -Command ^
            "Get-ChildItem 'Extensions\RAW_Image_Extension_*.AppxBundle'               | Where-Object { $_.Name -notmatch '2\.4\.9\.0' } | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
            "Get-ChildItem 'Extensions\WEB_Media_Extensions_*.AppxBundle'              | Where-Object { $_.Name -notmatch '1\.2\.29\.0' } | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
            "Get-ChildItem 'Extensions\JPEG_XL_Image_Extension_*.AppxBundle'           | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    )
    echo.
    echo Готово!
    echo.
    pause
    goto Menu
)
if errorlevel 2 (
    cls
    echo.
    echo Выполняется средняя установка расширений для изображений…
    powershell -NoProfile -Command ^
        "Get-ChildItem 'Extensions\Microsoft_VCLibs_140.00*.Appx'                      | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\AV1_Video_Extension_*.AppxBundle'                   | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\HEIF_Image_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Add-AppxPackage -Path 'Extensions\RAW_Image_Extension_2.4.24.0.AppxBundle';" ^
        "Get-ChildItem 'Extensions\WEBP_Image_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    if "%win_ver%"=="11" (
        powershell -NoProfile -Command ^
            "Get-ChildItem 'Extensions\RAW_Image_Extension_*.AppxBundle'               | Where-Object { $_.Name -notmatch '2\.4\.9\.0' } | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    )
    if "%win_ver%"=="11_24h2" (
        powershell -NoProfile -Command ^
            "Get-ChildItem 'Extensions\RAW_Image_Extension_*.AppxBundle'               | Where-Object { $_.Name -notmatch '2\.4\.9\.0' } | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
            "Get-ChildItem 'Extensions\JPEG_XL_Image_Extension_*.AppxBundle'           | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    )
    echo.
    echo Готово!
    echo.
    pause
    goto Menu
)
if errorlevel 1 (
    cls
    echo.
    echo Выполняется минимальная установка расширений для изображений…
    powershell -NoProfile -Command ^
        "Get-ChildItem 'Extensions\Microsoft_VCLibs_140.00*.Appx'                      | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\HEIF_Image_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName };" ^
        "Get-ChildItem 'Extensions\WEBP_Image_Extension_*.AppxBundle'                  | Select-Object -First 1 | ForEach-Object { Add-AppxPackage -Path $_.FullName }" 2>nul
    echo.
    echo Готово!
    echo.
    pause
    goto Menu
)
goto Menu

:About
cls
echo.
echo Этот установщик предназначен для лёгкой установки кодеков для современных форматов изображений и видео.
echo Вы можете выбрать минимальную или максимальную установку.
echo Минимальная установка включает 3 основных расширения: .heic, .heif и .webp
echo Средняя установка включает все расширения изображений: .heic, .heif, .webp, .avif, .av1, .jxl, .raw, .arw, .cr2 и .nef
echo Максимальная установка — полный набор всех расширений: .heic, .heif, .webp, .avif, .av1, .jxl, .raw, .arw, .cr2, .nef, .h265, .hevc, .mpg, .mpeg, .mpg2, .mpeg2, .m2v, .vp9, .webm .oga, .ogg и .ogv
echo Платформа: Windows 10/11
echo.
echo Нажмите любую клавишу, чтобы вернуться…
pause >nul
goto Menu

:eof
exit