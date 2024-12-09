# Stat-172-Final-Project

## Project Overview
This project, created as part of the Stat-172 course at Drake University, uses R-Studio to analyze food insecurity in Iowa. Working with Wesley Life, a non-profit organization dedicated to delivering food to those in need, we aimed to identify counties with the highest levels of food insecurity to assist their planned expansion beyond Polk County.

The analysis uses PUMA (Public Use Microdata Area) data to provide insights and help Wesley Life prioritize counties for their expansion.

## Data Sources
We worked with two primary datasets:

#### CPS (Current Population Survey):
Collected at the individual level with additional household information.

Includes data on food insecurity but is limited as it does not reach all counties, making it insufficient for a full analysis on its own.

#### ACS (American Community Survey):
Census data collected across Iowa, including PUMA data.

Does not directly measure food insecurity but contains other relevant variables for predictive modeling.

## Method
#### Model Training and Testing:
We trained a predictive model using 70% of the CPS data, focusing on food insecurity measures, using the other 30% as a testing model to ensure accuracy.

We used both a Lasso (alpha = 1) and Ridge (alpha = 0) regressions for these models, as well as cross-validation to select the best penalty parameter (lambda) for each model based on performance metrics.

We generated ROC curves to assess the predictive accuracy of the models on the testing dataset, including sensitivity and specificity at different thresholds. Comparing AUC (Area Under the Curve) values for both the Lasso and Ridge regression models.

#### Model Application
We applied the trained models to our ACS data, which does not include direct food insecurity measures, to predict food insecurity probabilities at the PUMA level.

#### Model Views
We utilized PUMA shapefiles for Iowa to create choropleth maps that visualize food insecurity probabilities. Mapping overall probabilities and focusing on the elderly population, grouping by PUMA and calculating weighted means.

#### Predictions with ACS Data:
The tested model was applied to the ACS data to predict food insecurity at the county level.

#### Variable Selection:
Our selected predictor for food insecurity is:

FSWROUTY - Worry that food would run out before being able to afform more (during the past year).

## Using Our Code
#### To replicate our analysis or to explore the data:
1. Download the R.Markdown file from this repository.
2. Open the file in R-Studio.
3. Run the script to see our methods and results.
4. Conclusions are commented within the file for easy reference.

## Conclusions
For our data, we found results of not only the seniors, but a subset of seniors that are strictly seniors that live alone.

We found that the Southwest Iowa--Council Bluffs City PUMA has the highest predicted amount of seniors that are food insecure for both the all seniors data as well as our subset.

Although this is true, the aggregate probability of a senior household being food insecure in Southwest Iowa--Council Bluffs City PUMA is not the highest probability among all the PUMA groups. The order of aggreagate probabilities for if senior households are food insecure is different for the subset of seniors and the total seniors. The Southwest Iowa--Council Bluffs City PUMA is the 5th higest probability in the subsetted data out of 24 PUMA's. The Southwest Iowa--Council Bluffs City PUMA is the 16th highest probability in the full data out of 24 PUMA's.

Because of these conclusions, we believe that Wesley Life should focus their efforts in expanding to the Southwest Iowa--Council Bluffs City PUMA area to help the most people in need.

#### Disclaimer
Wesley Life was especially interested in seniors who lived alone as these seniors will often use Wesley Life's food delivery system for regular social interaction. Wesley Life also likes this as they are able to keep track of these seniors, as they may be the only ones who show up regularily enough to know if something bad happened to the senior citizen. This is why we created this subset.

Although Wesley Life is interested in this subset, the subsetted model performed signficantly worse than the full model with all seniors, which is why we suggest using the full model in further conclusions and analysis.

## Acknowledements
We thank Wesley Life for their collaboration and the course instructor Lendie Follett for her guidance.
