
FROM ubuntu:18.04
WORKDIR /usr/src/app
COPY script.sh .
RUN apt-get update && apt-get install -y curl && apt-get clean
CMD ./script.sh
