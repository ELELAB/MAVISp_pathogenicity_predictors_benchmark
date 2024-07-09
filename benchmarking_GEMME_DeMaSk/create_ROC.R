library(pROC)

# Function to create ROC curve, calculate sensitivity, specificity, and save the results to CSV
create_ROC_curve_and_save_results <- function(file_path, roc_plot_save_path, sens_spec_plot_save_path, results_csv_path) {
  # Read data from file
  df <- read.csv(file_path, header = TRUE)
  
  # Extracting predictor and response variables
  if (grepl("combined_DeMaSk_values.csv", file_path)) {
    predictor <- df$DeMaSk_Score
  } else if (grepl("combined_GEMME_values.csv", file_path)) {
    predictor <- df$GEMME_Score
  } else {
    stop("File name not recognized. Please provide either combined_DeMaSk_values.csv or combined_GEMME_values.csv.")
  }
  
  # Recoding the response variable to include all pathogenic and likely pathogenic as positive (1),
  # and benign as negative (0)
  response <- ifelse(grepl("Pathogenic", df$ClinVar_Interpretation, ignore.case = TRUE), 1,
                     ifelse(grepl("Benign", df$ClinVar_Interpretation, ignore.case = TRUE), 0, NA))
  
  # Removing NA values
  predictor <- predictor[!is.na(response)]
  response <- response[!is.na(response)]
  
  # Calculating ROC curve
  roc_obj <- roc(response, predictor)
  
  # Creating Sensitivity-Specificity plot
  sens_spec_df <- coords(roc_obj, "all", ret = c("threshold", "sensitivity", "specificity"))
  
  # Calculating D
  D <- (1 - sens_spec_df$sensitivity)^2 + (1 - sens_spec_df$specificity)^2
  
  # Combine sensitivity, specificity, threshold, and D into a data frame
  result_df <- data.frame(threshold = sens_spec_df$threshold,
                          sensitivity = sens_spec_df$sensitivity,
                          specificity = sens_spec_df$specificity,
                          D = D)
  
  # Save results to CSV
  write.csv(result_df, file = results_csv_path, row.names = FALSE)
  
  # Plotting ROC curve
  png(file = roc_plot_save_path, width = 2000, height = 2000, res = 400)
  plot(roc_obj, main = "ROC Curve", col = "blue")
  legend("bottomright", legend = sprintf("AUC = %.2f", auc(roc_obj)), col = "blue", lty = 1, cex = 0.8)
  dev.off()
  
  # Find the index of the minimum D value
  min_D_index <- which.min(D)
  
  # Plotting Sensitivity-Specificity plot
  png(file = sens_spec_plot_save_path, width = 2000, height = 2000, res = 400)
  plot(sens_spec_df$threshold, sens_spec_df$sensitivity, type = "l", col = "red", xlab = "Threshold", ylab = "Sensitivity/Specificity", 
       main = "Sensitivity-Specificity Plot")
  lines(sens_spec_df$threshold, sens_spec_df$specificity, type = "l", col = "blue") # Plotting specificity line first
  
  # Plotting the D values as a separate line
  lines(sens_spec_df$threshold, D, type = "l", col = "green")
  
  # Add a vertical line at the minimum D value
  abline(v = sens_spec_df$threshold[min_D_index], col = "black", lty = 2)
  
  # Add text label for the minimum D point with smaller size
  text(sens_spec_df$threshold[min_D_index], D[min_D_index], labels = paste(round(sens_spec_df$threshold[min_D_index], 2), ",", round(D[min_D_index], 2)), pos = 3, cex = 0.5)
  
  # Position the legend to the left middle of the plot
  legend("left", legend = c("Sensitivity", "Specificity", "D"), col = c("red", "blue", "green"), lty = 1, cex = 0.5, bty = "n")
  dev.off()
  
}

file_path <- commandArgs(trailingOnly = TRUE)[1]
roc_plot_save_path <- commandArgs(trailingOnly = TRUE)[2]
sens_spec_plot_save_path <- commandArgs(trailingOnly = TRUE)[3]
results_csv_path <- commandArgs(trailingOnly = TRUE)[4]
create_ROC_curve_and_save_results(file_path, roc_plot_save_path, sens_spec_plot_save_path, results_csv_path)
