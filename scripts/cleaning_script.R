
# Libraries ---------------------------------------------------------------

library(tidyverse)
library(janitor)
library(here)
library(readxl)

# Read In Raw Data ------------------------------------------------------------

demographics <- read_csv("data/raw_data/tourism_day_visits_demographics.csv") %>% 
  clean_names()

regional_domestic_tourism <- read_csv("data/raw_data/regional_domestic_tourism.csv") %>%
  clean_names()

international_visits <- read_csv("data/raw_data/international-passenger-survey-scotland-2019.csv") %>%
  clean_names()

activities <- read_csv("data/raw_data/tourism_day_visits_activities.csv") %>%
  clean_names()

# domestic_day_visits <- read_excel("data/raw_data/gbdvs-2019-scotland-and-gb.xlsx") %>% 
#   clean_names()

# location <- read_csv("data/raw_data/tourism_day_visits_location.csv") %>% 
#   clean_names()
# 
# transport <- read_csv("data/raw_data/tourism_day_visits_transport.csv") %>% 
#   clean_names()
# 
# accomodation_occupancy <- read_csv("data/raw_data/scottish_accomodation_occupancy.csv") %>% 
#   clean_names()
# 

# Clean Demographic Data ------------------------------------------------------------

all_demographics_clean <- demographics %>%
  filter(age == "All", marital_status == "All", gender == "All", employment_status == "All",
         children == "All",  access_to_car == "All", social_grade == "All") %>%
  select(-c(measurement, units)) %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits,
         exp_per_visit_pct_change = (exp_per_visit - lag(exp_per_visit)) / lag(exp_per_visit) * 100,
         visits_change_label = case_when(Visits > lag(Visits) ~ "Increased",
                                         Visits < lag(Visits) ~ "Decreased",
                                         Visits == lag(Visits) ~ "No Change",
                                         TRUE ~ "Starting Year"),
         exp_change_label = case_when(Expenditure > lag(Expenditure) ~ "Increased",
                                      Expenditure < lag(Expenditure) ~ "Decreased",
                                      Expenditure == lag(Expenditure) ~ "No Change",
                                      TRUE ~ "Starting Year"),
         exp_per_visit_label = case_when(exp_per_visit > lag(exp_per_visit) ~ "Increased",
                                         exp_per_visit < lag(exp_per_visit) ~ "Decreased",
                                         exp_per_visit == lag(exp_per_visit) ~ "No Change",
                                         TRUE ~ "Starting Year")) %>% 
  select(date_code, Visits, Expenditure, exp_per_visit, exp_per_visit_pct_change, 
         visits_change_label, exp_change_label, exp_per_visit_label) %>% 
  rename(year = date_code) %>% 
  clean_names()

