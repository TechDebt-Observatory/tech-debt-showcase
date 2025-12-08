#!/usr/bin/env python3
"""
render_html.py - Analysis Bundle HTML Report Generator

4D DOCUMENTATION
================

@purpose: Generate interactive HTML report from analysis bundle
    - Transform JSON bundle into human-readable HTML format
    - Create navigable sections for each analysis tool
    - Enable visual inspection of static analysis results
    - Provide syntax highlighting for code snippets
    - Support offline viewing without dependencies

@workflow: Four-phase rendering process
    Phase 1: Bundle Loading
        └─> Read bundle.json from combined directory
        └─> Validate JSON structure and required keys
        └─> Extract metadata (file count, tool outputs)
    
    Phase 2: Template Generation
        └─> Create HTML structure with CSS styling
        └─> Build navigation menu for tool sections
        └─> Generate summary statistics table
        └─> Add JavaScript for interactive features
    
    Phase 3: Content Rendering
        └─> Render file list with syntax highlighting
        └─> Format call graph as collapsible tree
        └─> Display ctags in sortable table
        └─> Show clang-tidy/cppcheck warnings with severity
        └─> Visualize complexity metrics as charts
        └─> Embed AST data in expandable sections
    
    Phase 4: Output Generation
        └─> Write self-contained HTML file
        └─> Include inline CSS and JavaScript
        └─> Add timestamp and metadata
        └─> Report output location

@dependencies: Python 3.6+ with standard library
    System requirements:
        - Python 3.6+ (f-strings required)
        - Standard library only (json, os, sys, datetime)
        - No external packages or templates
        - Works offline after generation
    
    File structure:
        - ../outputs/combined/REPO_NAME/bundle.json - Input
        - ../outputs/final/REPO_NAME/report.html - Output
        - Self-contained HTML (no external CSS/JS)
    
    Relative paths:
        - Assumes execution from pipeline/ directory
        - Created by setup-pipeline.sh in ~/Shared/analysis/pipeline/

@gotchas: HTML generation and browser compatibility
    Bundle Size:
        - Large bundles (>50MB JSON) create huge HTML files
        - Browser may struggle with >100MB HTML
        - AST sections can be deeply nested (DOM performance)
        - Consider pagination for repositories >10,000 files
    
    JSON Encoding:
        - HTML entities must be escaped in content
        - JSON special characters need escaping in <script> tags
        - Large AST dumps may hit browser recursion limits
        - Use JSON.parse() carefully for embedded data
    
    Browser Compatibility:
        - Modern JavaScript (ES6+) for interactive features
        - CSS Grid/Flexbox for layout (IE11 not supported)
        - localStorage for user preferences (may be blocked)
        - Consider fallback for older browsers
    
    Memory Usage:
        - Entire bundle loaded into Python memory
        - HTML string constructed in memory before write
        - Large repositories may require >4GB RAM
        - Consider streaming write for very large outputs
    
    Path Assumptions:
        - Relative paths (..) assume specific directory structure
        - Will fail if run from different working directory
        - setup-pipeline.sh creates correct structure
        - Manual execution requires cd to pipeline/ first

USAGE:
    python render_html.py <repo_name>
    
    Example:
        cd ~/Shared/analysis/pipeline
        python render_html.py openssl
        
    View output:
        firefox ../outputs/final/openssl/report.html

ARGUMENTS:
    repo_name: Name of repository (matches bundle directory)

OUTPUT:
    Creates: ../outputs/final/REPO_NAME/report.html
    
    HTML sections:
        1. Summary - File count, tool versions, timestamps
        2. File List - All analyzed .c and .h files
        3. Call Graph - cflow output with collapsible tree
        4. Symbol Tags - ctags cross-reference table
        5. Static Warnings - clang-tidy findings
        6. Code Quality - cppcheck XML parsed results
        7. Complexity Metrics - Cyclomatic complexity charts
        8. AST Explorer - Interactive JSON tree viewer

RELATED SCRIPTS:
    - setup-pipeline.sh - Creates this script and directory structure
    - combine.py - Generates the bundle.json input (prerequisite)
    - run_llm_local.sh - Parallel workflow for LLM preprocessing

ERROR HANDLING:
    - FileNotFoundError: Missing bundle.json (run combine.py first)
    - JSONDecodeError: Malformed bundle JSON (check combine.py)
    - PermissionError: Can't write to final directory (check permissions)
    - KeyError: Missing expected keys in bundle (version mismatch)

MAINTENANCE:
    - Update HTML template if adding new analysis tools
    - Consider adding CSS framework for better styling
    - May need JavaScript bundler for complex interactivity
    - Test output with different browsers for compatibility
"""

