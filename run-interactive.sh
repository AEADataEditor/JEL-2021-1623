#!/bin/bash
# This script is a variant of run.sh and used for development in the Rstudio environment.

if [[ -f config.txt ]]
then 
   configfile=config.txt
else 
   configfile=init.config.txt
fi

# name of the file to run
file=code/main.do


echo "================================"
echo "Pulling defaults from ${configfile}:"
cat $configfile
echo "--------------------------------"

source $configfile

echo "================================"
echo "Running docker:"
set -ev

# When we are on Github Actions
if [[ $CI ]] 
then
   DOCKEROPTS="--rm"
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   DOCKEROPTS="-it --rm -u $(id -u ${USER}):$(id -g ${USER}) "
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi

# ensure that the directories are writable by Docker
chmod a+rwX code code/*
chmod a+rwX data 

# a few names
basefile=$(basename $file)
codedir=$(dirname $file)
logfile=${file%*.do}.log

# run the docker and the Stata file
# note that the working directory will be set to '/code' by default

time docker run $DOCKEROPTS \
  -u 0 \
  -v ${STATALIC}:/usr/local/stata/stata.lic \
  -v $(pwd):/home/rstudio \
  -v $(pwd)/${codedir}:/code \
  -v $(pwd)/data:/data \
  -e DISABLE_AUTH=true -p 8787:8787 \
  $DOCKERIMG:$TAG "$@"


