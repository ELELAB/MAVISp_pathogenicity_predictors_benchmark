# Benchmarking of Thresholds for Pathogenicity with GEMME and DeMaSk

## Description

This R script benchmarks thresholds for pathogenicity using genetic variant data, specifically evaluating GEMME and DeMaSk scores. 
It processes multiple CSV files, filters and combines the data based on specified criteria, and generates combined outputs of GEMME and DeMaSk scores.

## Requirements

  - Ensure you have R installed on your system. The code has been tested with R version 4.3.2.
  - Required R packages:
    - base: Core R functions (included with R).
    - utils: Utility functions (included with R).
    - pROC: Tools for visualizing, smoothing, and comparing receiver operating characteristic (ROC) curves. Version 1.18.5.

## Setup
  - Specify the directory path where the dataset comprising simple-mode MAVISp entries with different variants is located.
  - Provide a directory path for storing the combined results.
  - Have your ClinVar interpretation file ready along with its path.
  - Define review statuses as command line arguments.

## Usage

To run the analysis and generate ROC curves for GEMME and DeMaSk scores, execute the `run_ROC_analysis.sh` script. 
This script orchestrates the execution of all necessary scripts (see below) and automates the process.

  1. Ensure all required scripts (see below) are present in your working directory.

  2. Adjust the parameters in the `run_ROC_analysis.sh` script according to your setup.

  3. Execute the following command:
  ```
  bash run_ROC_analysis.sh <result_directory> <review_status> <clinvar_interpretation> <dataset_path>
  ```
  Replace `<result_directory>` with the directory where you want to save the results, and `<review_status>` with the desired review status of
  the ClinVar Classification. For the `<clinvar_interpretation>` use the file that was created containing all the necessary ClinVar interpretations and for the <dataset_path> parse the path to the directory where the results for the proteins including variants are. 

  4. The analysis will run, and ROC curves and depeneding csv files for GEMME and DeMaSk will be generated in the specified result directory.

Example Run of run_ROC_analysis.sh: 
    ```
    bash run_ROC_analysis.sh results_2_3 2,3 clinvar_interpretation_internal_dictionary.txt ../../data/1302024/biorxiv_13022024/simple_mode/dataset_tables/ 
    ```

By running the `run_ROC_analysis.sh` script, you automate the process and streamline the generation of ROC curves, making it convenient to rerun the analysis as needed.

For more details about each script and additional customization options, refer to the sections below.

## Scripts included in the repository:

  1. **extract_data.R**: 
This R script extracts data from CSV files, filters it based on review status, and combines the results.
Usage:
```bash
Rscript extract_data.R <directory_path> <combined_results_directory> <review_status> <clinvar_interpretation>
```

Example:
```
Rscript extract_data.R ../../data/1302024/biorxiv_13022024/simple_mode/dataset_tables/ "result_directory" "review_status" clinvar_interpretation.txt
```

  2. **create_ROC.R**:
This R script creates ROC curves and sensitivity-specificity plots for GEMME and DeMaSk.
Usage:
```
Rscript create_ROC.R <input_file> <ROC_output_file> <sensitivity_specificity_output_file> <sensitivity_specificity_csv_output_file>
```
Example (for GEMME):
```
Rscript create_ROC.R "result_directory/combined_GEMME_values.csv" "result_directory/ROC_GEMME.png" "result_directory/sensitivity_specificity_GEMME.png" "result_directory/sensitivity_specificity_GEMME.csv"
```

  3. **min_d_value.sh**:
This Bash script calculates the minimum value in a specified column of a CSV file and saves the corresponding row to a new file.
Usage:
```
bash min_d_value.sh <csv_file> <column_name> <output_file>
```
Example:
```
bash min_d_value.sh "result_directory/sensitivity_specificity_GEMME.csv" "D" "result_directory/min_d_value_GEMME.csv"
```

  4. **run_ROC_analysis.sh**:
