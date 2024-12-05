#!/bin/bash

cd modules/lambda/
mkdir -p raw_data_etl_layer/python/lib/python3.8/site-packages
cd raw_data_etl_layer/python/lib/python3.8/site-packages

RED='\033[0;31m' # ANSI Escape code
NC='\033[0m' # No Color

zip_binary_dir=$(which zip)
if [[ -z "$zip_binary_dir" ]]
  then
    # -e flag to respect escapes
    echo -e "${RED}ERROR:${NC} Please Install the zip package on your local machine"
    exit 1
fi

docker_dir=$(which docker)
if [[ -z "$docker_dir" ]]
  then
    # -e flag to respect escapes
    echo -e "${RED}ERROR:${NC} Please Install docker on your local machine"
    exit 1
fi

###################################### BEGIN ##########################################
#################### PYTHON DEPENDENCIES TO PACK INTO LAYER ###########################
touch derp.txt
echo "dependencies for python" >> derp.txt
####################################### END ###########################################

# create zip and then delete node_modules
cd ../../../..
zip -r python3.8_layer.zip python/
rm -rf python/
layer_zip_dir="$(pwd)/python3.8_layer.zip"