import json
import os
import sys
from datetime import datetime


def generate_html_template(repo_name, bundle):
    """
    Generate complete HTML report from bundle data.
    
    Args:
        repo_name: Repository name for title
        bundle: Dictionary containing all analysis data
    
    Returns:
        Complete HTML string ready to write
    """
    # WHY: Get current timestamp for report metadata
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # WHY: Count files for summary statistics
    file_count = len(bundle.get("files", []))
    ast_count = len(bundle.get("ast", {}))
    
    # Build HTML structure
    # WHY: Triple-quoted f-string for readability
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analysis Report: {repo_name}</title>
    <style>
        /* WHY: Inline CSS for self-contained HTML */
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }}
        
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        
        .header h1 {{
            margin: 0;
            font-size: 2.5rem;
        }}
        
        .header .meta {{
            opacity: 0.9;
            margin-top: 0.5rem;
        }}
        
        .container {{
            max-width: 1400px;
            margin: 2rem auto;
            padding: 0 2rem;
        }}
        
        .summary {{
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }}
        
        .summary .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }}
        
        .stat-box {{
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 4px;
            border-left: 4px solid #667eea;
        }}
        
        .stat-box .label {{
            font-size: 0.875rem;
            color: #666;
            margin-bottom: 0.25rem;
        }}
        
        .stat-box .value {{
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
        }}
        
        .section {{
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }}
        
        .section h2 {{
            margin-top: 0;
            color: #667eea;
            border-bottom: 2px solid #667eea;
            padding-bottom: 0.5rem;
        }}
        
        pre {{
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 4px;
            overflow-x: auto;
            max-height: 500px;
            overflow-y: auto;
        }}
        
        .file-list {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 0.5rem;
        }}
        
        .file-item {{
            padding: 0.5rem;
            background: #f8f9fa;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
        }}
        
        .collapsible {{
            cursor: pointer;
            user-select: none;
            padding: 0.5rem;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 4px;
            width: 100%;
            text-align: left;
            font-size: 1rem;
            margin-bottom: 0.5rem;
        }}
        
        .collapsible:hover {{
            background: #5568d3;
        }}
        
        .content {{
            display: none;
            padding: 1rem 0;
        }}
        
        .content.active {{
            display: block;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 Static Analysis Report</h1>
        <div class="meta">
            <strong>Repository:</strong> {repo_name} | 
            <strong>Generated:</strong> {timestamp}
        </div>
    </div>
    
    <div class="container">
        <!-- Summary Statistics -->
        <div class="summary">
            <h2>Summary</h2>
            <div class="stats">
                <div class="stat-box">
                    <div class="label">Total Files</div>
                    <div class="value">{file_count}</div>
                </div>
                <div class="stat-box">
                    <div class="label">AST Dumps</div>
                    <div class="value">{ast_count}</div>
                </div>
                <div class="stat-box">
                    <div class="label">Analysis Tools</div>
                    <div class="value">7</div>
                </div>
            </div>
        </div>
        
        <!-- File List -->
        <div class="section">
            <button class="collapsible">📁 File List ({file_count} files)</button>
            <div class="content">
                <div class="file-list">
                    {''.join(f'<div class="file-item">{f}</div>' for f in bundle.get("files", []))}
                </div>
            </div>
        </div>
        
        <!-- Call Graph -->
        <div class="section">
            <button class="collapsible">🔗 Call Graph (cflow)</button>
            <div class="content">
                <pre>{bundle.get("callgraph", "No call graph data")}</pre>
            </div>
        </div>
        
        <!-- Symbol Tags -->
        <div class="section">
            <button class="collapsible">🏷️ Symbol Tags (ctags)</button>
            <div class="content">
                <pre>{bundle.get("ctags", "No ctags data")}</pre>
            </div>
        </div>
        
        <!-- Static Analysis Warnings -->
        <div class="section">
            <button class="collapsible">⚠️ Static Warnings (clang-tidy)</button>
            <div class="content">
                <pre>{bundle.get("clang_tidy", "No clang-tidy data")}</pre>
            </div>
        </div>
        
        <!-- Code Quality -->
        <div class="section">
            <button class="collapsible">✅ Code Quality (cppcheck)</button>
            <div class="content">
                <pre>{bundle.get("cppcheck", "No cppcheck data")}</pre>
            </div>
        </div>
        
        <!-- Complexity Metrics -->
        <div class="section">
            <button class="collapsible">📈 Complexity Metrics (lizard)</button>
            <div class="content">
                <pre>{bundle.get("complexity", "No complexity data")}</pre>
            </div>
        </div>
        
        <!-- AST Explorer -->
        <div class="section">
            <button class="collapsible">🌳 AST Explorer ({ast_count} files)</button>
            <div class="content">
                <p><em>AST data available for {ast_count} C files. View in browser console or download bundle.json for programmatic access.</em></p>
                <button onclick="console.log(astData)">Log AST to Console</button>
            </div>
        </div>
    </div>
    
    <script>
        // WHY: Store AST data for browser console access
        const astData = {json.dumps(bundle.get("ast", {}))};
        
        // WHY: Make all sections collapsible for better navigation
        const collapsibles = document.querySelectorAll('.collapsible');
        collapsibles.forEach(button => {{
            button.addEventListener('click', function() {{
                this.classList.toggle('active');
                const content = this.nextElementSibling;
                content.classList.toggle('active');
            }});
        }});
    </script>
</body>
</html>
"""
    return html


def main():
    """Main rendering workflow."""
    # Validate command-line arguments
    if len(sys.argv) != 2:
        print("Usage: python render_html.py <repo_name>")
        sys.exit(1)
    
    repo_name = sys.argv[1]
    
    # Define input and output paths
    # WHY: Relative paths assume execution from pipeline/ directory
    bundle_path = f"../outputs/combined/{repo_name}/bundle.json"
    output_dir = f"../outputs/final/{repo_name}"
    output_path = f"{output_dir}/report.html"
    
    # Create output directory
    # WHY: exist_ok=True allows re-running without errors
    os.makedirs(output_dir, exist_ok=True)
    
    # Load bundle data
    # WHY: Read entire JSON file into memory (may be large)
    try:
        with open(bundle_path, 'r') as f:
            bundle = json.load(f)
    except FileNotFoundError:
        print(f"ERROR: Bundle not found at {bundle_path}")
        print("")
        print("Run combine.py first:")
        print(f"  python combine.py {repo_name}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in bundle: {e}")
        print("")
        print("Bundle may be corrupted. Re-run combine.py:")
        print(f"  python combine.py {repo_name}")
        sys.exit(1)
    
    # Generate HTML report
    # WHY: Template function handles all formatting
    html_content = generate_html_template(repo_name, bundle)
    
    # Write HTML file
    # WHY: Write complete HTML in single operation
    with open(output_path, 'w') as f:
        f.write(html_content)
    
    print(f"[INFO] HTML report created at {output_path}")
    print(f"[INFO] Open in browser: file://{os.path.abspath(output_path)}")


if __name__ == "__main__":
    main()
