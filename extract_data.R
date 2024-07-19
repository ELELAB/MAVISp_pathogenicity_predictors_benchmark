#!/usr/bin/env python3

# extract_data.R: extract data suitable for benchmark from MAVISp dataset
# Copyright (C) 2023 Laura Bauer, Matteo Tiberti, Danish Cancer Institute
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Set the directory path where your CSV files are located
directory_path <- commandArgs(trailingOnly = TRUE)[1]
combined_results_directory <- commandArgs(trailingOnly = TRUE)[2]
review_status <- unlist(strsplit(commandArgs(trailingOnly = TRUE)[3], ","))
clinvar_interpretation <- commandArgs(trailingOnly = TRUE)[4]

# Check if the combined results directory exists, if not, create
if (!file.exists(combined_results_directory)) {
  dir.create(combined_results_directory, recursive = TRUE)
  cat("Combined results directory created:", combined_results_directory, "\n")
} else {
  cat("Combined results directory already exists:", combined_results_directory, "\n")
}


# List all the CSV files in the directory
csv_files <- list.files(directory_path, pattern = ".csv", full.names = TRUE)

# Initialize empty data frames to store combined data
combined_gemme_data <- data.frame()
combined_demask_data <- data.frame()

# Initialize a variable to store total row count
total_row_count <- 0

# Initialize a variable to store the count of rows after ClinVar Classification extraction
total_rows_after_ClinVar_Classification <- 0

# Initialize a variable to store the count of rows after ClinVar Classification directory check
total_rows_after_ClinVar_Classification_dir <- 0

# Initialize a variable to store the count of rows extracting after review status
files_remaining_after_review <- 0

