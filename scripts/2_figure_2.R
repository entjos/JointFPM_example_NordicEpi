################################################################################
# Project: Example NordicEpi conference 2024
# 
# Title: Plot CIF of hospitalizations
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(JointFPM)
library(dplyr)

# Load readmission data included in {frailtypack}
comb_data <- read.csv("./data/readmission_stacked.csv")

# 1 . Create time-to-first-event dataset ---------------------------------------

# create dataset with time to first hospitalisation
first_hospitalisation_df <- comb_data |>
  filter(re == 1)                     |> 
  arrange(id, t.stop)                 |> 
  slice_head(n = 1,
             by = id)

# create dataset with time to death
death_df <- comb_data |>
  filter(re == 0) 

# Create combined dataset
time_first_event <- rbind(first_hospitalisation_df, death_df) |> 
  arrange(id)

# 2. Estimate CIF --------------------------------------------------------------

#   2.1 Test model for different dfs ===========================================

model_fits <- test_dfs_JointFPM(surv = Surv(t.start, t.stop, status, 
                                            type = 'counting') ~ 1,
                                re_model = ~ chemo,
                                ce_model = ~ chemo,
                                re_indicator = "re",
                                ce_indicator = "ce",
                                dfs_ce = 1:5,
                                dfs_re = 1:5,
                                tvc_re_terms = list(chemo  = 1:2),
                                tvc_ce_terms = list(chemo  = 1:2),
                                cluster = "id",
                                data = time_first_event)

# Get the dfs for the best model fit
model_fits[which.min(model_fits$AIC), ]

#   2.2 Get model fit ==========================================================

# Fit model with best model fit
fit <- JointFPM(surv = Surv(t.start, t.stop, status, type = 'counting') ~ 1,
                re_model =  ~ chemo,
                ce_model =  ~ chemo,
                re_indicator = "re",
                ce_indicator = "ce",
                df_ce = 2,
                df_re = 2,
                tvc_re_terms = list(chemo  = 1),
                tvc_ce_terms = list(chemo  = 2),
                cluster = "id",
                data = time_first_event) 

#   2.3 Estimate CIF ===========================================================

# Predict the mean number of events
cif <- lapply(0:1, function(i){
  
  predict(fit,
          type = "mean_no",
          newdata = data.frame(chemo = i),
          t =  seq(0, 1500, length.out = 100),
          ci_fit = FALSE)
  
})

# 3. Plot CIF ------------------------------------------------------------------

# Define output device
pdf("./graphs/figure_2.pdf",
    height = 7,
    width  = 7)

# Set up graph parameters
par(las = 1,
    bg  = "#EDF4F4",
    cex = 1.4)

plot.new()

plot.window(xlim = c(0, 1500),
            ylim = c(0, 1))

# Axes
axis(1)
axis(2)

# Plot CIFs
lines(cif[[1]]$t.stop,
      cif[[1]]$fit,
      col = "#FF876F",
      lwd = 2)

lines(cif[[2]]$t.stop,
      cif[[2]]$fit,
      col = "#4F0433",
      lwd = 2)

# Legend
legend("topleft",
       inset = 0.05,
       title = "Chemo Treatment",
       legend = c("No", "Yes"),
       lty = 1,
       lwd = 2,
       col = c("#FF876F", "#4F0433"))

# Reference line at 100 days
abline(v = 1000,
       lty = 2,
       lwd = 2)

# Get CIF at 1000 days
cif_chemo0_2yr <- cif[[1]]$fit[which.min(abs(cif[[1]]$t.stop - 1000))]
cif_chemo1_2yr <- cif[[2]]$fit[which.min(abs(cif[[2]]$t.stop - 1000))]

# Add text annotations
text(1000 - 130, cif_chemo0_2yr + 0.03, 
     bquote(
       italic(
         .(
           paste0(
             round(cif_chemo0_2yr * 100, 0), "%"
           )
         )
       )
     ),
     col = "#FF876F")

text(1000 - 130, cif_chemo1_2yr + 0.03, 
     bquote(
       italic(
         .(
           paste0(
             round(cif_chemo1_2yr * 100, 0), "%"
           )
         )
       )
     ),
     col = "#4F0433")

# Titles
title(x = "Days Since Colon Cancer Surgery",
      y = "Cumulative Incidence of Hospital Readmissions")

title(main = "Readmissions After Colon Cancer Surgery",
      adj  = 0)

dev.off()

# 4. Export estimates ----------------------------------------------------------

save(cif,
     file = "./data/cif.RData")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT