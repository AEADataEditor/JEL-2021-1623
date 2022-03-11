# this will get the IPUMS extract
Sys.getenv("IPUMS_API_KEY")
# See https://tech.popdata.org/ipumsr/dev/articles/ipums-api.html#sharing-an-extract-definition-1 for more details.
library(ipumsr)
library(haven)
library(here)

# Define paths
basepath <- here()
datapath <- file.path(basepath,"data")
codepath <- file.path(basepath,"code")

jsonpath     <- file.path(codepath,"author-extract.json")
extract.spec <- file.path(datapath,"author-extract.Rds")
dtasavepath  <- file.path(datapath,"ipums_extract.dta")

# Recover the extract specification
clone_extract <- define_extract_from_json(
                     jsonpath, 
                     "usa")

if ( file.exists(extract.spec)) {
  submitted_extract <- readRDS(extract.spec)
} else {
  # Submit the extract
  submitted_extract <- submit_extract(clone_extract)
  saveRDS(submitted_extract,extract.spec)
}
# Provide summary info on the submitted extract
print(submitted_extract)
# Initial status
get_extract_info(submitted_extract)$status
# This will continue waiting for the extract to be created
downloadable_extract <- wait_for_extract(submitted_extract)
# when that finishes, we can save it, if we haven't done so before

datgzfile <- basename(downloadable_extract[["download_links"]][["data"]][["url"]])
ddifile   <- basename(downloadable_extract[["download_links"]][["ddi_codebook"]][["url"]])
if ( file.exists(file.path(datapath,datgzfile))) {
  message(paste0("File already downloaded, see ",datgzfile))
  path_to_ddi_file <- file.path(datapath,ddifile)
  if ( ! file.exists(path_to_ddi_file)) {
    message("However, there seems to be a problem.")
  }
  
} else {
   path_to_ddi_file <- download_extract(downloadable_extract,
                                     download_dir=datapath,
                                     overwrite = TRUE)
}
data <- read_ipums_micro(path_to_ddi_file)
colnames(data) <- tolower(colnames(data))
write_dta(data,dtasavepath)
