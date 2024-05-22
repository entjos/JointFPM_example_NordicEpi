################################################################################
# Project: Example NordicEpi conference 2024
# 
# Title: Transform data into stacked format
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(dplyr)

# Load readmission data included in {frailtypack}
load("./data/readmission.rda")

# 1. Prepare data for analysis -------------------------------------------------

# limit to 1500 days of follow-up
readmission <- readmission |> 
  filter(t.start < 1500)   |> 
  mutate(death  = if_else(t.stop >= 1500, 0     , death),
         event  = if_else(t.stop >= 1500, 0     , event),
         t.stop = if_else(t.stop < 1500 , t.stop, 1500))

# Create one dataset for competing event times
ce_data <- readmission |> 
  group_by(id)         |>  
  slice_max(n = 1,
            order_by = t.stop) |>  
  mutate(status   = death,
         ce       = 1,
         re       = 0,
         t.start  = 0)

# Create one dataset for recurrent event times
re_data <- readmission |>  
  mutate(status = event,
         ce     = 0,
         re     = 1)

# Stack the datasets for recurrent and competing event times
comb_data <- bind_rows(ce_data, re_data) |> 
  mutate(female       = if_else(sex   == "Female",  1, 0),
         chemo        = if_else(chemo == "Treated", 1, 0),
         female_chemo = female * chemo)

# Create varialbe charlston at diagnosis
comb_data <- comb_data |> 
  group_by(id)         |> 
  mutate(cci_dx = first(charlson, order_by = enum))

# Save prepared dataset
write.csv(comb_data, "./data/readmission_stacked.csv")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-FILE