employment_demographics_clean <- demographics %>%
  select(-c(feature_code, age, marital_status, gender, children, access_to_car, 
            social_grade, measurement, units)) %>% 
  filter(employment_status != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, employment_status, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

gender_demographics_clean <- demographics %>%
  select(-c(feature_code, age, marital_status, children, access_to_car, 
            social_grade, measurement, units, employment_status)) %>% 
  filter(gender != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, gender, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

age_demographics_clean <- demographics %>%
  select(-c(feature_code, gender, marital_status, children, access_to_car, 
            social_grade, measurement, units, employment_status)) %>% 
  filter(age != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, age, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

marital_status_demographics_clean <- demographics %>%
  select(-c(feature_code, gender, age, children, access_to_car, 
            social_grade, measurement, units, employment_status)) %>% 
  filter(marital_status != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, marital_status, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

children_demographics_clean <- demographics %>%
  select(-c(feature_code, gender, age, marital_status, access_to_car, 
            social_grade, measurement, units, employment_status)) %>% 
  filter(children != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, children, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

car_demographics_clean <- demographics %>%
  select(-c(feature_code, gender, age, marital_status, children, 
            social_grade, measurement, units, employment_status)) %>% 
  filter(access_to_car != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, access_to_car, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

social_demographics_clean <- demographics %>%
  select(-c(feature_code, gender, age, marital_status, children, 
            access_to_car, measurement, units, employment_status)) %>% 
  filter(social_grade != "All") %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>%
  arrange(date_code, social_grade) %>% 
  mutate(exp_per_visit = Expenditure / Visits) %>% 
  select(date_code, social_grade, Visits, Expenditure, exp_per_visit) %>% 
  rename(year = date_code) %>% 
  clean_names()

# Clean Regional Domestic Tourism Data (Overnights) ------------------------------------------------------------

regional_domestic_tourism_clean <- regional_domestic_tourism %>%
  filter(feature_code == "S92000003") %>%
  arrange(date_code) %>% 
  select(-c(measurement, units)) %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>% 
  clean_names()

# Create International Passenger Survey Tibble  ------------------------------------------------------------

## Raw data available 'regional_spread_by_year_2002_-_2021_pivot.xlsx'. Pivot Table.

ips_2002_2019 <- tibble(year = c(2002,	2003,	2004,	2005,	2006,	2007,	2008,	2009,	2010,	2011,	
                                 2012,	2013,	2014,	2015,	2016,	2017,	2018,	2019),
                        visits = c(1581, 1565,	1881,	2392,	2732,	2791,	2492,	2564,	2319,	2367,	
                                   2249,	2436,	2690,	2635,	2871,	3432,	3729,	3460),
                        spend = c(806, 837, 994, 1208, 1439, 1367, 1241, 1397, 1422, 1478, 1398, 
                                  1671, 1868, 1720, 1944, 2459, 2379, 2538),
                        nights = c(15040, 14949,	19006, 24330,	26376, 24541, 19524, 21980, 21176,	17704, 
                                   17645, 19441, 21940, 21443,	22483, 26451,	25443, 27385))

ips_2002_2019_usa <- tibble(year = c(2002,	2003,	2004,	2005,	2006,	2007,	2008,	2009,	2010,	2011,	
                                 2012,	2013,	2014,	2015,	2016,	2017,	2018,	2019),
                        visits = c(386, 414, 405, 344, 475, 417, 340, 317, 263, 323, 302, 301, 
                                   399, 425, 487, 661, 570, 636),
                        spend = c(236, 228, 277, 195, 361, 257, 260, 208, 175, 219, 251, 262, 
                                  414, 397, 538, 645, 502, 717),
                        nights = c(2919, 3264, 3883, 2717, 4469, 3633, 2759, 2967, 2042, 2460, 
                                   2653, 2172, 3538, 4005, 4420, 5710, 4492, 4246))

# Import USA Spend and Visitor Data Demographic Data ------------------------------------------------------------

## Raw data available 'subregion_trend_by_purpose_country_2009-2021.xlsx'. Pivot Table.

usa_visitors_2009_2019 <- read_csv("data/raw_data/usa_visitors_region.csv") %>% clean_names()

usa_visitors_2009_2019_clean <- usa_visitors_2009_2019 %>% 
  pivot_longer(
    cols = c("x2009", "x2010", "x2011", "x2012", "x2013", "x2014", "x2015", "x2016", "x2017", "x2018", "x2019"),
    names_to = "year",
    values_to = "visits"
  ) %>% 
  mutate(year = str_remove(year, "x"))

usa_spend_2009_2019 <- read_csv("data/raw_data/usa_spend_region.csv") %>% clean_names()

usa_spend_2009_2019_clean <- usa_spend_2009_2019 %>% 
  pivot_longer(
    cols = c("x2009", "x2010", "x2011", "x2012", "x2013", "x2014", "x2015", "x2016", "x2017", "x2018", "x2019"),
    names_to = "year",
    values_to = "spend"
  ) %>% 
  mutate(year = str_remove(year, "x"))

usa_visit_spend_region <- usa_visitors_2009_2019_clean %>% inner_join(usa_spend_2009_2019_clean, 
                                                          by=c("region", "year")) %>% 
  select(-lat.y, -long.y)

# Clean Activities Data ------------------------------------------------------------

activities_clean <- activities %>%
  filter(tourism_activity != "All") %>% 
  select(-c(measurement, units)) %>%
  arrange(date_code) %>% 
  pivot_wider(names_from = breakdown_of_domestic_tourism, values_from = value) %>% 
  mutate(exp_per_visit = Expenditure / Visits,
         tourism_activity = recode(tourism_activity,
                                   "Day out to a beauty/health centre/spa, etc." = "Beauty/Health Centre/Spa",
                                   "Day trips/excursions for other leisure purpose" = "Day Trips for Other Leisure Purpose",
                                   "Entertainment - to a cinema, concert or theatre	" = "Entertainment (eg. Cinema, Concert)",
                                   "General day out/ to explore an area" = "General Day Out / Explore an Area",
                                   "Leisure activities e.g. hobbies & evening classes" = "Leisure Activities (eg. Hobbies)",
                                   "Night out to a bar, pub and/or club" = "Night Out (eg. Bar, Pub)",
                                   "Outdoor leisure activities e.g. walking, golf" = "Outdoor Leisure (eg. Golf)",
                                   "Shopping for items that you do not regularly buy" = "Shopping for Non-Regular Purchases",
                                   "Special personal events e.g. wedding, graduation" = "Special Personal Event (eg. Wedding)",
                                   "Special public event e.g. festival, exhibition" = "Special Public Event (eg. Festival)",
                                   "Sport participation, e.g. exercise classes, gym" = "Sport Participation",
                                   "Visited friends or family for leisure	" = "Visiting Friends/Family for Leisure",
                                   "Visitor attraction e.g. theme park, museum, zoo" = "Visitor Attraction (eg. Museum)",
                                   "Watched live sporting events (not on TV)" = "Attending Sporting Event",
                                   "Went out for a meal" = "Eating Out")) %>% 
  rename(year = date_code) %>% 
  clean_names()


# Write Clean Data To .CSV -----------------------------------------------------------

write_csv(all_demographics_clean, here("data/clean_data/all_demographics_clean.csv"))
write_csv(employment_demographics_clean, here("data/clean_data/employment_demographics_clean.csv"))
write_csv(gender_demographics_clean, here("data/clean_data/gender_demographics_clean.csv"))
write_csv(age_demographics_clean, here("data/clean_data/age_demographics_clean.csv"))
write_csv(marital_status_demographics_clean, here("data/clean_data/marital_status_demographics_clean.csv"))
write_csv(children_demographics_clean, here("data/clean_data/children_demographics_clean.csv"))
write_csv(car_demographics_clean, here("data/clean_data/car_demographics_clean.csv"))
write_csv(social_demographics_clean, here("data/clean_data/social_demographics_clean.csv"))
# write_csv(domestic_day_visits_clean, here("data/clean_data/domestic_day_visits_clean.csv"))
write_csv(regional_domestic_tourism_clean, here("data/clean_data/regional_domestic_tourism_clean.csv"))
write_csv(activities_clean, here("data/clean_data/activities_clean.csv"))
write_csv(usa_visit_spend_region, here("data/clean_data/usa_visit_spend_region_clean.csv"))

# Remove Objects from Environment -----------------------------------------------------------

rm(demographics)
rm(all_demographics_clean)
rm(employment_demographics_clean)
rm(gender_demographics_clean)
rm(age_demographics_clean)
rm(marital_status_demographics_clean)
rm(children_demographics_clean)
rm(car_demographics_clean)
rm(social_demographics_clean)
# rm(domestic_day_visits)
# rm(domestic_day_visits_clean)
rm(regional_domestic_tourism)
rm(regional_domestic_tourism_clean)
rm(activities)
rm(activities_clean)
rm(usa_visitors_2009_2019)
rm(usa_spend_2009_2019)
rm(usa_visitors_2009_2019_clean)
rm(usa_spend_2009_2019_clean)
rm(usa_visit_spend_region)