# Read data from file into a data frame
clinvar_data <- read.csv(file = clinvar_interpretation, header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

# Initialize an empty list to store key-value pairs
key_value_pairs <- list()

# Loop through each row of the data frame
for (i in 1:nrow(clinvar_data)) {
  # Extract key and value
  key <- clinvar_data[i, "#ClinVar"]  # Replace "#ClinVar" with the actual column name of your key
  value <- clinvar_data[i, "Internal_dictionary"]  # Replace "Internal_dictionary" with the actual column name of your value
  
  # Check if value is "Benign" or "Pathogenic"
  if (value %in% c("Benign", "Pathogenic")) {
    # Convert value to 0 for Benign, 1 for Pathogenic
    if (value == "Pathogenic") {
      value <- 1
    } else if (value == "Benign") {
      value <- 0
    }
    
    # Store key with numeric value in the dictionary
    key_value_pairs[[key]] <- value
  }
}

# Extract keys from key_value_pairs into filter_words vector
filter_words <- names(key_value_pairs)

# Loop over each CSV file
for (file in csv_files) {
  # Read the CSV file
  data <- read.csv(file)
  
  # Count rows
  total_row_count <- total_row_count + nrow(data)
  
  # Extract the file name
  file_name <- basename(file)
  
  # Extract the protein name from the file name
  protein_name <- sub("^.*?([^-]+)-[^-]+\\.csv$", "\\1", basename(file))
  
  # Check if the specified columns exist in the data
  if (!("ClinVar.Interpretation" %in% colnames(data))) {
     cat("Error: 'ClinVar.Interpretation' column not found in file:", file_name, "\n")
    next
  }
  
  total_rows_after_ClinVar_Classification <- total_rows_after_ClinVar_Classification + nrow(data)
  
  # Filter rows with non-empty values in ClinVar.Interpretation column
  filtered_data <- data[!is.na(data$ClinVar.Interpretation) & data$ClinVar.Interpretation != "", ]
  
  # Filter the filtered_data dataframe using the filter_words
  filtered_data <- filtered_data[filtered_data$ClinVar.Interpretation %in% filter_words, ]

  # Count remaining variants
  total_rows_after_ClinVar_Classification_dir <- total_rows_after_ClinVar_Classification_dir + nrow(filtered_data)
  
  # Filter by review status
  filtered_data <- filtered_data[filtered_data$ClinVar.Review.Status %in% review_status, ]
  
  # Count remaining variants after review status filtering
  files_remaining_after_review <- files_remaining_after_review + nrow(filtered_data)
  
 
   # Check if there are any rows left after filtering for ClinVar data
  if (nrow(filtered_data) > 0) {
    # Extract GEMME.Score and DeMaSk.delta.fitness values if columns exist
    if ("GEMME.Score" %in% colnames(filtered_data)) {
      GEMME_values <- filtered_data$GEMME.Score
    
      # Check if GEMME values are not empty or 0
      if (any(!is.na(GEMME_values))) {
        # Map ClinVar.Interpretation to ClinVar.Conversion using key_value_pairs
        filtered_data$ClinVar.Conversion <- sapply(filtered_data$ClinVar.Interpretation, function(key) key_value_pairs[[key]])

        GEMME_output <- data.frame(
          Protein = protein_name,
          Mutation = filtered_data$Mutation,
          GEMME_Score = GEMME_values,
          ClinVar_Interpretation = filtered_data$ClinVar.Interpretation,
          ClinVar_Conversion = filtered_data$ClinVar.Conversion,
          ClinVar_Review_Status = filtered_data$ClinVar.Review.Status)
        combined_gemme_data <- rbind(combined_gemme_data, GEMME_output)
      } else {
        cat("No valid GEMME scores found in file:", file_name, "\n")
      }
    } else {
      cat("Files with missing GEMME scores:", file_name, "\n")
    }
    
    # Extract DeMaSk.delta.fitness values if column exists
    if ("DeMaSk.delta.fitness" %in% colnames(filtered_data)) {
      DeMaSk_values <- filtered_data$DeMaSk.delta.fitness
    
    # Check if DeMaSk values are not empty or 0
      if (any(!is.na(DeMaSk_values))) {
        filtered_data$ClinVar.Conversion <- sapply(filtered_data$ClinVar.Interpretation, function(key) key_value_pairs[[key]])

        DeMaSk_output <- data.frame(
          Protein = protein_name,
          Mutation = filtered_data$Mutation,
          DeMaSk_Score = DeMaSk_values,
          ClinVar_Interpretation = filtered_data$ClinVar.Interpretation,
          ClinVar_Conversion = filtered_data$ClinVar.Conversion,
          ClinVar_Review_Status = filtered_data$ClinVar.Review.Status)
        combined_demask_data <- rbind(combined_demask_data, DeMaSk_output)
      } else {
        cat("No valid DeMaSk scores found in file:", file_name, "\n")
      }
    } else {
    cat("Files with missing DeMaSk scores:", file_name, "\n")
    }
  }
}

# Write combined GEMME data to a single CSV file in the combined results directory
if (nrow(combined_gemme_data) > 0) {
  combined_gemme_output_path <- file.path(combined_results_directory, "combined_GEMME_values.csv")
  write.csv(combined_gemme_data, combined_gemme_output_path, row.names = FALSE)
  cat("Combined GEMME values saved to:", combined_gemme_output_path, "\n")
} else {
  cat("No GEMME data available to save.\n")
}

# Write combined DeMaSk data to a single CSV file in the combined results directory
if (nrow(combined_demask_data) > 0) {
  combined_demask_output_path <- file.path(combined_results_directory, "combined_DeMaSk_values.csv")
  write.csv(combined_demask_data, combined_demask_output_path, row.names = FALSE)
  cat("Combined DeMaSk values saved to:", combined_demask_output_path, "\n")
} else {
  cat("No DeMaSk data available to save.\n")
}

combined_results_file <- file.path(combined_results_directory, "results_summary.txt")

# Write lines to a single file including row counts
writeLines(
  paste(
    "Total number of all variants:", total_row_count,
    "\nNumber variants left with after ClinVar classification:", total_rows_after_ClinVar_Classification,
    "\nNumber variants left after filtering ClinVar class. according dictionary:", total_rows_after_ClinVar_Classification_dir,
    "\nNumber variants left after filtering review status:", files_remaining_after_review,
    "\nNumber variants for GEMME Score:", nrow(combined_gemme_data),
    "\nNumber variants for DeMaSk Score:", nrow(combined_demask_data)
  ),
  combined_results_file
)
