import json

def load_json(file_path):
    """Loads JSON data from a file."""
    with open(file_path, "r") as f:
        return json.load(f)

def get_covered_lines(cobertura_json):
    """Extracts covered lines from Cobertura JSON report."""
    covered_lines = set()
    
    for package in cobertura_json.get("packages", []):
        for cls in package.get("classes", []):
            for line in cls.get("lines", []):  # Use .get() to avoid KeyErrors
                if line.get("hits", 0) > 0:  # Ensure hits key exists
                    covered_lines.add(line["number"])

    return covered_lines

def compute_function_coverage(function_data, covered_lines):
    """Computes coverage percentage for each function."""
    function_coverage = {}

    for func, range_info in function_data.get("functions", {}).items():
        start, end = range_info["start"], range_info["end"]
        total_lines = (end - start) + 1  # Fix off-by-one error
        covered = sum(1 for line in covered_lines if start <= line <= end)

        function_coverage[func] = (covered / total_lines) * 100 if total_lines > 0 else 0

    return function_coverage

def main(cobertura_json_path, function_data_path, output_path=None):
    """Main function to compute function coverage."""
    # Load JSON data
    cobertura_data = load_json(cobertura_json_path)
    function_data = load_json(function_data_path)

    # Get covered lines
    covered_lines = get_covered_lines(cobertura_data)

    # Compute coverage
    function_coverage = compute_function_coverage(function_data, covered_lines)

    # Print results
    print("\n📊 Function Coverage:")
    for func, coverage in sorted(function_coverage.items(), key=lambda x: x[1]):
        print(f"{func}: {coverage:.2f}% covered")

    # Save output if needed
    if output_path:
        with open(output_path, "w") as f:
            json.dump(function_coverage, f, indent=4)
        print(f"\n✅ Coverage data saved to: {output_path}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Compute function coverage from Cobertura JSON and function extraction data.")
    parser.add_argument("--cobertura", required=True, help="Path to Cobertura JSON file")
    parser.add_argument("--functions", required=True, help="Path to extracted functions JSON file")
    parser.add_argument("--output", help="Path to save function coverage JSON (optional)")
    
    args = parser.parse_args()
    main(args.cobertura, args.functions, args.output)
