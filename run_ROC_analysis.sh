#!/bin/bash

# Check if the result directory and review status are provided as arguments
if [ $# -ne 4 ]; then
    echo "Usage: $0 <result_directory> <review_status> <clinvar_interpretation> <dataset_path>"
    exit 1
fi

# Assign the result directory and review status to variables
result_dir="$1"
review_status="$2"
clinvar_interpretation="$3"
dataset_path="$4"

# Run the first R script to extract data with the review status
Rscript extract_data.R "$dataset_path" "$result_dir" "$review_status" "$clinvar_interpretation"

# Run the second R script to create ROC for GEMME
Rscript create_ROC.R "$result_dir"/combined_GEMME_values.csv "$result_dir"/ROC_GEMME.png "$result_dir"/sensitivity_specificity_GEMME.png "$result_dir"/sensitivity_specificity_GEMME.csv

# Print the count of rows for the combined GEMME file
echo "Count of rows in combined_GEMME_values.csv:"
wc -l < "$result_dir"/combined_GEMME_values.csv

# Run the third R script to create ROC for DeMaSk
Rscript create_ROC.R "$result_dir"/combined_DeMaSk_values.csv "$result_dir"/ROC_DeMaSk.png "$result_dir"/sensitivity_specificity_DeMaSk.png "$result_dir"/sensitivity_specificity_DeMaSk.csv

# Print the count of rows for the combined DeMaSk file
echo "Count of rows in combined_DeMaSk_values.csv:"
wc -l < "$result_dir"/combined_DeMaSk_values.csv

# Run the min_d_value.sh script for GEMME
bash min_d_value.sh "$result_dir"/sensitivity_specificity_GEMME.csv D "$result_dir"/min_d_value_GEMME.csv

# Run the min_d_value.sh script for DeMaSk
bash min_d_value.sh "$result_dir"/sensitivity_specificity_DeMaSk.csv D "$result_dir"/min_d_value_DeMaSk.csv
