################################################################################
# Project: Example NordicEpi conference 2024
# 
# Title: Plot Standardised Mean Number of Events Function
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(JointFPM)
library(dplyr)
library(fastDummies)

# Load readmission data included in {frailtypack}
comb_data <- read.csv("./data/readmission_stacked.csv")

# Load cef estimates
load("./data/cef.RData")

# Create dummies for CCI and Dukes stage
comb_data <- dummy_cols(comb_data, c("cci_dx", "dukes")) |> 
  rename_with(~ gsub("-", "_", .x))

# 1. Estimate Mean Number of Events --------------------------------------------

#   1.1 Fit adjusted model =====================================================

# Fit model with best model fit
adj_fit <- JointFPM(
  surv = Surv(t.start, t.stop, status, 
              type = 'counting') ~ 1,
  re_model = ~ female * chemo + cci_dx_1_2 + cci_dx_3 + dukes_C + dukes_D,
  ce_model = ~ female * chemo + cci_dx_1_2 + cci_dx_3 + dukes_C + dukes_D,
  re_indicator = "re",
  ce_indicator = "ce",
  df_ce = 2,
  df_re = 3,
  tvc_re_terms = list(chemo = 1),
  tvc_ce_terms = list(chemo = 2),
  cluster = "id",
  data = comb_data
)

#   1.2 Estimate standardised CIF ==============================================

# Predict the mean number of events
std_cef <- lapply(0:1, function(i){
  
  predict(adj_fit,
          type = "marg_mean_no",
          newdata = data.frame(chemo = i),
          t =  seq(0, 1500, length.out = 100),
          ci_fit = FALSE)
  
})

# 2. Plot Standardised and non-standardised estimates --------------------------

# Define output device
pdf("./graphs/figure_4.pdf",
    height = 7,
    width  = 7)

# Set up graph parameters
par(las = 1,
    bg  = "#EDF4F4",
    cex = 1.4)

plot.new()

plot.window(xlim = c(0, 1500),
            ylim = c(0, 2))

# Axes
axis(1)
axis(2)

# Add non-standardised mean number of event functions
lines(cef[[1]]$t.stop,
      cef[[1]]$fit,
      col = "#FF876F",
      lwd = 2)

lines(cef[[2]]$t.stop,
      cef[[2]]$fit,
      col = "#4F0433",
      lwd = 2)

# Add standardised mean number of event functions
lines(std_cef[[1]]$t.stop,
      std_cef[[1]]$fit,
      col = "#FF876F",
      lwd = 2,
      lty = 2)

lines(std_cef[[2]]$t.stop,
      std_cef[[2]]$fit,
      col = "#4F0433",
      lwd = 2,
      lty = 2)

# Legend
legend("topleft",
       inset = 0.05,
       legend = c("Non-Standardised", "Standardised"),
       lty = c(1, 2),
       lwd = 2,
       col = c("#4F0433", "#4F0433"))

# Titles
title(x = "Days Since Colon Cancer Surgery",
      y = "Mean Number of Readmissions")

title(main = "Mean Number of Readmissions",
      adj  = 0)

dev.off()

# //////////////////////////////////////////////////////////////////////////////
# END OF R-FILE