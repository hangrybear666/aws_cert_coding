#!/bin/bash

DOCKER_IMG="public.ecr.aws/lambda/nodejs:20"

LAYER_DIR="$(pwd)/modules/lambda/image_processing_layer/nodejs/node20/"
ZIP_DIR="$(pwd)/modules/lambda/image_processing_layer/"
mkdir -p $LAYER_DIR

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

docker pull $DOCKER_IMG

docker run --rm --entrypoint /bin/bash -v $LAYER_DIR:/var/task $DOCKER_IMG -c "
################## DEPENDENCY INSTALLATION BEGIN ###############
npm i sharp@0.33.5
################## DEPENDENCY INSTALLATION END #################
"

# create zip
cd $ZIP_DIR
zip -r nodejs20.x_layer.zip nodejs
docker run --rm --entrypoint /bin/bash -v $ZIP_DIR:/var/task $DOCKER_IMG -c "
rm -rf nodejs/
"
