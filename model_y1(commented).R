# Clearing the workspace
rm(list = ls())

# Loading necessary libraries
library(writexl)
library(tidyverse)
library(pROC)
library(glmnet)
library(lubridate)
library(sf)
library(tmap)
library(tigris)

# Loading external cleaning scripts
source("Code/clean_cps.R")
source("Code/clean_acs.R")

#Un/Comment line 19 to try with or without the subset of Seniors who live alone.
#cps_data = cps_data[cps_data$elderly == cps_data$hhsize & cps_data$elderly ==1, ]

# Removing unnecessary columns from CPS data
f <- cps_data %>% 
  select(-c(CPSID, COUNTY, FSTOTXPNC_perpers, FSSTATUS, FSSTATUSMD, FSFOODS, FSBAL,
            FSRAWSCRA, FSTOTXPNC))

# Dropping rows with missing values in the FSWROUTY column
df <- f[!is.na(f$FSWROUTY), ]

##### Splitting Data #####

# Creating training and testing datasets
train.idx <- sample(x = 1:nrow(df), size = 0.7 * nrow(df))
train.df <- df[train.idx, ]
test.df <- df[-train.idx, ]

# Preparing model matrices for training and testing
x.train <- model.matrix(FSWROUTY ~ hhsize + female + hispanic + black + kids + elderly + education + married + livalone, 
                        data = train.df %>% select(-weight))[,-1]
x.test <- model.matrix(FSWROUTY ~ hhsize + female + hispanic + black + kids + elderly + education + married + livalone, 
                       data = test.df %>% select(-weight))[,-1]

y.train <- as.vector(train.df$FSWROUTY)
y.test <- as.vector(test.df$FSWROUTY)

##### Model Training #####

# Cross-validation to find the best lambda for Lasso and Ridge
lr_lasso_cv <- cv.glmnet(x.train, y.train, family = binomial(link = "logit"), alpha = 1, 
                         weights = as.integer(train.df$weight))

lr_ridge_cv <- cv.glmnet(x.train, y.train, family = binomial(link = "logit"), alpha = 0, 
                         weights = as.integer(train.df$weight))

# Extracting the best lambda values
best_lasso_lambda <- lr_lasso_cv$lambda.min
best_ridge_lambda <- lr_ridge_cv$lambda.min

# Fitting final models
final_lasso <- glmnet(x.train, y.train, family = binomial(link = "logit"), alpha = 1, 
                      weights = as.integer(train.df$weight), lambda = best_lasso_lambda)

final_ridge <- glmnet(x.train, y.train, family = binomial(link = "logit"), alpha = 0, 
                      weights = as.integer(train.df$weight), lambda = best_ridge_lambda)

##### Model Evaluation #####

# Adding predictions to the test dataset
test.df.preds <- test.df %>% 
  mutate(
    lasso_pred = predict(final_lasso, x.test, type = "response")[,1],
    ridge_pred = predict(final_ridge, x.test, type = "response")[,1]
  )

# Generating ROC curves
lasso_rocCurve <- roc(response = as.factor(test.df.preds$FSWROUTY),
                      predictor = test.df.preds$lasso_pred, 
                      levels = c("0", "1"))

ridge_rocCurve <- roc(response = as.factor(test.df.preds$FSWROUTY),
                      predictor = test.df.preds$ridge_pred, 
                      levels = c("0", "1"))

# Plotting ROC curves
plot(lasso_rocCurve, print.thres = TRUE, print.auc = TRUE)
plot(ridge_rocCurve, print.thres = TRUE, print.auc = TRUE)

##### Applying Model to ACS Data #####

# Preparing the test matrix for ACS data
x.test.acs <- model.matrix(PUMA ~ hhsize + female + hispanic + black + kids + elderly + education + married + livalone, 
                           data = acs_data %>% select(-c(serialno, weight)))[,-1]

# Predicting probabilities for ACS data
acs.preds <- acs_data %>% 
  mutate(
    lasso_acs = predict(final_lasso, x.test.acs, type = "response")[,1],
    ridge_acs = predict(final_ridge, x.test.acs, type = "response")[,1]
  )

##### Mapping Predictions #####

# Loading Iowa PUMA shapefiles
iowa_pumas <- pumas(state = "Iowa", cb = TRUE, year = 2020)

# Aggregating predictions by PUMA
acs_preds_ag <- acs.preds %>%
  group_by(PUMA) %>%
  summarize(weighted_mean = weighted.mean(x = ridge_acs, w = weight, na.rm = TRUE))

# Joining shapefiles with predictions
iowa_map_data <- iowa_pumas %>%
  left_join(acs_preds_ag, by = c("GEOID20" = "PUMA"))

# Plotting choropleth map
ggplot(data = iowa_map_data) +
  geom_sf(aes(fill = weighted_mean), color = "white", size = 0.2) +
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "grey", name = "Food Insecure\n Seniors") +
  theme_minimal() +
  labs(title = "Choropleth Map of Iowa PUMAs",
       subtitle = "Visualization of Provided Data",
       caption = "Source: Provided PUMA Data")

##### Elderly Population Analysis #####

# Filtering and aggregating predictions for elderly population
acs_preds_ag <- acs.preds %>%
  filter(elderly >= 1) %>% 
  group_by(PUMA) %>%
  summarize(weighted_mean = weighted.mean(x = ridge_acs, w = weight, na.rm = TRUE))

# Updating map data for elderly analysis
iowa_map_data <- iowa_pumas %>%
  left_join(acs_preds_ag, by = c("GEOID20" = "PUMA"))

# Plotting elderly population map
ggplot(data = iowa_map_data) +
  geom_sf(aes(fill = weighted_mean), color = "white", size = 0.2) +
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "grey", name = "Aggregated\n Probability") +
  theme_minimal() +
  labs(title = "Choropleth Map of Iowa PUMAs")

##### Elderly Food Insecurity Analysis #####

# Loading data for total seniors by PUMA
puma_eld <- read.csv("Data/total_iowa_seniors_by_puma.csv")

# Merging predictions with senior population data
acs_preds_ag$PUMA <- as.integer(as.character(acs_preds_ag$PUMA))
puma_eld$GEOID <- as.integer(puma_eld$GEOID)

iowa_map_data_elderly <- puma_eld %>%
  left_join(acs_preds_ag, by = c("GEOID" = "PUMA"))

iowa_map_data$GEOID20 = as.integer(iowa_map_data$GEOID20)

iowa_map_data_elderly <- puma_eld %>%
  left_join(iowa_map_data, by = c("GEOID" = "GEOID20"))

# Final map plotting
ggplot(data = iowa_map_data_elderly) +
  geom_sf(aes(geometry = geometry, fill = weighted_mean * senior_population), 
          color = "white", size = 0.2) + 
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "grey", name = "Food Insecure\n     Seniors") +
  theme_minimal() +
  labs(title = "Choropleth Map of Iowa PUMAs")

##### Saving Results #####

# Saving the final dataset to an Excel file
save_this <- iowa_map_data_elderly %>% 
  mutate(total_seniors_insecure = senior_population * weighted_mean) %>% 
  select(c(senior_population, weighted_mean, total_seniors_insecure, NAMELSAD20))

#write_xlsx(save_this, "Output/number_of_seniors_preds_new.xlsx")