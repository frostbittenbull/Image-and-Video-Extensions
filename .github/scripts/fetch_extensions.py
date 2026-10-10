import cloudscraper
import re
import os
import glob
import time

TARGETS = [
    {"id": "9n5tdp8vcmhs", "name": "Microsoft_VCLibs_140.00", "filter": "vclibs.140.00"},
    {"id": "9mvzqvxjbq9v", "name": "AV1_Video_Extension", "filter": "av1video"},
    {"id": "9pb0trcnrhfx", "name": "AVC_Encoder_Video_Extension", "filter": "avcencodervideo"},
    {"id": "9pmmsr1cgpwg", "name": "HEIF_Image_Extension", "filter": "heifimage"},
    {"id": "9nmzlz57r3t7", "name": "HEVC_Video_Extension", "filter": "hevcvideo"},
    {"id": "9mzprth5c0tb", "name": "JPEG_XL_Image_Extension", "filter": "jpeg-xl"},
    {"id": "9n95q1zzpmh4", "name": "MPEG2_Video_Extension", "filter": "mpeg2video"},
    {"id": "9nctdw2w1bh8", "name": "RAW_Image_Extension", "filter": "rawimage"},
    {"id": "9n4d0msmp0pt", "name": "VP9_Video_Extensions", "filter": "vp9video"},
    {"id": "9n5tdp8vcmhs", "name": "WEB_Media_Extensions", "filter": "webmedia"},
    {"id": "9pg2dk419drg", "name": "WEBP_Image_Extension", "filter": "webpimage"}
]

EXT_DIR = "Image and Video Extensions/Extensions"
os.makedirs(EXT_DIR, exist_ok=True)

LEGACY_LINES = {
    "RAW_Image_Extension": (2, 4),
    "WEB_Media_Extensions": (1, 2),
}

FIXED_PACKAGES = {
    "Dolby_Audio_Extensions": {
        "version": "1.0.61521.0",
        "note": "Не обновляется",
    },
}

SECTION_MAIN = "Декодеры:"
SECTION_AVC = "Кодировщики:"
SECTION_LEGACY = "Резервные расширения:"

AVC_NAME = "AVC_Encoder_Video_Extension"
LEGACY_ORDER = ["RAW_Image_Extension", "WEB_Media_Extensions", "Dolby_Audio_Extensions"]

scraper = cloudscraper.create_scraper(
    browser={'browser': 'chrome', 'platform': 'windows', 'desktop': True}
)

HEADERS = {
    "Origin": "https://store.rg-adguard.net",
    "Referer": "https://store.rg-adguard.net/",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
    "Content-Type": "application/x-www-form-urlencoded"
}


def pretty(name):
    return name.replace("_", " ")


def parse_version(v_str):
    return tuple(map(int, v_str.split('.')))


def version_of(filename):
    m = re.search(r'_(\d+\.\d+\.\d+\.\d+)\.', filename)
    return m.group(1) if m else None


def fetch_links(app_id, retries=3):
    url = "https://store.rg-adguard.net/api/GetFiles"
    data = {"type": "ProductId", "url": app_id, "ring": "Retail", "lang": "ru-RU"}
    last_error = None
    for attempt in range(1, retries + 1):
        try:
            r = scraper.post(url, data=data, headers=HEADERS, timeout=30)
            r.raise_for_status()
            return r.text
        except Exception as e:
            last_error = e
            print(f"Ошибка при запросе {app_id} (попытка {attempt}/{retries}): {e}")
            if attempt < retries:
                time.sleep(5 * attempt)
    print(f"Не удалось получить ответ по {app_id} после {retries} попыток: {last_error}")
    return None


def download_file(url, filename):
    path = os.path.join(EXT_DIR, filename)
    tmp = path + ".part"
    print(f"Скачивание: {filename}...")
    try:
        with scraper.get(url, stream=True, timeout=120) as r:
            r.raise_for_status()
            with open(tmp, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)


