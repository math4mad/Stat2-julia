from html import unescape
from html.parser import HTMLParser
from pathlib import Path
import re

PAGE = Path("notes.html")


class FirstLink(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.current = None

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            self.current = dict(attrs)
            self.current["text"] = ""

    def handle_data(self, data):
        if self.current is not None:
            self.current["text"] += data

    def handle_endtag(self, tag):
        if tag == "a" and self.current is not None:
            self.links.append(self.current)
            self.current = None


html = PAGE.read_text(encoding="utf-8")
match = re.search(r"(?P<list><ul>.*?</ul>)", html, re.DOTALL)
if not match:
    raise SystemExit("notes list not found")

entries = []
for item in re.findall(r"<li>.*?</li>", match.group("list"), re.DOTALL):
    parser = FirstLink()
    parser.feed(item)
    rendered = next((link for link in parser.links if link.get("href", "").startswith("notes/")), None)
    source = next((link for link in parser.links if "/blob/python/" in link.get("href", "")), None)
    if rendered:
        parts = unescape(rendered["href"]).split("/")[1:-1]
        part = parts[0] if parts else "Root utilities"
        chapter = "/".join(parts[1:]) if len(parts) > 1 else "Root"
        entries.append((part, chapter, rendered.get("text", "").strip(), rendered["href"], source.get("href") if source else ""))

categories = {}
for entry in entries:
    categories.setdefault((entry[0], entry[1]), []).append(entry)

sections = ['<div class="notebook-library">']
current_part = None
for (part, chapter), notes in categories.items():
    if part != current_part:
        sections.append(f"<h2>{part}</h2>")
        current_part = part
    sections.append(f"<h3>{chapter}</h3>")
    sections.append('<table><thead><tr><th>Notebook</th><th>Format</th></tr></thead><tbody>')
    for _, _, name, rendered, source in notes:
        source_cell = f'<a href="{source}">Python</a>' if source else "Python"
        sections.append(f'<tr><td><a href="{rendered}">{name}</a></td><td>{source_cell}</td></tr>')
    sections.append("</tbody></table>")
sections.append("</div>")

updated = html[: match.start()] + "\n".join(sections) + html[match.end() :]
updated = re.sub(r"\n\s*<script>\n\s*document\.addEventListener\('DOMContentLoaded', \(\) => \{.*?</script>\n", "\n", updated, count=1, flags=re.DOTALL)
PAGE.write_text(updated, encoding="utf-8")
print(f"Wrote {len(entries)} notes in {len(categories)} folder categories")
