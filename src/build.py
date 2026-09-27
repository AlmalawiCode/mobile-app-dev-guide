#!/usr/bin/env python3
"""يجمّع أجزاء الدليل، يولّد الفهرس تلقائيًا، ويُخرج PDF عبر WeasyPrint."""
import re, sys, glob, subprocess, pathlib, html

ROOT = pathlib.Path(__file__).parent          # src/
DOCS = ROOT.parent / 'docs'                   # مخرجات النشر (GitHub Pages)
parts = sorted(glob.glob(str(ROOT / 'parts' / '*.html')), key=lambda f: int(pathlib.Path(f).name.split('_')[0]))
body = ''.join(open(p, encoding='utf-8').read() for p in parts)

# --- ترقيم الفصول وتوليد الفهرس ---
toc = []
chapter_no = 0
def slug(i): return f'sec-{i}'
counter = [0]
def h1_repl(m):
    global chapter_no
    attrs, title = m.group(1), m.group(2)
    idm = re.search(r'id="([^"]+)"', attrs)
    counter[0] += 1
    hid = idm.group(1) if idm else slug(counter[0])
    if 'class="chapter"' in attrs:
        chapter_no += 1
        num = f'<div class="chnum">CHAPTER {chapter_no:02d}</div>'
        label = f'الفصل {chapter_no}: {re.sub("<[^>]+>", "", title)}'
    else:
        num = ''
        label = re.sub('<[^>]+>', '', title)
    toc.append(('l1', hid, label))
    attrs2 = attrs if idm else attrs + f' id="{hid}"'
    return f'{num}<h1{attrs2}>{title}</h1>'
body = re.sub(r'<h1([^>]*)>(.*?)</h1>', h1_repl, body, flags=re.S)

def h2_repl(m):
    attrs, title = m.group(1), m.group(2)
    idm = re.search(r'id="([^"]+)"', attrs)
    counter[0] += 1
    hid = idm.group(1) if idm else slug(counter[0])
    if 'class="notoc"' not in attrs:
        toc.append(('l2', hid, re.sub('<[^>]+>', '', title)))
    attrs2 = attrs if idm else attrs + f' id="{hid}"'
    return f'<h2{attrs2}>{title}</h2>'
body = re.sub(r'<h2([^>]*)>(.*?)</h2>', h2_repl, body, flags=re.S)

toc_html = '<nav class="toc"><h1 class="front" id="toc">الفهرس</h1><ol>' + ''.join(
    f'<li class="{lvl}"><a href="#{hid}">{html.escape(label, quote=False)}</a></li>' for lvl, hid, label in toc
) + '</ol></nav>'
body = body.replace('<!--TOC-->', toc_html)

page = f'''<!doctype html>
<html lang="ar" dir="rtl"><head><meta charset="utf-8">
<title>من الفكرة إلى المتجر: دليل تطوير تطبيقات الهاتف</title>
<link rel="stylesheet" href="style.css"></head><body>
{body}
</body></html>'''
(DOCS / 'print.html').write_text(page, encoding='utf-8')
print(f'parts: {len(parts)}  toc entries: {len(toc)}  chapters: {chapter_no}')

# ================= قارئ الويب (فصل واحد في كل مرة) =================
import json
body_r = body.replace(toc_html, '')
# قسّم عند كل h1 (مع رقم الفصل الذي يسبقه إن وُجد)
pieces = re.split(r'(?=<h1[^>]*>)', body_r)
# رقم الفصل يسبق h1 مباشرة: انقله إلى بداية القطعة التالية
for i in range(len(pieces) - 1):
    m = re.search(r'(<div class="chnum">CHAPTER \d+</div>)\s*$', pieces[i])
    if m:
        pieces[i] = pieces[i][:m.start()]
        pieces[i+1] = m.group(1) + pieces[i+1]
pieces = [p for p in pieces if p.strip()]
sections = []   # (hid, title, html, kind)
for p in pieces:
    m = re.search(r'<h1([^>]*)>(.*?)</h1>', p, flags=re.S)
    if not m:
        sections.append(('cover', 'الغلاف', p, 'cover')); continue
    hid = re.search(r'id="([^"]+)"', m.group(1)).group(1)
    title = re.sub('<[^>]+>', '', m.group(2))
    kind = 'chapter' if 'class="chapter"' in m.group(1) else 'front'
    sections.append((hid, title, p, kind))
# ادمج الغلاف مع صفحة "قبل أن تبدأ"
if sections and sections[0][0] == 'cover' and len(sections) > 1:
    hid, title, h, kind = sections[1]
    sections = [(hid, title, sections[0][2] + h, kind)] + sections[2:]
# فهرس h2 لكل قسم
def subs(h):
    return [(m.group(1), re.sub('<[^>]+>', '', m.group(2))) for m in re.finditer(r'<h2(?![^>]*notoc)[^>]*id="([^"]+)"[^>]*>(.*?)</h2>', h, flags=re.S)]
nav_items = []
chap = 0
for hid, title, h, kind in sections:
    if kind == 'chapter':
        chap += 1; label = f'<span class="n">{chap:02d}</span>{title}'
    else:
        label = f'<span class="n">•</span>{title}'
    sub = ''.join(f'<li><a href="#{hid}/{sid}" data-sub="{sid}">{html.escape(st, quote=False)}</a></li>' for sid, st in subs(h))
    nav_items.append(f'<li class="l1" data-page="{hid}"><a href="#{hid}">{label}</a>{"<ol class=sub>"+sub+"</ol>" if sub else ""}</li>')
