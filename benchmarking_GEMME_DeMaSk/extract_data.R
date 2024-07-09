# Set the directory path where your CSV files are located
directory_path <- commandArgs(trailingOnly = TRUE)[1]
combined_results_directory <- commandArgs(trailingOnly = TRUE)[2]
review_status <- unlist(strsplit(commandArgs(trailingOnly = TRUE)[3], ","))
clinvar_interpretation <- commandArgs(trailingOnly = TRUE)[4]

# Check if the combined results directory exists, if not, create
if (!file.exists(combined_results_directory)) {
  unix_command <- paste("mkdir -p", combined_results_directory)
  system(unix_command)
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
files_remaining_after_ClinVar_Classification <- 0

# Initialize a variable to store the count of rows after ClinVar Classification directory check
files_remaining_after_ClinVar_Classification_dir <- 0

# Initialize a variable to store the count of rows extracting after review status
files_remaining_after_review <- 0

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
    # cat("Error: 'ClinVar.Interpretation' column not found in file:", file_name, "\n")
    next
  }
  
  files_remaining_after_ClinVar_Classification <- files_remaining_after_ClinVar_Classification + nrow(data)
  
  # Filter rows with non-empty values in ClinVar.Interpretation column
  filtered_data <- data[!is.na(data$ClinVar.Interpretation) & data$ClinVar.Interpretation != "", ]
  
  # Filter after ClinVar Classifications regarding directory 
  # filtered_data <- filtered_data[filtered_data$ClinVar.Interpretation %in% c("Benign", "Pathogenic, Pathogenic, Pathogenic", "Pathogenic; risk factor", "Pathogenic, Pathogenic", "Pathogenic"), ]
  
  # Filter after ClinVar Classifications regarding MAVISp Interpretation file
  filter_words <- scan(clinvar_interpretation, what="", sep="\n", quiet = TRUE)
  
  # Filter the filtered_data dataframe using the filter_words
  filtered_data <- filtered_data[filtered_data$ClinVar.Interpretation %in% filter_words, ]

  # Count remaining variants
  files_remaining_after_ClinVar_Classification_dir <- files_remaining_after_ClinVar_Classification_dir + nrow(filtered_data)
  
  # Filter by review status
  filtered_data <- filtered_data[filtered_data$ClinVar.Review.Status %in% review_status, ]
  
  # Count remaining variants after review status filtering
  files_remaining_after_review <- files_remaining_after_review + nrow(filtered_data)
  
 
   # Check if there are any rows left after filtering for ClinVar data
  if (nrow(filtered_data) > 0) {
    # Extract GEMME.Score and DeMaSk.delta.fitness values if columns exist
    if ("GEMME.Score" %in% colnames(filtered_data)) {
      GEMME_values <- filtered_data$GEMME.Score
      GEMME_output <- data.frame(Protein = protein_name, Mutation = filtered_data$Mutation, GEMME_Score = GEMME_values, ClinVar_Interpretation = filtered_data$ClinVar.Interpretation, ClinVar_Review_Status = filtered_data$ClinVar.Review.Status)
      combined_gemme_data <- rbind(combined_gemme_data, GEMME_output)
    } else {
      cat("Files with missing GEMME scores:", file_name, "\n")
    }
    
    if ("DeMaSk.delta.fitness" %in% colnames(filtered_data)) {
      DeMaSk_values <- filtered_data$DeMaSk.delta.fitness
      DeMaSk_output <- data.frame(Protein = protein_name, Mutation = filtered_data$Mutation, DeMaSk_Score = DeMaSk_values, ClinVar_Interpretation = filtered_data$ClinVar.Interpretation, ClinVar_Review_Status = filtered_data$ClinVar.Review.Status)
      combined_demask_data <- rbind(combined_demask_data, DeMaSk_output)
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
    "\nNumber variants left with after ClinVar classification:", files_remaining_after_ClinVar_Classification,
    "\nNumber variants left after filtering ClinVar class. according dictionary:", files_remaining_after_ClinVar_Classification_dir,
    "\nNumber variants left after filtering review status:", files_remaining_after_review,
    "\nNumber variants for GEMME Score:", nrow(combined_gemme_data),
    "\nNumber variants for DeMaSk Score:", nrow(combined_demask_data)
  ),
  combined_results_file
)



