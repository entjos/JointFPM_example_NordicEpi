#//////////////////////////////////////////////////////////////////////////////
# Project: Example NordicEpi conference 2024
# File: Make file
#
# Author: Joshua Entrop
#         Department of Medicine, Solna | Karolinska Institutet
#         171 77 Stockholm | Maria Aspmans gata 30A
#         +46 76 255 20 58 |
#         joshua.entrop@ki.se | ki.se
#
#//////////////////////////////////////////////////////////////////////////////

# Define R call
# SHELL = <PATH TO SEHLL> This only needs to be specified in case you are on 
# system where you don't automatically have acess to the shell
REXE  = R.exe # Please replace R.exe with the full path to your R installation
              # if you don't have R on your system path

RCALL = $(REXE) CMD BATCH --no-save

# Define repositories
SCRIPTS = ./scripts
OUT     = ./log

# Define all call
all: $(OUT)/1_prepare_data.out \
     $(OUT)/2_figure_2.out \
     $(OUT)/3_figure_3.out \
     $(OUT)/4_figure_4.out \
     $(OUT)/5_figure_5.out

# Define target
$(OUT)/1_prepare_data.out: $(SCRIPTS)/1_prepare_data.R
	$(RCALL) $< $@
	
$(OUT)/2_figure_2.out: $(SCRIPTS)/2_figure_2.R \
	$(OUT)/1_prepare_data.out
	$(RCALL) $< $@
	
$(OUT)/3_figure_3.out: $(SCRIPTS)/3_figure_3.R \
	$(OUT)/1_prepare_data.out
	$(RCALL) $< $@
	
$(OUT)/4_figure_4.out: $(SCRIPTS)/4_figure_4.R \
	$(OUT)/1_prepare_data.out
	$(RCALL) $< $@
	
$(OUT)/5_figure_5.out: $(SCRIPTS)/5_figure_5.R \
	$(OUT)/2_figure_2.out \
	$(OUT)/3_figure_3.out
	$(RCALL) $< $@

#//////////////////////////////////////////////////////////////////////////////
# END OF MAKE-FILE