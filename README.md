# Reflections-Pollination-Ecology


This repository contains the code and data needed to reproduce the text processing and develop the figures from

> T. M. Knight et al. (2018) Reflections on, and visions for, the changing field of pollination ecology

[Download][1] or clone the repository then run the scripts using the `reflections_pollination_ecology.Rproj` file.

[1]: 


### R script files

There is an R script for each of the three figures from the manuscript:

- `/R/fig_1_comparison_word_cloud.R`
- `/R/fig_2_linear_models.R`
- `/R/fig_3_network.R`

Before running any of the mentioned scripts, run the `/R/01_packages.R` to load or install the needed packages.
Each of the three scripts calls at run-time some helper scripts (so the user should not worry about running the helpers).

Note that, figures 1 (the comparison word cloud) and 3 (the bigrame network) were also processed in [Inkscape](https://inkscape.org/en/).
