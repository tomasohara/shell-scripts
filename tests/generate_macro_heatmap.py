#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Creates a unified report for shell macro coverage.
#

"""
Creates a unified report for shell macro coverage.

By default, this script prints a Tab-Separated Values (TSV) report to
standard output, suitable for command-line parsing and CI/CD integration.

It can also generate a full, interactive HTML report using the --web option.
The script reads macro definitions, coverage data, and failure analysis to
produce its reports.
"""

# Standard modules
from json import loads, JSONDecodeError
import re
from collections import defaultdict
import hashlib
import html

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants for switches
COVERAGE_REPORT = "coverage-report"
FAILURE_REPORT = "failure-report"
SOURCE_DIR = "source-dir"
OUTPUT_TSV = "output-tsv"
OUTPUT_WEB = "output-web"


# Environment Variables
EXTENDED_MACROS_OUTPUT = system.getenv_bool(
    "EXTENDED_MACROS_OUTPUT", False,
    description="Prints extended output with macros coverage and testing details"
)

# Constants
TL = debug.TL

class HeatmapGenerator:
    """Helper class for generating macro coverage reports."""

    def __init__(self, source_dir, output_file=None):
        """Initializer: Sets up the generator with necessary paths."""
        debug.trace(4, f"HeatmapGenerator.__init__({self}) =>")
        self.source_dir = source_dir
        self.output_file = output_file
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    # --- DATA LOADING AND PROCESSING ---

    def load_json_file(self, path: str) -> list | dict:
        """Loads and parses a JSON file using mezcla helpers."""
        file_content = system.read_entire_file(path, encoding='utf-8')
        if not file_content:
            debug.trace(4, f"Warning: File is empty or could not be read: {path}")
            return []
        try:
            return loads(file_content)
        except JSONDecodeError as e:
            debug.trace(4, f"Error: Could not parse JSON file at {path}. Details: {e}")
            return []

    def get_all_macros(self) -> dict:
        """Parses all *tomohara*aliases.bash files to find every macro definition."""
        debug.trace(4, f"Scanning '{self.source_dir}' for all macro definitions...")
        macros = {}
        func_pattern = re.compile(r"^(?:function\s+)?([\w.-]+)\s*\(\)\s*\{")
        alias_pattern = re.compile(r"^alias\s+([\w.-]+)=")
        target_pattern = '*tomohara*aliases.bash'

        find_command = f"find {self.source_dir} -type f -name '{target_pattern}'"
        matching_files_str = gh.run(find_command)
        
        if not matching_files_str:
            debug.trace(4, f"Warning: No files matching '{target_pattern}' found in '{self.source_dir}'.")
            return {}

        for file_path in matching_files_str.splitlines():
            file_content = system.read_entire_file(file_path, encoding='utf-8', errors='ignore')
            if not file_content:
                continue

            for line in file_content.splitlines():
                stripped_line = line.strip()
                func_match = func_pattern.match(stripped_line)
                alias_match = alias_pattern.match(stripped_line)
                if func_match:
                    macros[func_match.group(1)] = {"file": system.absolute_path(file_path), "type": "function"}
                elif alias_match:
                    macros[alias_match.group(1)] = {"file": system.absolute_path(file_path), "type": "alias"}

        debug.trace(4, f"Found {len(macros)} total macro definitions.")
        return macros

    def merge_data(self, all_macros: dict, coverage_data: list, failure_data: list) -> list:
        """Merges all data sources into a single, comprehensive list of macro objects."""
        debug.trace(4, "Merging coverage and failure data...")
        coverage_map = {item['macro']: item for item in coverage_data}
        failure_map = {item['macro']: item for item in failure_data}
        
        merged_list = []
        for name, info in all_macros.items():
            macro_obj = {
                "macro": name,
                "macro_type": info['type'],
                "definition_file": info['file']
            }
            
            if name in coverage_map:
                macro_obj.update(coverage_map[name])
            else:
                macro_obj.update({"percent_covered": None, "covered_lines": 0, "total_lines": 0, "status": "not_tested"})
                
            if name in failure_map:
                failure_info = failure_map[name]
                macro_obj.update({"total_uses": failure_info.get('total', 0), "bad_hits": failure_info.get('bad', 0), "failure_rate": failure_info.get('pct_bad', 0.0), "test_files": failure_info.get('failing_in_files', [])})
            else:
                macro_obj.update({"total_uses": 0, "bad_hits": 0, "failure_rate": 0.0, "test_files": []})
                
            merged_list.append(macro_obj)
            
        debug.trace(4, f"Successfully merged data for {len(merged_list)} macros.")
        return merged_list

    # --- HTML GENERATION HELPERS ---

    def get_status_style(self, status: str) -> tuple[str, str, str]:
        """Returns Tailwind CSS classes for background, text, and solid bar colors based on macro status."""
        styles = {
            'well_tested': ("bg-green-100", "text-green-800", "bg-green-500"),
            'insufficiently_tested': ("bg-yellow-100", "text-yellow-800", "bg-yellow-400"),
            'untested': ("bg-red-100", "text-red-800", "bg-red-500"),
            'not_tested': ("bg-gray-200", "text-gray-800", "bg-gray-400"),
        }
        return styles.get(status, ("bg-gray-100", "text-gray-600", "bg-gray-300"))

    def get_file_tag_color(self, filename: str) -> str:
        """Generates a consistent, differentiable shade of blue for a given filename string."""
        hash_val = int(hashlib.md5(filename.encode('utf-8')).hexdigest(), 16)
        hue = 180 + (hash_val % 90) 
        saturation = 60 + (hash_val % 20)
        lightness = 91 + (hash_val % 5)
        return f"hsl({hue}, {saturation}%, {lightness}%)"

    # --- REPORT GENERATORS ---

    def generate_tsv_report(self, data: list) -> str:
        """Generates a simple TSV report and returns it as a string."""
        debug.trace(4, "Generating TSV report...")
        
        header = [
            "Macro", "Status", "CoveragePct", "TotalUses", 
            "FailingHits", "FailureRatePct", "Type", "DefinitionFile"
        ]
        
        rows = ["\t".join(header)]
        
        sorted_data = sorted(data, key=lambda x: x['macro'].lower())

        for macro in sorted_data:
            coverage_val = macro.get("percent_covered")
            coverage_str = f"{coverage_val:.2f}" if coverage_val is not None else "N/A"
            
            failure_rate_val = macro.get("failure_rate", 0.0)
            failure_rate_str = f"{failure_rate_val:.2f}"

            row_data = [
                macro.get('macro', 'N/A'),
                macro.get('status', 'not_tested'),
                coverage_str,
                str(macro.get('total_uses', 0)),
                str(macro.get('bad_hits', 0)),
                failure_rate_str,
                macro.get('macro_type', 'N/A'),
                gh.basename(macro.get('definition_file', 'N/A'))
            ]
            rows.append("\t".join(row_data))
            
        return "\n".join(rows)

    # In the HeatmapGenerator class

    def generate_tsv_heatmap_report(self, data: list) -> str:
        """Generates a TSV heatmap summary of macros by file, usage, and status."""
        debug.trace(4, "Generating TSV heatmap summary report...")

        bins = {
            "High (50+)": lambda u: u >= 50,
            "Medium (10-49)": lambda u: 10 <= u < 50,
            "Low (1-9)": lambda u: 1 <= u < 10,
            "Unused (0)": lambda u: u == 0
        }
        statuses = ['well_tested', 'insufficiently_tested', 'untested', 'not_tested']
        
        # This part remains the same: gather the counts that exist.
        summary_data = defaultdict(lambda: defaultdict(lambda: defaultdict(int)))
        for macro in data:
            file = gh.basename(macro['definition_file'])
            uses = macro.get('total_uses', 0)
            status = macro.get('status', 'not_tested')

            for bin_name, check in bins.items():
                if check(uses):
                    summary_data[file][bin_name][status] += 1
                    break
        
        header = ["SourceFile", "UsageBin", "Status", "MacroCount"]
        rows = ["\t".join(header)]
        
        # --- MODIFICATION START ---
        # Instead of iterating through what we found, iterate through ALL possibilities.
        all_files = sorted(summary_data.keys()) # Get all unique files that have macros
        all_bins = list(bins.keys())
        
        for file in all_files:
            for bin_name in all_bins:
                for status in statuses:
                    # Look up the count. It will be 0 if the combination doesn't exist.
                    count = summary_data[file][bin_name][status]
                    rows.append(f"{file}\t{bin_name}\t{status}\t{count}")
        # --- MODIFICATION END ---

        return "\n".join(rows)
    
    def generate_heatmap_view(self, data: list) -> str:
        """Generates the HTML for the 2D summary heatmap view (Tab 1)."""
        
        bins = {"High (50+)": lambda u: u >= 50, "Medium (10-49)": lambda u: 10 <= u < 50, "Low (1-9)": lambda u: 1 <= u < 10, "Unused (0)": lambda u: u == 0}
        bin_order = ["High (50+)", "Medium (10-49)", "Low (1-9)", "Unused (0)"]
        status_order = ['well_tested', 'insufficiently_tested', 'untested', 'not_tested']
        status_map = {'well_tested': 'Well Tested', 'insufficiently_tested': 'Insufficiently Tested', 'untested': 'Untested', 'not_tested': 'Not Tested'}

        binned_data = defaultdict(lambda: defaultdict(list))
        source_files = sorted(list(set(m['definition_file'] for m in data)))

        for macro in data:
            file = macro['definition_file']
            uses = macro.get('total_uses', 0)
            for bin_name, check in bins.items():
                if check(uses):
                    binned_data[file][bin_name].append(macro)
                    break

        table_rows = []
        for i, file in enumerate(source_files):
            row_id = f"heatmap-row-{i}"
            
            table_rows.append('<tr class="border-t">')
            table_rows.append(f'<td class="p-3 font-mono text-sm font-semibold">{gh.basename(file)}</td>')
            
            for bin_name in bin_order:
                macros_in_bin = binned_data[file][bin_name]
                count = len(macros_in_bin)
                
                cell_content = ""
                onclick_attr = ""
                cell_class = "p-3 text-center transition-shadow"
                if count > 0:
                    cell_class += " clickable-cell"
                    onclick_attr = f"onclick=\"toggleDetails('{row_id}', '{bin_name}', this)\""
                    status_counts = defaultdict(int)
                    for m in macros_in_bin:
                        status_counts[m.get('status', 'not_tested')] += 1
                    
                    bar_html = '<div class="h-2.5 w-full flex rounded-full overflow-hidden bg-gray-200 my-1">'
                    for status in status_order:
                        if status_counts[status] > 0:
                            percentage = (status_counts[status] / count) * 100
                            _, _, bar_color = self.get_status_style(status)
                            bar_html += f'<div class="{bar_color}" style="width: {percentage}%" title="{status.replace("_", " ").title()}: {status_counts[status]}"></div>'
                    bar_html += '</div>'
                    
                    cell_content = f'<span class="text-xl font-bold">{count}</span>{bar_html}'
                else:
                    cell_content = '<span class="text-gray-400">0</span>'
                
                table_rows.append(f'<td class="{cell_class}" {onclick_attr}>{cell_content}</td>')
            table_rows.append('</tr>')
            
            details_html = f'<tr id="{row_id}" class="details-row" style="display: none;"><td colspan="{len(bin_order) + 1}" class="p-4 bg-gray-50">'
            for bin_name in bin_order:
                macros_in_bin = sorted(binned_data[file][bin_name], key=lambda m: m['macro'])
                
                details_html += f'<div id="{row_id}-{bin_name}" class="details-content" style="display: none;">'
                if macros_in_bin:
                    status_counts = defaultdict(int)
                    macro_tags = []
                    for m in macros_in_bin:
                        status = m.get('status', 'not_tested')
                        status_counts[status] += 1
                        bg_class, text_class, _ = self.get_status_style(status)
                        anchor_id = f"macro-{html.escape(m['macro'])}"
                        tag_html = f'''<a href="#{anchor_id}"
                                           onclick="switchToPhonebookAndHighlight('{anchor_id}')"
                                           class="macro-tag inline-block {bg_class} {text_class} border border-black/10 rounded px-2 py-0.5 text-xs font-mono hover:scale-105 hover:shadow-md transition-transform"
                                           data-status="{status}"
                                           title="Status: {status.replace('_', ' ').title()}">
                                           {html.escape(m["macro"])}
                                       </a>'''
                        macro_tags.append(tag_html)
                    macro_list = ''.join(macro_tags)

                    filter_buttons_html = '<div class="flex items-center flex-wrap gap-2 mb-3"><span class="text-sm font-semibold mr-2">Filter:</span>'
                    filter_buttons_html += f'<button data-status="all" onclick="filterDetails(\'{row_id}\', \'{bin_name}\', \'all\')" class="filter-btn text-xs px-2 py-1 rounded-md">All ({len(macros_in_bin)})</button>'
                    for status_key in status_order:
                        if status_counts[status_key] > 0:
                            count = status_counts[status_key]
                            status_name = status_map[status_key]
                            bg_class, text_class, _ = self.get_status_style(status_key)
                            filter_buttons_html += f'<button data-status="{status_key}" onclick="filterDetails(\'{row_id}\', \'{bin_name}\', \'{status_key}\')" class="filter-btn text-xs px-2 py-1 rounded-md {bg_class} {text_class}">{status_name} ({count})</button>'
                    filter_buttons_html += '</div>'

                    details_html += f'<h4 class="font-bold mb-2">Macros in "{bin_name}" for {gh.basename(file)}:</h4>{filter_buttons_html}<div class="flex flex-wrap gap-1 items-start">{macro_list}</div>'
                details_html += '</div>'
            details_html += '</td></tr>'
            table_rows.append(details_html)
            
        return f"""
        <div class="p-4 sm:p-6 lg:p-8 bg-gray-50 w-full">
            <div class="bg-white p-4 rounded-lg shadow-md overflow-x-auto">
                <table class="min-w-full border-collapse">
                    <thead><tr class="border-b-2 border-gray-300">
                        <th class="p-3 text-left text-sm font-semibold text-gray-600 uppercase">Source File</th>
                        {''.join(f'<th class="p-3 text-center text-sm font-semibold text-gray-600 uppercase">{b}</th>' for b in bin_order)}
                    </tr></thead>
                    <tbody>{''.join(table_rows)}</tbody>
                </table>
            </div>
        </div>
        """

    def generate_phonebook_view(self, data: list) -> str:
        """Generates the HTML for the two-column phonebook view (Tab 2)."""
        macros_by_letter = defaultdict(list)
        source_files = sorted(list(set(m['definition_file'] for m in data)))
        file_colors = {f: self.get_file_tag_color(f) for f in source_files}

        for macro in sorted(data, key=lambda x: x['macro'].lower()):
            first_letter = macro['macro'][0].upper()
            if 'A' <= first_letter <= 'Z': 
                macros_by_letter[first_letter].append(macro)
            else: 
                macros_by_letter['#'].append(macro)

        alphabet = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        file_options = ''.join(f'<option value="{gh.basename(f)}">{gh.basename(f)}</option>' for f in source_files)
        
        controls_html = f"""
        <div class="phonebook-controls w-full md:w-72 lg:w-80 flex-shrink-0 border-r bg-white p-4 space-y-6">
            <div>
                <label for="search-box" class="block text-sm font-medium text-gray-700">Search Macros</label>
                <input type="text" id="search-box" onkeyup="filterMacros()" placeholder="Enter macro name..." class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm">
            </div>
            <div>
                <label for="file-filter" class="block text-sm font-medium text-gray-700">Filter by File</label>
                <select id="file-filter" onchange="filterMacros()" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm">
                    <option value="all">All Files</option>
                    {file_options}
                </select>
            </div>
            <nav class="flex flex-wrap gap-1 justify-center">
                {''.join(f'<a href="#section-{letter}" class="nav-link {"" if letter in macros_by_letter else "disabled"}">{letter}<span class="count-badge" data-total="{len(macros_by_letter.get(letter, []))}">{len(macros_by_letter.get(letter, []))}</span></a>' for letter in alphabet)}
            </nav>
        </div>
        """

        main_content = []
        for letter in alphabet:
            if letter in macros_by_letter:
                main_content.append(f'<section id="section-{letter}" class="mb-12"><h2 class="text-3xl font-bold border-b pb-2 mb-6">{letter}</h2><div class="grid grid-cols-1 lg:grid-cols-2 2xl:grid-cols-3 gap-6">')
                for macro in macros_by_letter[letter]:
                    bg_color, _, _ = self.get_status_style(macro.get('status'))
                    def_file_short = gh.basename(macro['definition_file'])
                    file_color = file_colors[macro['definition_file']]
                    anchor_id = f"macro-{html.escape(macro['macro'])}"
                    test_files_html = "None"
                    if macro['test_files']:
                        files_list = ''.join(f'<li class="truncate" title="{f}"><code>{gh.basename(f)}</code></li>' for f in macro['test_files'])
                        test_files_html = f'<ul class="list-disc list-inside text-xs mt-1">{files_list}</ul>'
                    coverage_val = macro.get("percent_covered")
                    coverage_str = f"{coverage_val:.2f}%" if coverage_val is not None else "N/A"
                    status_str = macro.get('status', 'unknown').replace('_', ' ').title()
                    main_content.append(f"""
                    <div id="{anchor_id}" class="macro-card rounded-lg shadow-md p-4 {bg_color}" data-file="{def_file_short}" data-name="{macro['macro'].lower()}">
                        <div class="flex justify-between items-start"><h3 class="text-xl font-bold text-gray-900 break-all"><code>{macro['macro']}</code></h3><span class="text-xs font-semibold text-gray-500 bg-white/60 px-2 py-1 rounded">{macro['macro_type']}</span></div>
                        <p class="text-xs font-semibold px-2 py-1 rounded-full mt-2 inline-block" style="background-color: {file_color}; color: #0f172a;"><code>{def_file_short}</code></p>
                        <div class="mt-4 space-y-3 text-sm">
                            <div class="p-3 bg-white/70 backdrop-blur-sm rounded-md"><h4 class="font-semibold text-gray-700">Coverage Stats</h4><p><strong>Status:</strong> <span class="font-semibold">{status_str}</span></p><p><strong>Coverage:</strong> {coverage_str}</p><p><strong>Lines Covered:</strong> {macro.get('covered_lines', 'N/A')} / {macro.get('total_lines', 'N/A')}</p></div>
                            <div class="p-3 bg-white/70 backdrop-blur-sm rounded-md"><h4 class="font-semibold text-gray-700">Usage Stats</h4><p><strong>Total Uses in Tests:</strong> {macro.get('total_uses', 'N/A')}</p><p><strong>Failing Hits:</strong> {macro.get('bad_hits', 'N/A')}</p><p><strong>Files with Failures:</strong> {test_files_html}</p></div>
                        </div>
                    </div>""")
                main_content.append('</div></section>')
        
        main_html = f"<div class='phonebook-scroll-pane flex-grow overflow-y-auto bg-gray-50'><main class='p-4 sm:p-6 lg:p-8'>{''.join(main_content)}</main></div>"
        return controls_html + main_html

    def generate_unified_report(self, data: list):
        """Generates the final, self-contained HTML file with both tabs."""
        debug.trace(4, "Generating unified HTML report...")
        
        total_macros = len(data)
        heatmap_view_html = self.generate_heatmap_view(data)
        phonebook_view_html = self.generate_phonebook_view(data)
        
        html_template = f"""
        <!DOCTYPE html>
        <html lang="en" class="scroll-smooth">
        <head>
            <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Unified Macro Coverage Report</title>
            <script src="https://cdn.tailwindcss.com"></script>
            <style>
                body {{ font-family: 'Inter', sans-serif; }}
                @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap');
                
                .tab-button {{ padding: 0.75rem 1.5rem; font-weight: 600; cursor: pointer; border-bottom: 3px solid transparent; transition: all 0.2s; }}
                .tab-button.active {{ color: #2563eb; border-bottom-color: #2563eb; }}
                
                .tab-content {{ display: none !important; }}
                .tab-content.active {{ display: flex !important; }}
                
                .main-container {{ height: calc(100vh - 128px); }}

                .clickable-cell {{ cursor: pointer; }}
                .clickable-cell:hover {{ background-color: #f3f4f6; }}
                .selected-cell {{ box-shadow: inset 0 0 0 3px #3b82f6; }}
                
                .filter-btn {{ border: 1px solid #d1d5db; transition: all 0.15s ease-in-out; }}
                .filter-btn.active {{ border-width: 2px; border-color: #2563eb; transform: scale(1.05); }}
                
                .macro-card.highlight {{ transform: scale(1.02); box-shadow: 0 0 0 4px #2563eb; }}
                
                .nav-link {{ display: inline-flex; align-items: center; padding: 0.3rem 0.6rem; margin: 0.125rem; border-radius: 0.375rem; background-color: #f3f4f6; color: #374151; font-weight: 500; text-decoration: none; transition: all 0.2s; }}
                .nav-link:hover {{ background-color: #e5e7eb; }}
                .nav-link.disabled {{ background-color: #f9fafb; color: #d1d5db; cursor: not-allowed; }}
                .count-badge {{ font-size: 0.7rem; font-weight: 700; margin-left: 0.4rem; background-color: #e5e7eb; color: #4b5563; padding: 0.1rem 0.4rem; border-radius: 9999px; }}
            </style>
        </head>
        <body class="text-gray-800 bg-white">
            <div class="flex flex-col h-screen">
                <header class="p-4 sm:p-6 shadow-md z-40 w-full">
                    <div class="container mx-auto">
                        <h1 class="text-3xl font-bold text-gray-900">Unified Macro Coverage Report</h1>
                        <p class="text-md text-gray-600 mt-1">Analyzed <span class="font-bold text-blue-600">{total_macros}</span> macros.</p>
                        <div class="flex items-center flex-wrap gap-x-4 gap-y-1 mt-3 text-sm">
                            <span class="font-semibold">Legend:</span>
                            <div class="flex items-center"><div class="w-4 h-4 mr-1.5 rounded-sm bg-green-500 border"></div>Well Tested</div>
                            <div class="flex items-center"><div class="w-4 h-4 mr-1.5 rounded-sm bg-yellow-400 border"></div>Insufficiently Tested</div>
                            <div class="flex items-center"><div class="w-4 h-4 mr-1.5 rounded-sm bg-red-500 border"></div>Untested</div>
                            <div class="flex items-center"><div class="w-4 h-4 mr-1.5 rounded-sm bg-gray-400 border"></div>Not Tested</div>
                        </div>
                    </div>
                </header>
                <div class="border-b border-gray-200 sticky top-0 z-30 bg-white">
                    <div class="container mx-auto">
                        <nav class="-mb-px flex" id="tab-nav">
                            <button class="tab-button active" onclick="switchTab('heatmap')">Heatmap</button>
                            <button class="tab-button" onclick="switchTab('phonebook')">Phonebook</button>
                        </nav>
                    </div>
                </div>
                <div class="main-container flex-grow">
                    <div id="heatmap-content" class="tab-content active w-full">{heatmap_view_html}</div>
                    <div id="phonebook-content" class="tab-content w-full h-full flex-col md:flex-row">{phonebook_view_html}</div>
                </div>
            </div>
            <script>
                let activeDetails = {{ row: null, bin: null, cell: null }};
                function switchTab(tabName) {{
                    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
                    document.getElementById(tabName + '-content').classList.add('active');
                    document.querySelectorAll('#tab-nav .tab-button').forEach(btn => btn.classList.toggle('active', btn.textContent.toLowerCase() === tabName));
                }}
                function toggleDetails(rowId, binName, cellElement) {{
                    if (activeDetails.cell && activeDetails.cell !== cellElement) {{ activeDetails.cell.classList.remove('selected-cell'); }}
                    const detailsRow = document.getElementById(rowId);
                    const targetContent = document.getElementById(`${{rowId}}-${{binName}}`);
                    const allContentsInRow = detailsRow.querySelectorAll('.details-content');
                    allContentsInRow.forEach(c => {{ if (c.id !== targetContent.id) c.style.display = 'none'; }});
                    if (targetContent.style.display !== 'none') {{
                        detailsRow.style.display = 'none';
                        targetContent.style.display = 'none';
                        cellElement.classList.remove('selected-cell');
                        activeDetails = {{ row: null, bin: null, cell: null }};
                    }} else {{
                        cellElement.classList.add('selected-cell');
                        detailsRow.style.display = 'table-row';
                        targetContent.style.display = 'block';
                        activeDetails = {{ row: rowId, bin: binName, cell: cellElement }};
                        filterDetails(rowId, binName, 'all');
                    }}
                }}
                function filterDetails(rowId, binName, statusToFilter) {{
                    const detailContent = document.getElementById(`${{rowId}}-${{binName}}`);
                    const macroTags = detailContent.querySelectorAll('.macro-tag');
                    const filterButtons = detailContent.querySelectorAll('.filter-btn');
                    filterButtons.forEach(btn => {{ btn.classList.toggle('active', btn.dataset.status === statusToFilter); }});
                    macroTags.forEach(tag => {{
                        tag.style.display = (statusToFilter === 'all' || tag.dataset.status === statusToFilter) ? 'inline-block' : 'none';
                    }});
                }}
                function switchToPhonebookAndHighlight(anchorId) {{
                    switchTab('phonebook');
                    setTimeout(() => {{
                        const element = document.getElementById(anchorId);
                        if (element) {{
                            document.querySelectorAll('.macro-card.highlight').forEach(card => card.classList.remove('highlight'));
                            const scrollPane = document.querySelector('.phonebook-scroll-pane');
                            scrollPane.scrollTo({{ top: element.offsetTop - scrollPane.offsetTop - 30, behavior: 'smooth' }});
                            element.classList.add('highlight');
                            setTimeout(() => element.classList.remove('highlight'), 2500);
                        }}
                    }}, 100);
                }}
                function filterMacros() {{
                    const searchTerm = document.getElementById('search-box').value.toLowerCase();
                    const selectedFile = document.getElementById('file-filter').value;
                    const cards = document.querySelectorAll('.macro-card');
                    const sections = document.querySelectorAll('.phonebook-scroll-pane main section');
                    const navLinks = document.querySelectorAll('.phonebook-controls nav .nav-link');
                    const visibleMacrosByLetter = {{}};
                    cards.forEach(card => {{
                        const macroName = card.getAttribute('data-name');
                        const fileName = card.getAttribute('data-file');
                        const searchMatch = macroName.includes(searchTerm);
                        const fileMatch = selectedFile === 'all' || fileName === selectedFile;
                        if (searchMatch && fileMatch) {{
                            card.style.display = 'block';
                            const firstLetter = macroName[0].toUpperCase();
                            const letterKey = (firstLetter >= 'A' && firstLetter <= 'Z') ? firstLetter : '#';
                            visibleMacrosByLetter[letterKey] = (visibleMacrosByLetter[letterKey] || 0) + 1;
                        }} else {{
                            card.style.display = 'none';
                        }}
                    }});
                    sections.forEach(section => {{
                        const visibleCards = section.querySelectorAll('.macro-card[style*="display: block"]');
                        section.style.display = visibleCards.length > 0 ? 'block' : 'none';
                    }});
                    navLinks.forEach(link => {{
                        const letter = link.textContent.charAt(0);
                        const countBadge = link.querySelector('.count-badge');
                        const totalCount = parseInt(countBadge.getAttribute('data-total'));
                        const visibleCount = visibleMacrosByLetter[letter] || 0;
                        countBadge.textContent = visibleCount;
                        link.classList.toggle('disabled', visibleCount === 0);
                    }});
                }}
                document.addEventListener('DOMContentLoaded', () => {{ switchTab('heatmap'); }});
            </script>
        </body>
        </html>
        """
        
        system.write_file(self.output_file, html_template, skip_newline=True)
        debug.trace(4, f"Unified report generation complete. Output at: {self.output_file}")


