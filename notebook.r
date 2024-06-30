# Load the necessary packages
install.packages("Metrics")
if (!requireNamespace("fastDummies", quietly = TRUE)) {
  install.packages("fastDummies")
}

# Load libraries
library(tidyverse)
library(yardstick)
library(Metrics)
library(gridExtra) # Grids for plots
library(caret) # ML
library(glue) # String interpolation
library(fastDummies) # OneHot Encoding

# Load the data
hd_data <- read.csv("Cleveland_hd.csv")

# Inspect the first five rows
head(hd_data, 5)

### EDA ###

# Balance of sexes
table(hd_data["sex"])

# Adjust figure size
options(repr.plot.width = 4, repr.plot.height = 4)

# Distribution of age
p <- ggplot(hd_data, aes(x = age)) + 
     geom_histogram(binwidth = 5, fill = "dark green", color = "black") + 
     labs(title = "Histogram of Age", x = "Age", y = "Frequency") + 
     theme_minimal()


# Convert class column to binary and as factor
hd_data_2 <- hd_data %>% mutate(class = as.factor(ifelse(class == 0, 0, 1)), sex = as.factor(sex))

# Convert the rest of categorical features as factors
hd_data_2 <- hd_data %>% mutate(class = as.factor(ifelse(class == 0, 0, 1)), sex = as.factor(sex))


str(hd_data_2)

# Check potential missing values

NA_counts <- colSums(is.na(hd_data_2))

print(NA_counts)

### Check if distribution of numeric features is normal ###

# Shapiro-Wilk normality test
for (name in names(hd_data_2)) {
	if (is.numeric(hd_data_2[[name]])) {
		result <- shapiro.test(hd_data_2[[name]])
		if (result$p.value < 0.05) {
			print(paste(name, "is NOT normally distributed.", " p.value:", format(result$p.value, digits = 2)))
		} else {
			print(paste(name, "is normally distributed.", " p.value:", format(result$p.value, digits = 2)))
		}
	}
}

# Make lists for continuous (numeric) and discrete (categorical) features
numeric_features = c()
categorical_features = c()

# Loop through each column name in the dataframe
for (name in names(hd_data_2)) { 
	
  # Check if the column is numeric and has more than 10 unique values
  if (is.numeric(hd_data_2[[name]]) && length(unique(hd_data_2[[name]])) > 10) {
	  
    # Append the column name to the numeric_features vector
    numeric_features <- c(numeric_features, name)
  } else {
	categorical_features <- c(categorical_features, name)
  }
}

# Delete class from categorical feature as it's the target
categorical_features <- categorical_features[categorical_features != "class"]

print(numeric_features)
print(categorical_features)

# Remove rows containing missing values
hd_data_2 <- na.omit(hd_data_2)


#########################################
# Plot numeric feature vs heart disease #
#########################################

# Adjust figure size
options(repr.plot.width = 8, repr.plot.height = 8)

# Create an empty dataframe to store numeric feature pvalues
numeric_feature_p_values <- data.frame(feature = character(), feature_type = character(), test = character(), p_value = numeric())

# Create a list to hold all the plots
numeric_plots <- list()

# Create a list to hold all the tests
numeric_tests <- list()

for (i in 1:length(numeric_features)) {
  feature <- numeric_features[i]
  
  # Group by healthy vs disease and calculate means
  hd_data_means <- hd_data_2 %>% 
    group_by(class) %>%
    summarise(means = mean(.data[[feature]], na.rm = TRUE))
  
  # Bar plots and Wilcoxon test (none of the values is normally distributed)
  plot <- ggplot(hd_data_means, aes(x = class, y = means)) + 
    geom_bar(stat = "identity", width = 0.5, fill = "darkgreen") +   
    labs(title = paste(feature), x = "class", y = feature) + 
	theme(
    plot.title = element_text(size = 20),      
    axis.title.x = element_text(size = 16),    
    axis.title.y = element_text(size = 16),   
    axis.text.x = element_text(size = 14),            
    axis.text.y = element_text(size = 14)            
  )
  
  # print(hd_data_means)
  
  x1 <- hd_data_2 %>% filter(class == 0) %>% pull(feature)
  x2 <- hd_data_2 %>% filter(class == 1) %>% pull(feature)
  
  test <- wilcox.test(x1, x2, paired = FALSE)
  
  # Store results in the dataframe
  numeric_feature_p_values <- rbind(numeric_feature_p_values, data.frame(feature = feature, feature_type = "numeric", test = "Wilcoxon", p_value = test$p.value))
  
  # Add the plot and test to the lists
  numeric_plots[[i]] <- plot
  numeric_tests[[i]] <- test
  
}

