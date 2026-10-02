@echo off
::if not "%~1"=="max" start "" /max conhost.exe "%~f0" max & exit /b
cls
chcp 1251 >nul
title Установка расширений для изображений и видео
cd /d "%~dp0"

for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "esc=%%b"
set "red=%esc%[91m"
set "green=%esc%[92m"
set "yellow=%esc%[93m"
set "grey=%esc%[90m"
set "reset=%esc%[0m"

set "psf=$global:e=0; $b=[int]$env:build; function Ins($f,$sfx=''){ $n=$f.BaseName -replace '_',' '; try { Add-AppxPackage -Path $f.FullName -ErrorAction Stop; Write-Host ('Установлено: ' + $n + $sfx) -ForegroundColor Green } catch { if($_.Exception.Message -match 'HRESULT:\s*0x([0-9A-Fa-f]{8})'){ $c='0x'+$matches[1].ToUpper() } else { $c='0x{0:X8}' -f $_.Exception.HResult }; if($c -eq '0x80073D06' -or $c -eq '0x80073CFB'){ Write-Host ('Уже установлено: ' + $n + $sfx) -ForegroundColor Green } else { Write-Host ('Ошибка ' + $c + ': ' + $n) -ForegroundColor Red; $global:e++ } } }; function Inst($md,$m,$mn=0,$ex='',$why='',$opt=$false){ if($md -notlike ('*'+$env:mode+'*')){ return }; $f=Get-ChildItem $m -ErrorAction SilentlyContinue | Where-Object { !$ex -or $_.Name -notmatch $ex } | Sort-Object { try{ [version]($_.BaseName -replace '^.*_(\d+(\.\d+)+)$','$1') }catch{ [version]'0.0' } } -Descending | Select-Object -First 1; if(!$f){ if(!$opt){ Write-Host ('Не найден файл: ' + $m) -ForegroundColor Red; $global:e++ }; return }; if($b -lt $mn){ Write-Host ('Пропущено: ' + ($f.BaseName -replace '_',' ') + ' (Ваша версия Windows устарела, требуется минимум ' + $why + ')') -ForegroundColor Yellow; return }; Ins $f }; function Pair($md,$pm,$nm,$mn,$ex,$why){ if($md -notlike ('*'+$env:mode+'*')){ return }; $p=Get-ChildItem $pm -ErrorAction SilentlyContinue | Select-Object -First 1; $f=Get-ChildItem $nm -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch $ex } | Sort-Object { try{ [version]($_.BaseName -replace '^.*_(\d+(\.\d+)+)$','$1') }catch{ [version]'0.0' } } -Descending | Select-Object -First 1; $sk=[bool]($f -and $b -lt $mn); if($sk){ Write-Host ('Пропущено: ' + ($f.BaseName -replace '_',' ') + ' (Ваша версия Windows устарела, требуется минимум ' + $why + ')') -ForegroundColor Yellow }; if($p){ $s=''; if($sk){ $s=' (Установлено вместо ' + ($f.BaseName -replace '^.*_(\d+(\.\d+)+)$','$1') + ')' }; Ins $p $s } else { Write-Host ('Не найден файл: ' + $pm) -ForegroundColor Red; $global:e++ }; if($f -and !$sk){ Ins $f } }; function Sel(){ $pin=@{RAW_Image_Extension=@('2.4.36.0',22621);WEB_Media_Extensions=@('1.2.29.0',22000)}; $min=@{JPEG_XL_Image_Extension=26100}; $r=@(); foreach($g in (Get-ChildItem 'Extensions\*.Appx*' | Where-Object { $_.Name -notlike 'Microsoft_VCLibs_140.00*' -and $_.Name -notlike 'Dolby_Audio_Extensions_*' -and $_.Name -notlike 'AVC_Encoder_Video_Extension_*' } | Group-Object { $_.BaseName -replace '_\d+(\.\d+)+$','' } | Sort-Object Name)){ $k=$g.Name; if($min[$k] -and $b -lt $min[$k]){ continue }; $s=@($g.Group | Sort-Object { try{ [version]($_.BaseName -replace '^.*_(\d+(\.\d+)+)$','$1') }catch{ [version]'0.0' } } -Descending); $f=$s[0]; if($pin[$k] -and $b -lt $pin[$k][1]){ $f=$s | Where-Object { $_.BaseName -like ('*_' + $pin[$k][0]) } | Select-Object -First 1; if(!$f){ continue } }; $r+=$f }; return $r };"

fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%Ошибка: Пожалуйста, запустите данный BAT-файл от имени Администратора.%reset%
    pause
    exit /b
)

if not exist "Extensions" (
    echo.
    echo %red%Ошибка: Папка "Extensions" не найдена!
    echo Пожалуйста, убедитесь, что папка%reset% %green%"Extensions"%reset% %red%находится в той же директории, что и этот скрипт.%reset%
    echo.
    pause
    exit
)

for /f "tokens=3" %%I in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') do set "build=%%I"

:Menu
cls

echo.
echo %green%1 - Минимальная установка (4 основных расширения изображений)
echo 2 - Средняя установка (все расширения изображений)
echo 3 - Максимальная установка (все расширения изображений и видео)%reset%
echo %yellow%4 - На выбор (выборочно установить нужные расширения)
echo.
echo 5 - Установка Dolby Audio Extensions (.ac3, .eac3)
echo 6 - Установка AVC Encoder Video Extension (кодирование H.264)%reset%
echo.
echo %grey%9 - О программе
echo 0 - Выход%reset%
echo.

choice /c 12345690 /n /m "Выберите пункт: "
if errorlevel 8 goto eof
if errorlevel 7 goto About
if errorlevel 6 (
    cls
    echo.
    echo Выполняется установка AVC Encoder Video Extension…
    echo.
    set "mode=a"
    call :InstallAvc
    call :Result
    pause
    goto Menu
)
if errorlevel 5 (
    cls
    echo.
    echo Выполняется установка Dolby Audio Extensions…
    echo.
    set "mode=d"
    call :InstallDolby
    call :Result
    pause
    goto Menu
)
if errorlevel 4 goto Custom
if errorlevel 3 (
    cls
    echo.
    echo Выполняется максимальная установка расширений для изображений и видео…
    echo.
    set "mode=3"
    call :Install
    call :Result
    pause
    goto Menu
)
if errorlevel 2 (
    cls
    echo.
    echo Выполняется средняя установка расширений для изображений…
    echo.
    set "mode=2"
    call :Install
    call :Result
    pause
    goto Menu
)
if errorlevel 1 (
    cls
    echo.
    echo Выполняется минимальная установка расширений для изображений…
    echo.
    set "mode=1"
    call :Install
    call :Result
    pause
    goto Menu
)
goto Menu

:Custom
cls
echo.
powershell -NoProfile -Command ^
    "%psf%" ^
    "$L=@(Sel); if(!$L.Count){ Write-Host 'Подходящие файлы в папке Extensions не найдены' -ForegroundColor Red; exit 1 }; $i=1; foreach($f in $L){ Write-Host ('{0} - {1}' -f $i, ($f.BaseName -replace '_',' ')); $i++ }; exit 0"
if errorlevel 1 (
    echo.
    pause
    goto Menu
)
echo.
echo %grey%Введите номера (например: 1578) и нажмите Enter чтобы продолжить…
echo Пустой ввод - возврат в меню.%reset%
echo.
set "sel="
set /p "sel=> "
if not defined sel goto Menu
cls
echo.
echo Выполняется установка выбранных расширений…
echo.
set "mode=4"
set "fail="
powershell -NoProfile -Command ^
    "%psf%" ^
    "$L=@(Sel); $rx=if($L.Count -le 9){'\d'}else{'\d+'}; $k=@([regex]::Matches($env:sel,$rx) | ForEach-Object { [int]$_.Value } | Where-Object { $_ -ge 1 -and $_ -le $L.Count } | Select-Object -Unique | Sort-Object); if(!$k.Count){ Write-Host 'Не выбрано ни одного расширения' -ForegroundColor Yellow; exit 100 };" ^
    "Inst '4' 'Extensions\Microsoft_VCLibs_140.00*.Appx';" ^
    "foreach($i in $k){ Ins $L[$i-1] };" ^
    "exit $global:e"
if errorlevel 100 (
    echo.
    pause
    goto Menu
)
if errorlevel 1 set "fail=1"
call :Result
pause
goto Menu

