## Exercise 3.2: Building images inside of a container

Build the image and give it a name: 

`docker build . -t deployer`

Run the newly built container. The container works as DoD (Docker out of Docker), so a volume `-v /var/run/docker.sock:/var/run/docker.sock` is added to the command to give access to the Docker daemon of the host machine. Other parameters needed are: 

-r GitHub repository full path
-u DockerHub username
-p DockerHub password
-n Name of the image to be deployed

When running the container, it clones the given repository and builds it into a docker image based on a dockerfile found in the root of the project. It then logs in to DockerHub using the provided credentials, and pushes the image with the given name and a tag :latest. 

`docker run -v /var/run/docker.sock:/var/run/docker.sock deployer -r https://github.com/user/reponame.git -u user -n imagename -p secret`

