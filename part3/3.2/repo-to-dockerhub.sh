#!/bin/sh

# -r Github repository
# -u Dockerhub username
# -p Dockerhub password
# -n Image name

while getopts r:u:n:p: flag
do
    case "${flag}" in
        r) repository=${OPTARG};;
        u) user=${OPTARG};;
        n) name=${OPTARG};;
        p) password=${OPTARG};;
    esac
done
echo Cloning $repository

git clone $repository $name

echo Building Docker image

echo name $name

echo user $user

echo repo $repository

cd $name

docker build . -t $user/$name:latest

echo Login to Dockerhub as $user 

docker login -u $user -p $password

echo docker push $user/$name:latest

docker push $user/$name:latest