:Install
set "fail="
powershell -NoProfile -Command ^
    "%psf%" ^
    "Inst '123' 'Extensions\Microsoft_VCLibs_140.00*.Appx';" ^
    "Inst '23' 'Extensions\AV1_Video_Extension_*.AppxBundle';" ^
    "Inst '123' 'Extensions\HEIF_Image_Extension_*.AppxBundle';" ^
    "Inst '3' 'Extensions\HEVC_Video_Extension_*.AppxBundle';" ^
    "Inst '23' 'Extensions\JPEG_XL_Image_Extension_*.AppxBundle' 26100 '' 'Windows 11 24H2 26100';" ^
    "Inst '3' 'Extensions\MPEG2_Video_Extension_*.AppxBundle';" ^
    "Pair '23' 'Extensions\RAW_Image_Extension_2.4.36.0.AppxBundle' 'Extensions\RAW_Image_Extension_*.AppxBundle' 22621 '2\.4\.9\.0|2\.4\.36\.0' 'Windows 11 22H2 22621';" ^
    "Inst '3' 'Extensions\VP9_Video_Extensions_*.AppxBundle';" ^
    "Pair '3' 'Extensions\WEB_Media_Extensions_1.2.29.0.AppxBundle' 'Extensions\WEB_Media_Extensions_*.AppxBundle' 22000 '1\.2\.29\.0' 'Windows 11 21H2 22000';" ^
    "Inst '123' 'Extensions\WEBP_Image_Extension_*.AppxBundle';" ^
    "exit $global:e"
if errorlevel 1 set "fail=1"
exit /b

:InstallDolby
set "fail="
powershell -NoProfile -Command ^
    "%psf%" ^
    "Inst 'd' 'Extensions\Microsoft_VCLibs_140.00*.Appx';" ^
    "Inst 'd' 'Extensions\Dolby_Audio_Extensions_1.0.61521.0.Appx';" ^
    "exit $global:e"
if errorlevel 1 set "fail=1"
exit /b

:InstallAvc
set "fail="
powershell -NoProfile -Command ^
    "%psf%" ^
    "Inst 'a' 'Extensions\Microsoft_VCLibs_140.00*.Appx';" ^
    "Inst 'a' 'Extensions\AVC_Encoder_Video_Extension_*.AppxBundle' 26100 '' 'Windows 11 24H2 26100';" ^
    "exit $global:e"
if errorlevel 1 set "fail=1"
exit /b

:Result
echo.
if defined fail (
    echo %red%Установка завершена с ошибками. Коды ошибок указаны выше.%reset%
) else (
    echo %green%Готово!%reset%
)
echo.
exit /b

:About
cls
echo.
echo Этот установщик предназначен для установки расширений декодеров современных форматов изображений и видео.
echo.
echo Минимальная установка включает 4 основных расширения:
echo %grey%.heic, .heif, .hif и .webp%reset%
echo.
echo Средняя установка включает все расширения изображений:
echo %grey%.heic, .heif, .hif, .webp, .avif, .av1, .jxl, .3fr, .arw, .cr2, .cr3, .crw,
echo .dng, .iiq, .nef, .nrw, .orf, .pef, .raf, .raw, .rw2, .rwl, .rwz, .sr2 и .srf%reset%
echo.
echo Максимальная установка — полный набор всех расширений:
echo %grey%.heic, .heif, .hif, .webp, .avif, .av1, .jxl, .3fr, .arw, .cr2, .cr3, .crw, .dng,
echo .iiq, .nef, .nrw, .orf, .pef, .raf, .raw, .rw2, .rwl, .rwz, .sr2, .srf, .h265, .hevc,
echo .mpg, .mpg2, .mpeg, .mpeg2, .m2ts, .m2v, .ts, .vp9, .webm, .oga, .ogg и .ogv%reset%
echo.
echo Вариант «На выбор» позволяет отметить нужные расширения из списка.
echo.
echo Установка Dolby Audio Extensions добавляет расширение декодера звука:
echo %grey%Dolby Digital (.ac3) и Dolby Digital Plus (.eac3).%reset%
echo.
echo Установка AVC Encoder Video Extension добавляет расширение кодировщика видео H.264 (только Windows 11 24H2 и новее).
echo %grey%Это расширение видео позволяет приложениям кодировать видео в формат AVC (H.264) видеокодирования.
echo Расширение использует API кодирования DirectX 12, если это возможно,
echo с использованием аппаратных возможностей на более новых устройствах.%reset%
echo.
echo %green%Платформа: Windows 10/11%reset%
echo.
echo %grey%Нажмите любую клавишу, чтобы вернуться…%reset%
pause >nul
goto Menu

:eof
exit