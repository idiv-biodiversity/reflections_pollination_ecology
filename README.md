# Reflections-Pollination-Ecology


This repository contains the code and data needed to reproduce the text processing and develop the figures from

> T. M. Knight et al. (2018) Reflections on, and visions for, the changing field of pollination ecology

[Download][1] or clone the repository then run the scripts using the `reflections_pollination_ecology.Rproj` file ([R Studio][2] is needed).

[1]: https://github.com/idiv-biodiversity/reflections_pollination_ecology/archive/master.zip
[2]: https://www.rstudio.com/products/rstudio/download/


### R script files

There is an R script for each of the three figures from the manuscript:

- `/R/fig_1_comparison_word_cloud.R`
- `/R/fig_2_linear_models.R`
- `/R/fig_3_network.R`

Before running the scripts, execute `/R/01_packages.R` to load (and install if the case) the needed R packages. Check the comments in the script for some suggestions for installing older versions of the packages.

Note also that, each of the three scripts calls at run-time some helper scripts (so the user should not worry about running the helpers).

Note that, figures 1 (the comparison word cloud) and 3 (the bigrame network) were also further processed in [Inkscape](https://inkscape.org/en/).