pages_html = ''
for i, (hid, title, h, kind) in enumerate(sections):
    prev = sections[i-1] if i > 0 else None
    nxt = sections[i+1] if i+1 < len(sections) else None
    pager = '<div class="pager">'
    pager += (f'<a class="prev" href="#{prev[0]}"><small>السابق</small>{html.escape(prev[1], quote=False)}</a>' if prev else '<a class="none"></a>')
    pager += (f'<a class="next" href="#{nxt[0]}"><small>التالي</small>{html.escape(nxt[1], quote=False)}</a>' if nxt else '<a class="none"></a>')
    pager += '</div>'
    h = h.replace('<table', '<div class="tbl"><table').replace('</table>', '</table></div>')
    pages_html += f'<section class="page" data-page="{hid}" hidden>{h}{pager}</section>\n'
order = json.dumps([s[0] for s in sections], ensure_ascii=False)
titles = json.dumps({s[0]: s[1] for s in sections}, ensure_ascii=False)
reader_page = f"""<!doctype html>
<html lang="ar" dir="rtl"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>من الفكرة إلى المتجر: دليل تطوير تطبيقات الهاتف</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Noto+Naskh+Arabic:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="reader.css"></head><body>
<div class="topbar"><button id="menuBtn" aria-label="المحتويات">☰ المحتويات</button><div class="t" id="topTitle"></div></div>
<div class="scrim" id="scrim"></div>
<div class="app">
<aside class="side" id="side">
  <p class="brand">من الفكرة إلى المتجر<small>دليل تطوير تطبيقات الهاتف بمساعدة الذكاء الاصطناعي</small></p>
  <div class="progress"><i id="prog"></i></div>
  <nav><ol>{''.join(nav_items)}</ol></nav>
</aside>
<main class="reader" id="main">
{pages_html}
</main>
</div>
<script>
const ORDER = {order};
const TITLES = {titles};
const pages = Object.fromEntries([...document.querySelectorAll('section.page')].map(s => [s.dataset.page, s]));
const navItems = Object.fromEntries([...document.querySelectorAll('aside li.l1')].map(l => [l.dataset.page, l]));
function show(id, sub) {{
  if (!pages[id]) id = ORDER[0];
  for (const k in pages) pages[k].hidden = (k !== id);
  for (const k in navItems) navItems[k].classList.toggle('active', k === id);
  const i = ORDER.indexOf(id);
  document.getElementById('prog').style.width = ((i + 1) / ORDER.length * 100) + '%';
  document.getElementById('topTitle').textContent = TITLES[id] || '';
  document.body.classList.remove('nav-open');
  try {{ localStorage.setItem('guide-pos', id + (sub ? '/' + sub : '')); }} catch (e) {{}}
  if (sub && document.getElementById(sub)) {{
    document.getElementById(sub).scrollIntoView({{block: 'start'}});
  }} else {{
    window.scrollTo({{top: 0}});
  }}
  const act = navItems[id]; if (act) act.scrollIntoView({{block: 'nearest'}});
}}
function route() {{
  let h = location.hash.replace(/^#/, '');
  if (!h) {{ try {{ h = localStorage.getItem('guide-pos') || ''; }} catch (e) {{}} }}
  const [id, sub] = h.split('/');
  show(id || ORDER[0], sub);
}}
window.addEventListener('hashchange', route);
route();
// تمييز العنوان الفرعي الحالي أثناء التمرير
const obs = new IntersectionObserver(es => {{
  es.forEach(e => {{ if (e.isIntersecting) {{
    document.querySelectorAll('aside ol.sub a').forEach(a => a.classList.toggle('cur', a.dataset.sub === e.target.id));
  }} }});
}}, {{rootMargin: '-10% 0px -80% 0px'}});
document.querySelectorAll('section.page h2[id]').forEach(h => obs.observe(h));
document.getElementById('menuBtn').onclick = () => document.body.classList.toggle('nav-open');
document.getElementById('scrim').onclick = () => document.body.classList.remove('nav-open');
document.addEventListener('keydown', e => {{
  if (e.target.tagName === 'INPUT') return;
  const i = ORDER.indexOf(Object.keys(pages).find(k => !pages[k].hidden));
  if (e.key === 'ArrowLeft' && i < ORDER.length - 1) location.hash = ORDER[i + 1];
  if (e.key === 'ArrowRight' && i > 0) location.hash = ORDER[i - 1];
}});
</script>
</body></html>"""
(DOCS / 'index.html').write_text(reader_page, encoding='utf-8')
print(f'reader pages: {len(sections)}')


if '--pdf' in sys.argv:
    out = ROOT.parent / 'build' / 'mobile-app-dev-guide-ar.pdf'
    out.parent.mkdir(exist_ok=True)
    r = subprocess.run(['weasyprint', str(DOCS / 'print.html'), str(out)], capture_output=True, text=True)
    warn = [l for l in r.stderr.splitlines() if 'unicode-bidi' not in l and l.strip()]
    print('\n'.join(warn[:20]))
    info = subprocess.run(['pdfinfo', str(out)], capture_output=True, text=True).stdout
    print([l for l in info.splitlines() if l.startswith('Pages')])