def local_files(name, legacy):
    """Локальные файлы пакета нужной ветки: [(путь, версия_строкой, версия_кортежем)]."""
    result = []
    for p in glob.glob(os.path.join(EXT_DIR, f"{name}_*")):
        base = os.path.basename(p)
        v = version_of(base)
        if not v:
            continue
        vt = parse_version(v)
        if name in LEGACY_LINES:
            in_legacy_line = vt[:2] == LEGACY_LINES[name]
            if in_legacy_line != legacy:
                continue
        result.append((p, v, vt))
    return result


def pick_best(candidates, name, legacy):
    """Лучший кандидат для ветки (основной или резервной)."""
    if name in LEGACY_LINES:
        line = LEGACY_LINES[name]
        if legacy:
            candidates = [c for c in candidates if c['version_tuple'][:2] == line]
        else:
            candidates = [c for c in candidates if c['version_tuple'][:2] > line]
    if not candidates:
        return None
    return sorted(candidates, key=lambda x: (x['version_tuple'], x['priority']), reverse=True)[0]


def note_line(icon, name, version, text):
    label = pretty(name) + (f" {version}" if version else "")
    return f"{icon} {label} — {text}"


def sync_track(name, legacy, best, fetched):
    """Сверяет одну ветку пакета с сервером, при необходимости скачивает новую версию
    и возвращает строку для релиз-нот."""
    existing = sorted(local_files(name, legacy), key=lambda x: x[2], reverse=True)
    old_version = existing[0][1] if existing else None

    def ic(main_icon):
        return main_icon

    if not fetched:
        return note_line(ic("🔴"), name, old_version, "Не обновилось")

    if not best:
        if legacy and old_version:
            print(f"{name}: на сервере нет версий резервной линии, оставляем {old_version}.")
            return note_line("🔴", name, old_version, "Не обновилось")
        print(f"Не найдено подходящих файлов для {name}")
        return note_line("⚠️", name, old_version, "Не найдено подходящих файлов на сервере")

    new_version = best['version_str']
    label = f"{name} ({'резервная ветка' if legacy else 'основная ветка'})" if name in LEGACY_LINES else name

    if old_version == new_version:
        print(f"{label}: версия {new_version} актуальна.")
        return note_line(ic("🔴"), name, old_version, "Не обновилось")

    if old_version and best['version_tuple'] < parse_version(old_version):
        print(f"{label}: на сервере {new_version} ниже установленной {old_version} — откат.")
        icon, shown, text = "🟡", old_version, f"Откатилось до {new_version}"
    elif old_version:
        print(f"{label}: найдено обновление {old_version} -> {new_version}")
        icon, shown, text = "🟢", old_version, f"Обновилось до {new_version}"
    else:
        print(f"{label}: новый пакет {new_version}")
        icon, shown, text = "🔵", new_version, "Добавлено"

    try:
        download_file(best['url'], best['filename'])
    except Exception as e:
        print(f"Не удалось скачать {best['filename']}: {e}")
        return note_line(ic("🔴"), name, old_version, "Не обновилось")

    for path, _, _ in existing:
        if os.path.basename(path) != best['filename']:
            os.remove(path)
            print(f"Удален старый файл: {os.path.basename(path)}")

    return note_line(ic(icon), name, shown, text)


main_notes = []
avc_notes = []
legacy_notes = {}

try:
    scraper.get("https://store.rg-adguard.net/", headers=HEADERS, timeout=30)
except Exception:
    pass

html_cache = {}

for fixed_name, fixed_cfg in FIXED_PACKAGES.items():
    if glob.glob(os.path.join(EXT_DIR, f"{fixed_name}_{fixed_cfg['version']}.*")):
        legacy_notes[fixed_name] = f"🟣 {pretty(fixed_name)} {fixed_cfg['version']} — {fixed_cfg['note']}"

