
# Libraries ---------------------------------------------------------------

library(tidyverse)
library(janitor)
library(here)

# Read In Raw Data ------------------------------------------------------------

regional_domestic_tourism <- read_csv("data/raw_data/regional_domestic_tourism.csv") %>%
  clean_names()

local_authority_codes <- read_csv("data/raw_data/local_authority_codes.csv")

international_visits <- read_csv("data/raw_data/international-passenger-survey-scotland-2019.csv")

tourism_businesses <- read_csv("data/raw_data/tourism-businesses-in-scotland.csv") %>% 
  clean_names()

local_authority_geo <- st_read(dsn = "data/geo_data/", layer = "pub_las")

# National Domestic Tourism Data ------------------------------------------------------------

domestic_annual_clean <- read_csv("data/raw_data/gbts_scotland_annual.csv") %>% 
  mutate(dom_int = "Domestic", .after = year)

## Regional Domestic Tourism Data ------------------------------------------------------------

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

regional_data_joined_sco_eng <- local_authority_geo %>% 
  left_join(regional_domestic_tourism_non_gb_clean, by = c("code" = "feature_code"))

# International Tourism Data ------------------------------------------------------------

international_visits_clean <- international_visits %>%
  clean_names()

international_visits_annual_summary_clean <- international_visits_clean %>%
  filter(year %in% c(2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019)) %>%
  group_by(year) %>%
  summarise(visits = sum(visits),
            spend = sum(spend),
            nights = sum(nights)) %>% 
  mutate(dom_int = "International")

# Join Domestic And International Tourism Data ------------------------------------------------------------

dom_int_summary <- bind_rows(domestic_annual_clean, international_visits_annual_summary_clean) %>% 
  select(-nights)

# Tourism Business Data ------------------------------------------------------------

tourism_businesses_clean <- tourism_businesses %>%
  clean_names() %>% 
  select(-x7) %>% 
  filter(local_authority != "- Select -")

# Write Clean Data To .CSV -----------------------------------------------------------

write_csv(regional_domestic_tourism_individual_clean, here("data/clean_data/regional_domestic_tourism_individual_clean.csv"))
write_csv(regional_domestic_tourism_non_gb_clean, here("data/clean_data/regional_domestic_tourism_non_gb_clean.csv"))
write_csv(international_visits_clean, here("data/clean_data/international_visits_clean.csv"))
write_csv(tourism_businesses_clean, here("data/clean_data/tourism_businesses_clean.csv"))
write_csv(dom_int_summary, here("data/clean_data/dom_int_summary_clean.csv"))

# Remove Objects from Environment -----------------------------------------------------------

rm(regional_domestic_tourism)
rm(regional_domestic_tourism_individual_clean)
rm(regional_domestic_tourism_non_gb_clean)
rm(local_authority_codes)
rm(international_visits_clean)
rm(international_visits)
rm(local_authority_geo)
rm(tourism_businesses)
rm(tourism_businesses_clean)
rm(domestic_annual_clean)
rm(international_visits_annual_summary_clean)
rm(dom_int_summary_clean)
