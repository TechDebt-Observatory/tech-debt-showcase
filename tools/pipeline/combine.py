#!/usr/bin/env python3
"""
combine.py - Static Analysis Bundle Aggregator

4D DOCUMENTATION
================

@purpose: Aggregate multi-tool analysis outputs into single JSON bundle
    - Combine outputs from 7 different static analysis tools
    - Create unified data structure for LLM preprocessing
    - Enable single-file distribution of complete analysis results
    - Preserve raw tool outputs alongside structured AST data
    - Support multi-repository analysis workflows

@workflow: Three-phase aggregation process
    Phase 1: File Discovery
        └─> Locate all analysis outputs in raw directory
        └─> Read file list from files.txt
        └─> Validate all expected outputs exist
    
    Phase 2: Data Loading
        └─> Load text outputs (cflow, ctags, clang-tidy, complexity)
        └─> Parse XML output (cppcheck)
        └─> Load and parse JSON AST dumps for each .c file
        └─> Build nested dictionary structure
    
    Phase 3: Bundle Creation
        └─> Combine all data into single JSON object
        └─> Write to combined directory with indentation
        └─> Report bundle location for next pipeline step

@dependencies: Python 3.6+ with standard library
    System requirements:
        - Python 3.6+ (f-strings, dict ordering)
        - Standard library only (json, glob, os, sys)
        - No external packages required
    
    File structure:
        - ../outputs/raw/REPO_NAME/ - Input directory
        - ../outputs/combined/REPO_NAME/ - Output directory
        - Expected files: files.txt, cflow.txt, ctags.txt, 
          clang-tidy.txt, cppcheck.xml, complexity.txt, *.ast.json
    
    Relative paths:
        - Assumes execution from pipeline/ directory
        - Created by setup-pipeline.sh in ~/Shared/analysis/pipeline/

@gotchas: Data integrity and error handling
    Missing Files:
        - No validation for missing analysis outputs
        - Will raise FileNotFoundError on missing files
        - run_static.sh should complete before running this
        - Consider adding error handling for partial results
    
    Memory Usage:
        - Loads all AST files into memory at once
        - Large codebases (>1000 files) may exceed RAM
        - JSON parsing is memory-intensive for deep ASTs
        - Consider streaming for repositories with >5000 files
    
    Path Assumptions:
        - Relative paths (..) assume specific directory structure
        - Will fail if run from different working directory
        - setup-pipeline.sh creates correct structure
        - Manual execution requires cd to pipeline/ first
    
    JSON Encoding:
        - Uses indent=2 for readability (increases file size)
        - Large bundles (>100MB) may be slow to pretty-print
        - Consider indent=None for production use
        - AST dumps can be deeply nested (recursion risk)
    
    Filename Patterns:
        - AST files must match pattern: *.ast.json
        - Basename extraction assumes .ast.json suffix
        - Non-.c files won't have AST dumps (expected)
        - Glob pattern may match unexpected files

USAGE:
    python combine.py <repo_name>
    
    Example:
        cd ~/Shared/analysis/pipeline
        python combine.py openssl

ARGUMENTS:
    repo_name: Name of repository (matches directory in repos/)

OUTPUT:
    Creates: ../outputs/combined/REPO_NAME/bundle.json
    
    Bundle structure:
        {
          "files": ["file1.c", "file2.h", ...],
          "callgraph": "cflow output...",
          "ctags": "ctags output...",
          "clang_tidy": "clang-tidy output...",
          "cppcheck": "cppcheck XML...",
          "complexity": "lizard output...",
          "ast": {
            "file1.c": {...AST...},
            "file2.c": {...AST...}
          }
        }

RELATED SCRIPTS:
    - setup-pipeline.sh - Creates this script and directory structure
    - run_static.sh - Generates the input files (prerequisite)
    - run_llm_local.sh - Consumes the bundle.json output

ERROR HANDLING:
    - FileNotFoundError: Missing input files (run run_static.sh first)
    - JSONDecodeError: Malformed AST files (check clang errors)
    - PermissionError: Can't write to combined directory (check permissions)
    - KeyError: Missing expected keys in bundle structure

MAINTENANCE:
    - Update bundle structure if adding new analysis tools
    - Consider adding file existence validation before loading
    - Consider adding progress output for large repositories
    - May need streaming approach for very large codebases
"""

import json
import glob
import os
import sys


def main():
    """Main aggregation workflow."""
    # Validate command-line arguments
    if len(sys.argv) != 2:
        print("Usage: python combine.py <repo_name>")
        sys.exit(1)
    
    repo_name = sys.argv[1]
    
    # Define input and output directories
    # WHY: Relative paths assume execution from pipeline/ directory
    out_dir = f"../outputs/raw/{repo_name}"
    combined_dir = f"../outputs/combined/{repo_name}"
    
    # Create output directory
    # WHY: exist_ok=True allows re-running without errors
    os.makedirs(combined_dir, exist_ok=True)
    
    # Build the bundle dictionary
    # WHY: Dict preserves insertion order in Python 3.7+
    bundle = {
        # WHY: splitlines() removes trailing newlines and creates list
        "files": open(f"{out_dir}/files.txt").read().splitlines(),
        
        # WHY: Read as complete strings for text-based tool outputs
        "callgraph": open(f"{out_dir}/cflow.txt").read(),
        "ctags": open(f"{out_dir}/ctags.txt").read(),
        "clang_tidy": open(f"{out_dir}/clang-tidy.txt").read(),
        "cppcheck": open(f"{out_dir}/cppcheck.xml").read(),
        "complexity": open(f"{out_dir}/complexity.txt").read(),
        
        # WHY: Nested dict for per-file AST data
        "ast": {}
    }
    
    # Load all AST JSON files
    # WHY: glob.glob finds all matching files in directory
    for f in glob.glob(f"{out_dir}/*.ast.json"):
        # WHY: Extract base filename without .ast.json suffix
        # Example: "foo.c.ast.json" -> "foo.c"
        key = os.path.basename(f).replace(".ast.json", "")
        
        # WHY: Load JSON and store in ast dictionary
        bundle["ast"][key] = json.loads(open(f).read())
    
    # Write bundle to output file
    # WHY: indent=2 makes JSON human-readable for debugging
    with open(f"{combined_dir}/bundle.json", "w") as f:
        json.dump(bundle, f, indent=2)
    
    print(f"[INFO] Bundle created at {combined_dir}/bundle.json")


if __name__ == "__main__":
    main()
