################################################################################
# Project: Example NordicEpi conference 2024
# 
# Title: Plot Comparison CIF and Mean Number of Events
# 
# Author: Joshua Entrop
# 
################################################################################

# Load estimates
load("./data/cif_estimates.RData")
load("./data/cef_estimates.RData")

# 1. Create combined plot ------------------------------------------------------

# Define ooutput device
pdf("./graphs/figure_5.pdf",
    height = 7,
    width  = 14)

# Set up graph parameters
par(las = 1,
    mfrow = c(1, 2),
    bg  = "#EDF4F4",
    cex = 1.4)

#   1.1 Plot CIF ===============================================================

plot.new()

plot.window(xlim = c(0, 1500),
            ylim = c(0, 2))

# Axes
axis(1)
axis(2)

# Add CIFs
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

# Reference line at 1000 days
abline(v = 1000,
       lty = 2,
       lwd = 2)

# Get CIFs at 1000 days
cif_chemo0_1000 <- cif[[1]]$fit[which.min(abs(cif[[1]]$t.stop - 1000))]
cif_chemo1_1000 <- cif[[2]]$fit[which.min(abs(cif[[2]]$t.stop - 1000))]

# Add text annotations
text(1000 - 130, cif_chemo0_1000 + 0.03, 
     bquote(
       italic(
         .(
           paste0(
             round(cif_chemo0_1000, 2)
           )
         )
       )
     ),
     col = "#FF876F")

text(1000 - 130, cif_chemo1_1000 + 0.03, 
     bquote(
       italic(
         .(
           paste0(
             round(cif_chemo1_1000, 2)
           )
         )
       )
     ),
     col = "#4F0433")

# Add CIF ratio at 1000 days
text(1020, 2, 
     bquote(
       italic(
         .(
           paste0(
             "Ratio: ", format(round(cif_chemo0_1000 / cif_chemo1_1000, 2),
                               nsmall = 2)
           )
         )
       )
     ),
     adj = 0,
     col = "black")

# Titles
title(x = "Days Since Colon Cancer Surgery",
      y = "Cumulative Incidence of Readmissions")

title(main = "A) Cumulative Incidence of Readmissions",
      adj  = 0)

#   1.2 Plot Mean Number of Events ---------------------------------------------

plot.new()

plot.window(xlim = c(0, 1500),
            ylim = c(0, 2))

# Axes
axis(1)
axis(2)

# Add Mean number of event functions
lines(cef[[1]]$t.stop,
      cef[[1]]$fit,
      col = "#FF876F",
      lwd = 2)

lines(cef[[2]]$t.stop,
      cef[[2]]$fit,
      col = "#4F0433",
      lwd = 2)

# Reference line at 1000 days
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

# Add mean number of events ratio at 1000 days
text(1020, 2, 
     bquote(
       italic(
         .(
           paste0(
             "Ratio: ", format(round(cef_chemo0_1000 / cef_chemo1_1000, 2),
                               nsmall = 2)
           )
         )
       )
     ),
     adj = 0,
     col = "black")

# Titles
title(x = "Days Since Colon Cancer Surgery",
      y = "Mean Number of Readmissions")

title(main = "B) Mean Number of Readmissions",
      adj  = 0)

dev.off()

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT