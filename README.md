# A Stata + R Docker Project

A docker image for JEL-2021-1623. For details on setting it up, see [https://github.com/AEADataEditor/docker-stata-R-example](https://github.com/AEADataEditor/docker-stata-R-example).

> THIS IS STILL WORK IN PROGRESS.

## Notes

This requires both R and Stata, because R is used to create and download the IPUMS extract used here. Requires (as of March 2022) participation in the IPUMS Beta for the API.

### Step 1

Upload JSON specification to IPUMS API, wait for files to be created, then download, and convert to Stata

### Step 2

Run Stata code.

> Currently only works for Fig 1.

## Pulling it all together

The file `run` executes it all. If you have the software installed locally (R, Stata), can be run on a Unix-like system:

```{bash}
./run
```

## Running Docker

Alternatively, if you have Docker installed, and a Stata license handy,  use the `run-docker.sh` script or `run-interactive.sh` to launch an Rstudio session for debugging. About 5min runtime.

```{bash}
./run-docker.sh 
```

## Details

The R functionality leverages the [IPUMS API](https://beta.developer.ipums.org/docs/apiprogram/clients/). Follow instructions there to set it up.

Alternatively, the R functionality to download the data can be skipped. Once the extract has been created, you can go to [My Data|IPUMS](https://usa.ipums.org/usa-action/data_requests/download) to download the extract. Code will need to be adjusted.


