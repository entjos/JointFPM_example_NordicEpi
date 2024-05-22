# ESTIMATION OF THE MEAN NUMBER OF HOSPITALISATION AFTER COLON CANCER SURGERY

- Author: Joshua Entrop
- Email: joshua.entrop@ki.se

## Figures

Each figure included in the presentation has one corresponding script that was used for creating the figure. If you are interested in re-creating the figures included in the presentation just take a look at the `./scripts` folder. All packages and package version requiered for the exmaple analysis are specified in the `renv.lock` file.

```
(PROJECT ROOT)
+--- scripts
|    +--- 1_prepare_data.R
|    +--- 2_figure_2.R
|    +--- 3_figure_3.R
|    +--- 4_figure_4.R
|    +--- 5_figure_5.R
+--- renv.lock
```

## Reproducing the example

System requirements:

- R version 4.3.1
- GNU make

This project includes a `makefile` which can be used to re-run the example analysis. The `makefile` will re-create all figures included in the manuscript. Running the make file requires you to install `GNU make` on your computer, if you haven't done so before. A Windows installation of `GNU make` can be found [here](https://gnuwin32.sourceforge.net/packages/make.htm) or as part of `Rtools`. All packages and package versions required for the analysis are defined in the `renv.lock` file. In order to reproduce the analysis please follow the steps listed below.

   1. Open the `mean_no_events.Rproj` file. This will open a new RStudio session on your computer.
   2. Make sure that you are running R version 4.3.1
   3. If necessary install the package `{renv}`.
   4. Run the following command in your R console `renv::init()`and chose the following option in the prompt: "1: Restore the project from the lockfile."
   5. Open your shell or console in the project folder and run the following command `make all`. This will prompt make to re-run the whole analysis. Please be aware that re-running the whole simulation study might take several days. Running the makefile requires you to have R available on your system path. Otherwise, you can open the makefile using your favourite text editor and replace `R.exe` with the whole path to your `R.exe` file in the row starting with `REXE`, e.g. `RCALL = "C:/programmes/R/R-4.3.1/bin/R.exe"`.

Don't hesitate to write me an email if you should have troubles re-running the analysis for this project.

## Data provenance

The example dataset `data/readmission.rds` used in the illustrative example was first published in the [`frailtypack`](https://cran.r-project.org/package=frailtypack) package for R under a GPL-2 licence.