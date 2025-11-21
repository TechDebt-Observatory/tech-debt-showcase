#!/usr/bin/env python3
import json, os, sys, html

if len(sys.argv) < 3:
    print("Usage: render_html.py <repo> <output_dir>")
    sys.exit(1)

repo = sys.argv[1]
out_dir = sys.argv[2]
bundle_path = f"{os.path.expanduser('~/Shared/analysis/outputs/combined')}/{repo}/bundle.json"
summary_path = f"{os.path.expanduser('~/Shared/analysis/outputs/final')}/{repo}/summary.txt"

bundle = json.load(open(bundle_path))
summary = open(summary_path).read()

html_path = f"{out_dir}/report.html"
with open(html_path, "w") as f:

    def esc(s): return html.escape(s)

    f.write("<html><body>")
    f.write(f"<h1>Analysis Report: {repo}</h1>")

    f.write("<h2>LLM Summary</h2><pre>")
    f.write(esc(summary))
    f.write("</pre>")

    f.write("<h2>File List</h2><pre>")
    f.write(esc("\n".join(bundle.get("files", []))))
    f.write("</pre>")

    f.write("<h2>Call Graph (cflow)</h2><pre>")
    f.write(esc(bundle.get("cflow", "")))
    f.write("</pre>")

    f.write("<h2>Tags</h2><pre>")
    f.write(esc(bundle.get("ctags", "")))
    f.write("</pre>")

    f.write("<h2>clang-tidy</h2><pre>")
    f.write(esc(bundle.get("clang-tidy", "")))
    f.write("</pre>")

    f.write("<h2>cppcheck</h2><pre>")
    f.write(esc(bundle.get("cppcheck", "")))
    f.write("</pre>")

    f.write("<h2>Complexity</h2><pre>")
    f.write(esc(bundle.get("complexity", "")))
    f.write("</pre>")

    # ASTs
    f.write("<h2>AST Dumps</h2>")
    for key, astdata in bundle.get("ast", {}).items():
        f.write(f"<details><summary>{key}</summary><pre>")
        f.write(esc(json.dumps(astdata, indent=2)))
        f.write("</pre></details>")

    f.write("</body></html>")

print(f"[OK] HTML report written to {html_path}")
