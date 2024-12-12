# Stat-172-Final-Project

## Project Overview
This project, created as part of the Stat-172 course at Drake University, uses R-Studio to analyze food insecurity in Iowa. Working with Wesley Life, a non-profit organization dedicated to delivering food to those in need, we aimed to identify counties with the highest levels of food insecurity among seniors to assist their planned expansion beyond Polk County.

The analysis uses PUMA (Public Use Microdata Area) data to provide insights and help Wesley Life prioritize counties for their expansion.

## Data Sources
We worked with two primary datasets:

#### CPS:
Collected at the individual level with additional household information.

Includes data on food insecurity but is limited as it does not reach all counties, making it insufficient for a full analysis on its own.

#### ACS:
Census data collected across Iowa, including PUMA data.

Does not directly measure food insecurity but contains other relevant variables for predictive modeling.

## Method
#### Model Training and Testing:
We trained a predictive model using 70% of the CPS data, focusing on food insecurity measures, using the other 30% as a testing model to ensure accuracy.

We used both Lasso (alpha = 1) and Ridge (alpha = 0) regressions for these models, as well as cross-validation to select the best parameter (lambda) for each model based on performance metrics.

We generated ROC curves to assess the predictive accuracy of the models on the testing dataset, including sensitivity and specificity at different thresholds. Comparing AUC (Area Under the Curve) values for both the Lasso and Ridge regression models.

#### Model Application
We created and trained two different models. The first model included every household, the second model only looked at households where there is a senior that is living alone.

We applied the trained models to our ACS data, which does not include direct food insecurity measures, to predict food insecurity probabilities among households with seniors at the PUMA level.

#### Model Views
We utilized PUMA shapefiles for Iowa to create choropleth maps that visualize food insecurity probabilities. Mapping overall probabilities and focusing on the elderly population, grouping by PUMA and calculating weighted means.

#### Variable Selection:
Our selected predictor for food insecurity is:

FSWROUTY - Worry that food would run out before being able to afford more (during the past year).

## Using Our Code
#### Our R Studio scripts
We have 5 R Studio scripts that we used for this data. 

clean_acs.R - This takes our ACS data and cleans it so we can properly work with it and draw conclusions.

clean_cps.R - This takes our CPS data and cleans it so we can properly train our models.

RandomForestVariableImportance.R - This is how we found our most important variables to use in our models.

graphs.R - This produces our graphs.

model_y1(commented).R - This is the code for our models. The current script gives the "full" model. If you uncomment line 19, the code will produce our subset model which is strictly seniors that live alone.

#### Using Our Code
After downloading the 5 R Studio files, you can easily duplicate our results by running the two cleaning scripts first, then the model_y1 script, then the RandomForestVariableImportance script, and finally the graphs script if you are looking to see the cloropleth graphs we have produced.

All librarys that are needed are listed at the top of each script.

## Conclusions
#### Full Model
After using the "full" data to assess food insecurity among households with seniors, we found these conclusions:

The largest aggregated probability that a household with a senior will be food insecure is in the Des Moines City PUMA.

The largest number of expected households with a senior being food insecure is in the Southwest Iowa--Council Bluffs City PUMA.

Although this is true, the aggregate probability of a household with a senior being food insecure in Southwest Iowa--Council Bluffs City PUMA is the 16th highest probability out of only 24 PUMA areas.

#### Recommendations
Wesley Life is already expanded to the Southwest Iowa--Council Bluffs City PUMA which is why we are recommending that they expand their efforts to the Dubuque, Buchanan, Jackson & Delaware Counties--Dubuque City PUMA.

#### Subset Model
Wesley Life was especially interested in seniors who lived alone as these seniors will often use Wesley Life's food delivery system for regular social interaction. Wesley Life also likes this as they are able to keep track of these seniors, as they may be the only ones who show up regularily enough to know if something bad happened to the senior citizen. This is why we created this subset.

Although Wesley Life is interested in this subset, the subset model performed signficantly worse than the full model with all seniors, which is why we recommend using the full model in further conclusions and analysis.

## Acknowledements
We thank Wesley Life for their collaboration and the course instructor Lendie Follett for her guidance.
