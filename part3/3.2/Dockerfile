FROM yobasystems/alpine-docker

# Install git 
RUN apk update && apk add git 

WORKDIR ./
COPY repo-to-dockerhub.sh .
RUN chmod +x repo-to-dockerhub.sh
ENTRYPOINT ["sh", "repo-to-dockerhub.sh"]

