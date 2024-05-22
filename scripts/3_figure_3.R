################################################################################
# Project: Example NordicEpi conference 2024
# 
# Title: Plot Mean Number of Events Function
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(JointFPM)

# Load readmission data included in {frailtypack}
comb_data <- read.csv("./data/readmission_stacked.csv")

# 1. Estimate Mean Number of Events --------------------------------------------

#   1.1 Test model for different dfs ===========================================

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
                                data = comb_data)

# Get the dfs for the best model fit
model_fits[which.min(model_fits$AIC), ]

#   1.2 Get model fir ==========================================================

# Fit model with best model fit
fit <- JointFPM(surv = Surv(t.start, t.stop, status, type = 'counting') ~ 1,
                re_model =  ~ chemo,
                ce_model =  ~ chemo,
                re_indicator = "re",
                ce_indicator = "ce",
                df_ce = 2,
                df_re = 3,
                tvc_re_terms = list(chemo  = 1),
                tvc_ce_terms = list(chemo  = 2),
                cluster = "id",
                data = comb_data)

#   1.3 Estimate CIF ===========================================================

# Predict the mean number of events
cef <- lapply(0:1, function(i){
  
  predict(fit,
          type = "mean_no",
          newdata = data.frame(chemo = i),
          t =  seq(0, 1500, length.out = 100),
          ci_fit = FALSE)
  
})

# Predict the mean number of events
cef_diff <- predict(fit,
                    type = "diff",
                    newdata = data.frame(chemo = 0),
                    exposed = function(x) transform(x, chemo = 1),
                    t =  seq(0, 1500, length.out = 100),
                    ci_fit = TRUE)

# 2. Plot data -----------------------------------------------------------------

#   2.1 Plot Mean Number of Events =============================================  

# Define output device
pdf("./graphs/figure_3.pdf",
    height = 7,
    width  = 14)

# Set up graph parameters
par(las = 1,
    mfrow = c(1, 2),
    bg  = "#EDF4F4",
    cex = 1.4)

plot.new()

plot.window(xlim = c(0, 1500),
            ylim = c(0, 2))

# Axes
axis(1)
axis(2)

# Plot mean number of events function
lines(cef[[1]]$t.stop,
      cef[[1]]$fit,
      col = "#FF876F",
      lwd = 2)

lines(cef[[2]]$t.stop,
      cef[[2]]$fit,
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

abline(v = 1000,
       lty = 2,
       lwd = 2)

# Get mean number of events at 1000 days
cef_chemo0_1000 <- cef[[1]]$fit[which.min(abs(cef[[1]]$t.stop - 1000))]
cef_chemo1_1000 <- cef[[2]]$fit[which.min(abs(cef[[2]]$t.stop - 1000))]

# Add text annotations
text(1000 - 120, cef_chemo0_1000 + 0.03, 
     bquote(
       italic(
         .(
           paste0(
             round(cef_chemo0_1000, 2)
           )
         )
       )
     ),
     col = "#FF876F")

text(1000 - 120, cef_chemo1_1000 + 0.03, 
     bquote(
       italic(
         .(
           paste0(
             round(cef_chemo1_1000, 2)
           )
         )
       )
     ),
     col = "#4F0433")

# Titles
title(x = "Days Since Colon Cancer Surgery",
      y = "Mean Number of Readmissions")

title(main = "A) Mean Number of Readmissions",
      adj  = 0)

#   2.2 Plot Difference in The Mean Number of Events ===========================

plot.new()

plot.window(xlim = c(0, 1500),
            ylim = c(-0.2, 1.6))

# Axes
axis(1)
axis(2, at = seq(-0.2, 1.6, 0.2))

# CIs for difference in mean number of events
polygon(c(cef_diff$t.stop, rev(cef_diff$t.stop)),
        c(cef_diff$uci   , rev(cef_diff$lci)),
        col = "#eddbe4",
        border = "#4F0433")

# Difference estimates
lines(cef_diff$t.stop,
      cef_diff$fit,
      col = "#4F0433",
      lwd = 2)

# Line at 1000 days
abline(v = 1000,
       lty = 2,
       lwd = 2)

# Get difference at 1000 days 
cef_diff_1000 <- cef_diff[which.min(abs(cef_diff$t.stop - 1000)), ]

# Add text annotations
text(990, 1.5, 
     bquote(
       italic(
         .(
           paste0(
             round(cef_diff_1000$fit, 2), 
             " (95%CI: ", 
             round(cef_diff_1000$lci, 2),
             "-",
             round(cef_diff_1000$uci, 2),
             ")"
           )
         )
       )
     ),
     adj = 1,
     col = "black")

# Titles
title(x = "Days Since Colon Cancer Surgery",
      y = "Difference in The Mean Number of Readmissions")

title(main = "B) Difference in Readmissions",
      adj  = 0)

dev.off()

# 3. Export estimates ----------------------------------------------------------

save(cef,
     file = "./data/cef.RData")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT