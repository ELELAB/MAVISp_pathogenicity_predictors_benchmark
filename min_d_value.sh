#!/bin/bash

# Check if a file is provided as an argument
if [ $# -lt 3 ]; then
    echo "Usage: $0 <csv_file> <column_name> <output_file>"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "File '$1' not found!"
    exit 1
fi

# Set variables
input_file="$1"
column_name="$2"
output_file="$3"

# Check if the column name exists in the header
header=$(head -n 1 "$input_file")
if ! echo "$header" | grep -qw "$column_name"; then
    echo "Column '$column_name' not found in the header of '$input_file'."
    exit 1
fi

# Get the column number based on the column name
column_number=$(echo "$header" | tr ',' '\n' | grep -nw "$column_name" | cut -d':' -f1)

# Run awk command to find the minimum value in the specified column
min_value=$(awk -F',' -v col="$column_number" 'NR>1 {if (!min || $col<min) {min=$col; row=$0}} END {print min}' "$input_file")

# Get the entire row where the minimum value is found
min_row=$(grep "$min_value" "$input_file")

# Save the minimum row to a new CSV file
echo "$header" > "$output_file"
echo "$min_row" >> "$output_file"

echo "Minimum value in column '$column_name': $min_value"
echo "Row with the minimum value saved to '$output_file'"
