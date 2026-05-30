import cloudscraper
import re
import os
import glob
import time

TARGETS =[
    {"id": "9n5tdp8vcmhs", "name": "Microsoft_VCLibs_140.00", "filter": "vclibs.140.00"},
    {"id": "9mvzqvxjbq9v", "name": "AV1_Video_Extension", "filter": "av1video"},
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

def fetch_links(app_id):
    url = "https://store.rg-adguard.net/api/GetFiles"
    data = {"type": "ProductId", "url": app_id, "ring": "Retail", "lang": "ru-RU"}
    try:
        r = scraper.post(url, data=data, headers=HEADERS, timeout=30)
        r.raise_for_status()
        return r.text
    except Exception as e:
        print(f"Ошибка при запросе {app_id}: {e}")
        return None

def download_file(url, filename):
    path = os.path.join(EXT_DIR, filename)
    print(f"Скачивание: {filename}...")
    with scraper.get(url, stream=True) as r:
        r.raise_for_status()
        with open(path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)

def parse_version(v_str):
    return tuple(map(int, v_str.split('.')))

notes =["### Список обновлений:\n"]
has_changes = False

try:
    scraper.get("https://store.rg-adguard.net/", headers=HEADERS, timeout=30)
except:
    pass

html_cache = {}

for target in TARGETS:
    app_id = target["id"]
    nice_name = target["name"]
    pkg_filter = target["filter"]
    
    print(f"\nПроверка: {nice_name} ({app_id})")
    
    if app_id not in html_cache:
        html = fetch_links(app_id)
        html_cache[app_id] = html
        time.sleep(3)
    else:
        html = html_cache[app_id]
        print("Используется кэшированный ответ API.")
    
    if not html:
        print("Не удалось получить HTML-ответ от сервера.")
        continue

    links = re.findall(r'<a href="(.*?)".*?>(.*?)</a>', html)

    candidates =[]
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

    if candidates:
        best = sorted(candidates, key=lambda x: (x['version_tuple'], x['priority']), reverse=True)[0]
        
        best_filename = best['filename']
        best_version = best['version_str']
        
        existing_files = glob.glob(os.path.join(EXT_DIR, f"{nice_name}_*"))
        old_version = None
        
        if existing_files:
            old_file = os.path.basename(existing_files[0])
            old_ver_match = re.search(r'_(\d+\.\d+\.\d+\.\d+)\.', old_file)
            if old_ver_match:
                old_version = old_ver_match.group(1)

        if old_version == best_version:
            print(f"Версия {best_version} актуальна.")
            notes.append(f"🔴 `{nice_name}_{best_version}` — Не обновилось")
        else:
            if old_version:
                print(f"Найдено обновление: {old_version} -> {best_version}")
                notes.append(f"🟢 `{nice_name}_{old_version}` — Обновилось до `{best_version}`")
            else:
                print(f"Новый пакет: {best_version}")
                notes.append(f"🟡 `{nice_name}_{best_version}` — Добавлено")
            
            for ef in existing_files:
                os.remove(ef)
                print(f"Удален старый файл: {os.path.basename(ef)}")
            
            download_file(best['url'], best_filename)
            has_changes = True
    else:
        print(f"Не найдено подходящих файлов для {nice_name}")

actual_files =[]
for target in TARGETS:
    pattern = os.path.join(EXT_DIR, f"{target['name']}_*")
    found = glob.glob(pattern)
    if found:
        actual_files.append(os.path.basename(found[0]))

if actual_files:
    tree_lines =[
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
                print("\n✅ Файл README.md обновлен актуальными версиями!")
                has_changes = True

gh_output = os.getenv('GITHUB_OUTPUT')
if gh_output:
    with open(gh_output, 'a', encoding='utf-8') as f:
        f.write(f"changed={'true' if has_changes else 'false'}\n")
        f.write("notes<<EOF\n")
        f.write("\n".join(notes) + "\n")
        f.write("EOF\n")
