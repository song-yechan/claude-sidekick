#!/bin/bash
# Auto-format Dart files after edit

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; data=json.load(sys.stdin); print(data.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

# Check if it's a Dart file
if [[ "$FILE_PATH" == *.dart ]]; then
    # Format the file
    dart format "$FILE_PATH" 2>/dev/null
fi

exit 0
