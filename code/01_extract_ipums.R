# this will get the IPUMS extract
Sys.getenv("IPUMS_API_KEY")
# See https://tech.popdata.org/ipumsr/dev/articles/ipums-api.html#sharing-an-extract-definition-1 for more details.
library(ipumsr)
extract.spec <- file.path("data","author-extract.Rds")
# Recover the extract specification
clone_extract <- define_extract_from_json(
                     file.path("code","author-extract.json"), 
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
# when that finishes, we can save it.
path_to_ddi_file <- download_extract(downloadable_extract,
                                     download_dir=file.path("data"),
                                     overwrite = TRUE)
