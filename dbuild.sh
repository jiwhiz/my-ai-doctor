#!/bin/bash
set -e  # Exit the script if any command fails

echo "Today is " `date`

cd ./mydoctor/mydoctor-api
docker build -t mydoctor-api .
echo "Docker build mydoctor-api succeeded!"
cd ../..

cd ./mydoctor/mydoctor-ui
docker build -t mydoctor-ui .
echo "Docker build mydoctor-ui succeeded!"
cd ../..

cd ./myhealth/myhealth-api
docker build -t myhealth-api .
echo "Docker build myhealth-api succeeded!"
cd ../..

cd ./myhealth/myhealth-ui
docker build -t myhealth-ui .
echo "Docker build myhealth-ui succeeded!"
cd ../..
