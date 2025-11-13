"""
Check Dart files for Firestore queries that might need indexes
"""
import os
import re

def find_dart_files(directory):
    """Find all .dart files in directory"""
    dart_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def check_file_for_queries(filepath):
    """Check a file for Firestore queries that might need indexes"""
    potential_issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
            # Look for queries with where + orderBy
            where_pattern = r'\.where\([^)]+\)'
            order_pattern = r'\.orderBy\([^)]+\)'
            
            # Check if file has both where and orderBy
            has_where = re.search(where_pattern, content)
            has_order = re.search(order_pattern, content)
            
            if has_where and has_order:
                # Extract the actual queries for review
                lines = content.split('\n')
                for i, line in enumerate(lines, 1):
                    if '.where(' in line or '.orderBy(' in line:
                        potential_issues.append((filepath, i, line.strip()))
    
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
    
    return potential_issues

def main():
    print("🔍 Checking Firestore Queries for Potential Index Requirements")
    print("=" * 70)
    
    lib_directory = 'lib'
    if not os.path.exists(lib_directory):
        print("❌ 'lib' directory not found. Run this from project root.")
        return
    
    dart_files = find_dart_files(lib_directory)
    print(f"📁 Found {len(dart_files)} Dart files to check\n")
    
    all_issues = []
    for filepath in dart_files:
        issues = check_file_for_queries(filepath)
        all_issues.extend(issues)
    
    if not all_issues:
        print("✅ No obvious query issues found!")
        return
    
    print(f"⚠️  Found {len(all_issues)} potential queries that might need indexes:\n")
    
    # Group by file
    files_with_issues = {}
    for filepath, line_num, line in all_issues:
        rel_path = filepath.replace('lib\\', '').replace('lib/', '')
        if rel_path not in files_with_issues:
            files_with_issues[rel_path] = []
        files_with_issues[rel_path].append((line_num, line))
    
    for filepath, issues in files_with_issues.items():
        print(f"\n📄 {filepath}")
        print("-" * 70)
        for line_num, line in issues:
            print(f"  Line {line_num}: {line}")
    
    print("\n" + "=" * 70)
    print("💡 Tips:")
    print("   - Not all of these NEED indexes")
    print("   - Run your app and check console for actual errors")
    print("   - Click the URLs in error messages to auto-create indexes")
    print("   - Indexes are only needed for queries with:")
    print("     • where() + orderBy() on different fields")
    print("     • arrayContains + orderBy()")
    print("     • Multiple where() + orderBy()")
    print("=" * 70)

if __name__ == '__main__':
    main()