for target in TARGETS:
    app_id = target["id"]
    nice_name = target["name"]
    pkg_filter = target["filter"]

    print(f"\nПроверка: {nice_name} ({app_id})")

    if app_id not in html_cache:
        html_cache[app_id] = fetch_links(app_id)
        time.sleep(3)
    else:
        print("Используется кэшированный ответ API.")
    html = html_cache[app_id]

    candidates = []
    if html:
        links = re.findall(r'<a href="(.*?)".*?>(.*?)</a>', html)

        for href, text in links:
            text_lower = text.lower()

            if pkg_filter not in text_lower: continue

            if "uwpdesktop" in text_lower: continue

            if ".blockmap" in text_lower or ".eappxbundle" in text_lower: continue
            if "arm" in text_lower or "x86" in text_lower: continue
            if "scale-" in text_lower: continue

            ver_match = re.search(r'_(\d+\.\d+\.\d+\.\d+)_', text)
            if not ver_match: continue
            version = ver_match.group(1)

            priority = 0
            ext = ""
            if text_lower.endswith(".appxbundle"):
                priority = 3
                ext = "AppxBundle"
            elif "x64" in text_lower and text_lower.endswith(".appx"):
                priority = 2
                ext = "Appx"
            elif "neutral" in text_lower and text_lower.endswith(".appx"):
                priority = 1
                ext = "Appx"

            if priority > 0:
                candidates.append({
                    "url": href,
                    "version_str": version,
                    "version_tuple": parse_version(version),
                    "filename": f"{nice_name}_{version}.{ext}",
                    "priority": priority
                })
    else:
        print("Не удалось получить HTML-ответ от сервера.")

    line = sync_track(nice_name, False, pick_best(candidates, nice_name, False), bool(html))
    (avc_notes if nice_name == AVC_NAME else main_notes).append(line)

    if nice_name in LEGACY_LINES:
        legacy_notes[nice_name] = sync_track(
            nice_name, True, pick_best(candidates, nice_name, True), bool(html)
        )

actual_files = []
for target in TARGETS:
    pattern = os.path.join(EXT_DIR, f"{target['name']}_*")
    for f in sorted(glob.glob(pattern)):
        name = os.path.basename(f)
        if name.endswith(".part"):
            continue
        if name not in actual_files:
            actual_files.append(name)

for name_, cfg_ in FIXED_PACKAGES.items():
    for f in sorted(glob.glob(os.path.join(EXT_DIR, f"{name_}_{cfg_['version']}.*"))):
        name = os.path.basename(f)
        if name not in actual_files:
            actual_files.append(name)

actual_files.sort()

if actual_files:
    tree_lines = [
        "```text",
        "Image and Video Extensions/",
        "├── Install.bat",
        "└── Extensions/"
    ]
    for i, f in enumerate(actual_files):
        connector = "└──" if i == len(actual_files) - 1 else "├──"
        tree_lines.append(f"    {connector} {f}")
    tree_lines.append("```")

    tree_text = "\n".join(tree_lines)

    readme_path = "README.md"
    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as file:
            readme_content = file.read()

        start_marker = "<!-- TREE_START -->\n"
        end_marker = "\n<!-- TREE_END -->"

        if start_marker in readme_content and end_marker in readme_content:
            before = readme_content.split(start_marker)[0]
            after = readme_content.split(end_marker)[1]
            new_readme_content = before + start_marker + tree_text + end_marker + after

            if new_readme_content != readme_content:
                with open(readme_path, "w", encoding="utf-8") as file:
                    file.write(new_readme_content)
                print("\n✅ Файл README.md обновлен актуальными версиями (только текст дерева, статус изменений определяется отдельно через git).")

notes = ["### Список обновлений:", ""]
if main_notes:
    notes.append(SECTION_MAIN)
    notes.extend(main_notes)
    notes.append("")
if avc_notes:
    notes.append(SECTION_AVC)
    notes.extend(avc_notes)
    notes.append("")
legacy_lines = [legacy_notes[k] for k in LEGACY_ORDER if k in legacy_notes]
if legacy_lines:
    notes.append(SECTION_LEGACY)
    notes.extend(legacy_lines)

gh_output = os.getenv('GITHUB_OUTPUT')
if gh_output:
    with open(gh_output, 'a', encoding='utf-8') as f:
        f.write("notes<<EOF\n")
        f.write("\n".join(notes) + "\n")
        f.write("EOF\n")
else:
    print("\n".join(notes))