This Bash script orchestrates the execution of the above scripts to perform ROC analysis for GEMME and DeMaSk.
Usage:
```
bash run_ROC_analysis.sh <result_directory> <review_status> <clinvar_interpretation> <dataset_path>
```
Example:
```
bash run_ROC_analysis.sh results_2_3 2,3 clinvar_interpretation.txt ../../data/1302024/biorxiv_13022024/simple_mode/dataset_tables/ 
```

## Specified Inputs and Outputs to Reproduce the Analysis
### Overview
To reproduce the analysis, three specific runs were performed using the run_ROC_analysis.sh script. Each run utilized the same input files but targeted different review statuses. The output of each run is saved in separate result folders.

### Input Files
  - ClinVar Interpretation File: clinvar_interpretation_internal_dictionary.txt
  - Dataset Tables Directory: dataset_tables_june-july2024/
 
### Output Directories 
Each run generates output files in a dedicated results directory:

Run 1:
Command: bash run_ROC_analysis.sh results_review-status-2-3 clinvar_interpretation_internal_dictionary.txt dataset_tables_june-july2024/
Output Directory: results_review-status-2-3
Description: This run targets review statuses 2 and 3.

Run 2:
Command: bash run_ROC_analysis.sh results_review-status-3-4 3,4 clinvar_interpretation_internal_dictionary.txt dataset_tables_june-july2024/
Output Directory: results_review-status-3-4
Description: This run targets review statuses 3 and 4.

Run 3:
Command: bash run_ROC_analysis.sh results_review-status-2-3-4 2,3,4 clinvar_interpretation_internal_dictionary.txt dataset_tables_june-july2024/
Output Directory: results_review-status-2-3-4
Description: This run targets review statuses 2, 3, and 4.

Steps to Reproduce:
  - Ensure that the clinvar_interpretation_internal_dictionary.txt file and the dataset_tables_june-july2024/ directory are available in your working directory and/or that you have their paths ready.
  - Execute each run using the provided commands to generate the respective output directories.
  - The results of each analysis will be saved in the corresponding output directory as specified above.
  - By following these steps, you can reproduce the analysis and obtain the results for each specified review status.
  - The specific output description is provided below.
  

## Output

  - `combined_GEMME_values.csv`: Contains combined GEMME scores for genetic variants meeting specified criteria. Includes details such as protein name, mutation, GEMME score, ClinVar interpretation, and ClinVar review status.
  - `combined_DeMaSk_values.csv`: Contains combined DeMaSk scores for genetic variants meeting specified criteria. Includes details such as protein name, mutation, DeMaSk score, ClinVar interpretation, and ClinVar review status.
  - `results_summary.txt`: Summary file detailing counts of variants at each processing stage.
  - `min_d_value_GEMME.csv`: Contains minimum D values calculated for each protein using GEMME scores. Includes details such as threshold value, sensitivity, specificity, and calculated D value.
  - `min_d_value_DeMaSk.csv`: Contains minimum D values calculated for each protein using DeMaSk scores. Similar to min_d_value_GEMME.csv, it includes columns for threshold value, sensitivity, specificity, and calculated D value.
  - `ROC_GEMME.png`: Plot of the ROC curve generated based on GEMME scores, showing sensitivity-specificity trade-off.
  - `ROC_DeMaSk.png`: Plot of the ROC curve generated based on DeMaSk scores, showing sensitivity-specificity trade-off.
  - `sensitivity_specificity_GEMME.csv`: Contains sensitivity and specificity data based on GEMME scores. Includes details such as threshold value used, sensitivity, specificity, and D value.
  - `sensitivity_specificity_GEMME.png`: Plot of sensitivity and specificity for GEMME.
  - `sensitivity_specificity_DeMaSk.csv`: Contains sensitivity and specificity data based on DeMaSk scores. Includes details such as threshold value used, sensitivity, specificity, and D value.
  - `sensitivity_specificity_DeMaSk.png`: Plot of sensitivity and specificity for DeMaSk.

## Authors:

  - Laura Bauer
  - Matteo Tiberti
