
# Libraries ---------------------------------------------------------------

library(tidyverse)
library(janitor)
library(here)

# Read In Raw Data ------------------------------------------------------------

regional_domestic_tourism <- read_csv("data/raw_data/regional_domestic_tourism.csv") %>%
  clean_names()

local_authority_codes <- read_csv("data/raw_data/local_authority_codes.csv")

international_visits <- read_csv("data/raw_data/international-passenger-survey-scotland-2019.csv")

local_authority_geo <- st_read(dsn = "data/geo_data/", layer = "pub_las")

tourism_businesses <- read_csv(here("data/raw_data/tourism-businesses-in-scotland.csv")) %>% clean_names()

# Clean Tourism Business Data ------------------------------------------------------------

tourism_businesses_clean <- tourism_businesses %>%
  clean_names() %>% 
  select(-x7)

# Clean International Tourism Data ------------------------------------------------------------

international_visits_clean <- international_visits %>%
  clean_names()

# Clean Regional Domestic Tourism Data ------------------------------------------------------------

regional_domestic_tourism_all_clean <- regional_domestic_tourism %>%
  filter(feature_code == "S92000003",
         region_of_residence == "All of GB") %>%
  arrange(date_code) %>% 
  select(-c(measurement, units)) %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>% 
  clean_names() %>% 
  mutate(exp_per_visit = expenditure / visits,
         exp_per_visit_pct_change = (exp_per_visit - lag(exp_per_visit)) / lag(exp_per_visit) * 100,
         visit_pct_change = (visits - lag(visits)) / lag(visits) * 100,
         exp_pct_change = (expenditure - lag(expenditure)) / lag(expenditure) * 100,
  
         visits_change_label = case_when(visits > lag(visits) ~ "Increased",
                                         visits < lag(visits) ~ "Decreased",
                                         visits == lag(visits) ~ "No Change",
                                         TRUE ~ "Starting Year"),
         exp_pct_change_label = case_when(expenditure > lag(expenditure) ~ "Increased",
                                      expenditure < lag(expenditure) ~ "Decreased",
                                      expenditure == lag(expenditure) ~ "No Change",
                                      TRUE ~ "Starting Year"),
         exp_per_visit_label = case_when(exp_per_visit > lag(exp_per_visit) ~ "Increased",
                                         exp_per_visit < lag(exp_per_visit) ~ "Decreased",
                                         exp_per_visit == lag(exp_per_visit) ~ "No Change",
                                         TRUE ~ "Starting Year"))

regional_domestic_tourism_individual_clean <- regional_domestic_tourism %>%
  filter(feature_code != "S92000003",
         region_of_residence == "All of GB") %>%
  arrange(date_code) %>% 
  select(-c(measurement, units)) %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>% 
  clean_names() %>%
  rename(year = date_code) %>% 
  inner_join(local_authority_codes, by = "feature_code")

regional_domestic_tourism_non_gb_clean <- regional_domestic_tourism %>%
  filter(feature_code != "S92000003",
         region_of_residence != "All of GB") %>%
  arrange(date_code) %>% 
  select(-c(measurement, units)) %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>% 
  clean_names() %>%
  rename(year = date_code) %>% 
  inner_join(local_authority_codes, by = "feature_code")
  
regional_data_joined <- local_authority_geo %>% 
  left_join(regional_domestic_tourism_individual_clean, by = c("code" = "feature_code"))

# Write Clean Data To .CSV -----------------------------------------------------------

write_csv(regional_domestic_tourism_all_clean, here("data/clean_data/regional_domestic_tourism_all_clean.csv"))
write_csv(regional_domestic_tourism_individual_clean, here("data/clean_data/regional_domestic_tourism_individual_clean.csv"))
write_csv(regional_domestic_tourism_non_gb_clean, here("data/clean_data/regional_domestic_tourism_non_gb_clean.csv"))
write_csv(international_visits_clean, here("data/clean_data/international_visits_clean.csv"))
write_csv(tourism_businesses_clean, here("data/clean_data/tourism_businesses_clean.csv"))

# Remove Objects from Environment -----------------------------------------------------------

rm(regional_domestic_tourism)
rm(regional_domestic_tourism_all_clean)
rm(regional_domestic_tourism_individual_clean)
rm(regional_domestic_tourism_non_gb_clean)
rm(local_authority_codes)
rm(international_visits_clean)
rm(international_visits)
rm(local_authority_geo)
rm(tourism_businesses)
rm(tourism_businesses_clean)