class Script(Main):
    """Adhoc script class (no I/O loop, just run calls)"""
    coverage_report = ""
    failure_report = ""
    source_dir = ""

    # Paths for different output formats
    tsv_output_file = ""
    web_output_file = ""
    
    helper = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace(4, f"Script.setup({self}) =>")
        # Input options
        self.coverage_report = self.get_parsed_option(COVERAGE_REPORT, self.coverage_report)
        self.failure_report = self.get_parsed_option(FAILURE_REPORT, self.failure_report)
        self.source_dir = self.get_parsed_option(SOURCE_DIR, self.source_dir)
        
        # Output options
        self.tsv_output_file = self.get_parsed_option(OUTPUT_TSV, self.tsv_output_file)
        self.web_output_file = self.get_parsed_option(OUTPUT_WEB, self.web_output_file)

        debug.assertion(self.coverage_report, "Coverage report path must be provided.")
        debug.assertion(self.failure_report, "Failure report path must be provided.")
        debug.assertion(self.source_dir, "Source directory path must be provided.")
        
        self.helper = HeatmapGenerator(self.source_dir, self.web_output_file)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Main processing step, orchestrates data loading and report generation."""
        debug.trace(4, f"Script.run_main_step({self}) =>")
        
        # --- 1. Data Loading and Merging ---
        coverage_data = self.helper.load_json_file(self.coverage_report)
        failure_data = self.helper.load_json_file(self.failure_report)
        
        if not coverage_data and not failure_data:
            debug.trace(4, "Error: Both report files failed to load. Aborting.")
            return
            
        all_macros = self.helper.get_all_macros()
        if not all_macros:
            debug.trace(4, "Error: No macros found in the source directory. Aborting.")
            return
            
        merged_data = self.helper.merge_data(all_macros, coverage_data, failure_data)
        
        # --- 2. Output Generation Logic ---

        # Priority 1: Generate Web Report if requested
        if self.web_output_file:
            debug.trace(4, f"Web report requested. Generating HTML at: {self.web_output_file}")
            # Ensure the helper has the correct output file path
            self.helper.output_file = self.web_output_file
            self.helper.generate_unified_report(merged_data)
        
        # Priority 2: Generate TSV (either to file or stdout)
        else:
            # Check for the environment variable to determine output detail level
            if EXTENDED_MACROS_OUTPUT:
                debug.trace(4, "EXTENDED_MACROS_OUTPUT is set. Generating detailed TSV report.")
                tsv_output = self.helper.generate_tsv_report(merged_data)
            else:
                debug.trace(4, "Generating simple TSV heatmap summary.")
                tsv_output = self.helper.generate_tsv_heatmap_report(merged_data)
            
            # If an output file for TSV is specified, write to it
            if self.tsv_output_file:
                debug.trace(4, f"TSV file output requested. Writing to: {self.tsv_output_file}")
                system.write_file(self.tsv_output_file, tsv_output, skip_newline=True)
                debug.trace(4, "TSV report generation complete.")
            # Default: Print TSV to standard output
            else:
                debug.trace(4, "Defaulting to TSV output on stdout.")
                print(tsv_output)


def main():
    """Entry point"""
    app = Script(
        description=__doc__,
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (COVERAGE_REPORT, "Path to the JSON coverage report."),
            (FAILURE_REPORT, "Path to the JSON failure analysis report."),
            (SOURCE_DIR, "Path to the directory with .bash macro definition files."),
            (OUTPUT_TSV, "Path to save the TSV report to a file."),
            (OUTPUT_WEB, "Path to save the HTML web report to a file.")
        ])
    app.run()

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()
