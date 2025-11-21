#!/usr/bin/env python3
import json, glob, os, sys
if len(sys.argv) != 2:
  print("Usage: combine.py <repo_name>")
  sys.exit(1)
base = os.path.expanduser("~/Shared/analysis")
repo_name = sys.argv[1]
out_dir = os.path.join(base, "outputs", "raw", repo_name)
combined_dir = os.path.join(base, "outputs", "combined", repo_name)
os.makedirs(combined_dir, exist_ok=True)
bundle = {}
# files
files_path = os.path.join(out_dir, "files.txt")
bundle["files"] = open(files_path).read().splitlines() if os.path.exists(files_path) else []
# simple text artifacts
for key in ("cflow.txt","ctags.txt","clang-tidy.txt","cppcheck.xml","complexity.txt"):
  p = os.path.join(out_dir, key)
  bundle[key.replace('.txt','').replace('.xml','')] = open(p).read() if os.path.exists(p) else ""
# ast
bundle["ast"] = {}
for f in glob.glob(os.path.join(out_dir, "*.ast.json")):
  key = os.path.basename(f).replace(".ast.json","")
  try:
    bundle["ast"][key] = json.load(open(f))
  except Exception as e:
    bundle["ast"][key] = {"error":"failed to parse","path":f,"exc":str(e)}
out_file = os.path.join(combined_dir, "bundle.json")
with open(out_file, "w") as fh:
  json.dump(bundle, fh, indent=2)
print("[INFO] Bundle created at", out_file)