# Create a grid of plots
grid.arrange(grobs = numeric_plots, ncol = 3)

# Print results
print(numeric_feature_p_values)

#############################################
# Plot categorical feature vs heart disease #
#############################################

# Adjust figure size
options(repr.plot.width = 10, repr.plot.height = 10)

# Create an empty dataframe to store categorical feature pvalues
categorical_feature_p_values <- data.frame(feature = character(), feature_type = character(), test = character(), p_value = numeric())

# Create a list to hold all the plots and tests
categrorical_plots <- list()
categorical_tests <- list()

# Create a grouped bar plot for each categorical feature
for (i in 1:length(categorical_features)) {
	feature <- categorical_features[i]
 
	# Make a grouped bar plot
    cat_plot <- ggplot(hd_data_2, aes(x = factor(class), fill = factor(.data[[feature]]))) + 
	geom_bar(position = "dodge") + 
	labs(title = paste(feature), x = "class", y = "count") + 
    theme_minimal() +
	scale_fill_discrete(name = feature) + 
	theme(
    plot.title = element_text(size = 20),      
    axis.title.x = element_text(size = 16),    
    axis.title.y = element_text(size = 16),    
    axis.text.x = element_text(size = 14),                    
    axis.text.y = element_text(size = 14),                    
    legend.title = element_text(size = 16),    
    legend.text = element_text(size = 14)                     
  )
	
	# Chi-square test
	chisq_test <- chisq.test(hd_data_2$class, hd_data_2[[feature]])
	
	# Store results in the dataframe
	categorical_feature_p_values <- rbind(categorical_feature_p_values, data.frame(feature = feature, feature_type = "categorical", test = "Chi-square", p_value = chisq_test$p.value))
	
	# Add the plot and test to the lists
  	categrorical_plots[[i]] <- cat_plot
	categorical_tests[[i]] <- chisq_test
	
}

# Create a grid of plots
grid.arrange(grobs = categrorical_plots, ncol = 3)

# Print results
print(categorical_feature_p_values)


### Select the top 3 predictors related to heart disease ###

# Create one dataframe for both numeric and categorical feature
feature_p_values <- rbind(numeric_feature_p_values, categorical_feature_p_values)

# Sort feature_p_values by p-value
feature_p_values <- feature_p_values[order(feature_p_values$p_value),]

# Create an empty list to store the top 3 predictors related to heart disease
highly_significant <- character()

# Add the top 3 feature names to the list
for (i in 1:3) {
  highly_significant[i] <- feature_p_values[i, "feature"]
}

print(paste("Top 3 features related to heart disease: ", toString(highly_significant)))

#######################
# Logistic regression #
#######################

# Select top 3 columns from df that are highly_significant
df <- hd_data_2 %>% select(all_of(c(highly_significant, "class")))

# One hot encoding
df <- dummy_cols(df, select_columns = highly_significant, remove_selected_columns = TRUE)

# Define X and y
X <- select(df, -class)
y <- df$class

# Train-Test split
set.seed(42)
train_index <- createDataPartition(y, p = 0.7, list = FALSE)
X_train <- X[train_index, ]
y_train <- y[train_index]
X_test <- X[-train_index, ]
y_test <- y[-train_index]

# Fit logistic regression model
model <- glm(y_train ~., data = X_train, family = binomial)

# Make predictions
predictions <- predict(model, newdata = X_test, type = "response")
predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Convert predictions and y_test to factors
predicted_classes <- as.factor(predicted_classes)
y_test_factor <- as.factor(y_test)

# Evaluate the model
accuracy <- mean(predicted_classes == y_test_factor)
print(glue("Accuracy: {accuracy * 100}%"))

# Convert highly_significant to a list for final evaluation
highly_significant <- as.list(highly_significant)

# Detailed performance metrics
confusion <- confusionMatrix(predicted_classes, y_test_factor)

# Plot the confusion matrix
options(repr.plot.width = 4, repr.plot.height = 4)

df_conf_mat <- as.data.frame(confusion$table)

ggplot(df_conf_mat, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), color = "white", size = 12) +
  scale_fill_gradient(low = "#D3D3D3", high = "#0073C2") +
  labs(x = "Reference", y = "Prediction", title = "Confusion Matrix") +
  theme_minimal()


