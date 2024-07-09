Description
================

Benchmarking of thresholds for pathogenicity with GEMME and DeMaSk

To Run the Analysis:
====================

To run the analysis and generate ROC curves for the GEMME and DeMaSk scores, you only need to execute the `run_ROC_analysis.sh` script.
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
    bash run_ROC_analysis.sh results_2_3 2,3 clinvar_interpretation.txt ../../data/1302024/biorxiv_13022024/simple_mode/dataset_tables/ 
    ```

By running the `run_ROC_analysis.sh` script, you automate the process and streamline the generation of ROC curves, 
making it convenient to rerun the analysis as needed.

For more details about each script and additional customization options, refer to the sections below.

Scripts Included:
------------------
1. **extract_data.R**: 
    - Description: This R script extracts data from CSV files, filters it based on review status, and combines the results.
    - Usage: 
        ```
        Rscript extract_data.R <directory_path> <combined_results_directory> <review_status> <clinvar_interpretation>
        ```
    - Example:
        ```
        Rscript extract_data.R ../../data/1302024/biorxiv_13022024/simple_mode/dataset_tables/ "result_directory" "review_status" clinvar_interpretation.txt
        ```

2. **create_ROC.R**:
    - Description: This R script creates ROC curves and sensitivity-specificity plots for GEMME and DeMaSk.
    - Usage:
        ```
        Rscript create_ROC.R <input_file> <ROC_output_file> <sensitivity_specificity_output_file> <sensitivity_specificity_csv_output_file>
        ```
    - Example (for GEMME):
        ```
        Rscript create_ROC.R "result_directory/combined_GEMME_values.csv" "result_directory/ROC_GEMME.png" "result_directory/sensitivity_specificity_GEMME.png" "result_directory/sensitivity_specificity_GEMME.csv"
        ```

3. **min_d_value.sh**:
    - Description: This Bash script calculates the minimum value in a specified column of a CSV file and saves the corresponding row to a new file.
    - Usage:
        ```
        bash min_d_value.sh <csv_file> <column_name> <output_file>
        ```
    - Example:
        ```
        bash min_d_value.sh "result_directory/sensitivity_specificity_GEMME.csv" "D" "result_directory/min_d_value_GEMME.csv"
        ```

4. **run_ROC_analysis.sh**:
    - Description: This Bash script orchestrates the execution of the above scripts to perform ROC analysis for GEMME and DeMaSk.
    - Usage:
        ```
        bash run_ROC_analysis.sh <result_directory> <review_status> <clinvar_interpretation> <dataset_path>
        ```
    - Example:
        ```
        bash run_ROC_analysis.sh results_2_3 2,3 clinvar_interpretation.txt ../../data/1302024/biorxiv_13022024/simple_mode/dataset_tables/ 
        ```

Authors:
---------
- Laura Bauer
