#install.packages("ipumsr")
remotes::install_github(
  "ipums/ipumsr", 
  build_vignettes = FALSE, 
  dependencies = TRUE
)
install.packages("here")
