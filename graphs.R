rm(list=ls())

library(tidyverse)
library(pROC)
library(glmnet)
library(lubridate)
library(sf)
library(tmap)
library(tigris)

source("Final Project Materials/Data/clean_cps.R")



f = cps_data %>% 
  select(-c(CPSID,COUNTY,FSTOTXPNC_perpers,FSSTATUS,FSSTATUSMD,FSFOODS,FSBAL,
            FSRAWSCRA,FSTOTXPNC  ))

#dropping FSWROUTY na's
df <- f[!is.na(f$FSWROUTY), ]




# Summarize data to calculate proportions of FSWROUTY = 1
df_grouped <- df %>%
  group_by(education) %>%
  summarize(
    household_count = n(),
    FSWROUTY_1_proportion = mean(FSWROUTY == 1, na.rm = TRUE) # Proportion of FSWROUTY = 1
  )

# Create the bar plot
ggplot(df_grouped, aes(x = education, y = FSWROUTY_1_proportion, fill = FSWROUTY_1_proportion)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") + # Gradient for continuous values
  labs(
    title = "Proportion of Food Insecure Households by Education Level",
    x = "# of Educated People in Household",
    y = "Proportion of Food Insecure Households",
    fill = "Proportion"
  ) +
  theme_minimal()

# Convert livalone to categorical labels
df_clean <- df %>%
  mutate(livalone = ifelse(livalone == 1, "Yes", "No"))

# Plot the data
ggplot(data = df_clean, aes(x = livalone, fill = as.factor(FSWROUTY))) +
  geom_bar(position = "dodge") +
  labs(
    title = "# of Food Insecure Households by Living Alone Status",
    x = "Living Alone Status",
    y = "# of Households",
    fill = "Food Insecure"
  ) +
  scale_fill_brewer(
    palette = "Blues",
    direction = 1
  ) +
  theme_minimal()


summary(final_lasso)

levels(as.factor(df$livalone))

# Relabel livalone variable as "Yes" or "No"
df_clean <- df %>%
  mutate(livalone = ifelse(livalone == 1, "Yes", "No"))

# Summarize data to calculate proportions of FSWROUTY = 1 for relabeled livalone
df_grouped <- df_clean %>%
  group_by(livalone) %>%
  summarize(
    household_count = n(),
    FSWROUTY_1_proportion = mean(FSWROUTY == 1, na.rm = TRUE) # Proportion of FSWROUTY = 1
  )

# Create the bar plot for relabeled livalone
ggplot(df_grouped, aes(x = livalone, y = FSWROUTY_1_proportion, fill = FSWROUTY_1_proportion)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") + # Gradient for continuous values
  labs(
    title = "Proportion of Food Insecure Households by Living Alone Status",
    x = "Living Alone Status",
    y = "Proportion of Food Insecure Households",
    fill = "Proportion"
  ) +
  theme_minimal()


