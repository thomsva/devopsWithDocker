## Excerise 3.1: A deployment pipeline to Heroku

A deployment pipeline was made for [this simple React app](https://github.com/thomsva/Hello). 

## Excercise 3.2-3.3 Building an image inside a container and using non root user

The solutions can be found in the 3.2 and 3.3 folders. 
## Exercise 3.4-3.6: Optimize image sizes
### Starting point (and using FROM node and FROM golang)
The starting sizes are fairly good because Alpine versions has been used all along. I found that using non-alpine (FROM node and FROM golang) versions would be 295MB larger for the frontend and 194MB larger for the backend.  

These were the actual starting points using Dockerfiles from excercise 3.3:
- frontend: 426MB (FROM node:16-alpine)
- backend: 447MB (FROM golang:1.16-alpine)

### After optimizing RUN commands

- frontend: 426MB (FROM node:16-alpine)
- backend: 447MB (FROM golang:1.16-alpine)

No noticable change in size after this change. Dockerfiles now look like this: 

Frontend:
```Dockerfile
FROM node:16-alpine
WORKDIR /app
COPY . .
RUN npm install \
  && npm run build \
  && npm install -g serve \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup
EXPOSE 5000
USER appuser
CMD ["serve", "-s", "-l", "5000", "build"]
```
Backend:
```Dockerfile
FROM golang:1.16-alpine
WORKDIR ./app
COPY . . 
RUN go build \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup
ENV PORT=8080
EXPOSE 8080
USER appuser
CMD ./server
```
### Removing parts not needed

For the frontend the source and node modules folder were deleted to save some space and keeping just the optimized production version in the build folder.

- frontend 186MB (FROM node:16-alpine)

Frontend:
```Dockerfile
FROM node:16-alpine
WORKDIR /app
COPY . .
RUN npm install \
  && npm run build \
  && npm install -g serve \
  && rm -rf node_modules \
  && rm -rf src \
  && rm -rf public \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup
EXPOSE 5000
USER appuser
CMD ["serve", "-s", "-l", "5000", "build"]
```

### Multi stage build
- frontend: 96.2MB (multistage build, FROM alpine)
- frontend: 10.4MB (multistage build, FROM alpine, thttpd)
- backend: 23.7MB (multistage build, FROM alpine)
- backend: 18.1MB (multistage build, FROM scratch)

The backend could be reduced to a very small size using a multi stage build. Using Alpine as a starting image was fairly straightforward and the image size was already under the required 25MB. Moving to `FROM scratch` turned out to be challenging. Google helped find a way to add the user in Alpine, then copy it to the final image. After this I still had a lot of trouble to start the executable. The error was `exec ./server: no such file or directory`. The solution seems to be adding CGO_ENABLED=0 in Alpine to build a standalone binary that would run by itself. Not having worked with GO before, I'm not sure about the details but now it works. 

Backend:
```Dockerfile
FROM golang:1.16-alpine AS buildstage
WORKDIR /app
COPY . . 
ENV PORT=8080
RUN CGO_ENABLED=0 go build \
  && adduser -D -g '' appuser

FROM scratch 
WORKDIR /server
COPY --from=buildstage /app /server
COPY --from=buildstage /etc/passwd /etc/passwd
EXPOSE 8080
USER appuser
CMD  ["./server"]
```
Next was to change the frontend to a multistage build. The size was reduced to half. In this solutuion Serve is still used, so Node is needed in the container. 

Frontend:
```Dockerfile
FROM node:16-alpine AS build
WORKDIR /app
COPY . .
RUN npm install \
  && npm run build 

FROM alpine
RUN apk add --update npm \
  && npm install -g serve \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=build /app/build/ /app/build/
EXPOSE 5000
RUN chown -R appuser:appgroup /app/build
USER appuser
CMD ["serve", "-s", "-l", "5000", "build"]
```
The image could probably be made smaller using another tool to serve the content. After some searcing for potential candidates I found a program called [thttpd](https://www.acme.com/software/thttpd/) (tiny/turbo/throttling HTTP server) and instructions how to use it. Now the image size is reduced to only 10MB and everything seems to work fine. 

Frontend:
```Dockerfile
FROM node:16-alpine AS build
WORKDIR /app
COPY . .
RUN npm install \
  && npm run build 

FROM alpine

RUN apk add thttpd \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=build /app/build/ /app/build/
EXPOSE 5000
RUN chown -R appuser:appgroup /app/build
USER appuser
CMD ["thttpd", "-D", "-h", "0.0.0.0", "-p", "5000", "-d", "build", "-u", "appuser", "-l", "-", "-M", "60"]

```

> Summary: The backend image size was reduced to 18.1MB and the frontend to 10.4MB.

## Excercise 3.7

Optimizing the Docker configuration of the simple React app used in 3.1.

The original Dockerfile looks like this: 
```Dockerfile
FROM node:16.14-alpine
WORKDIR /app
COPY package*.json /app/
RUN npm ci
COPY ./ /app
RUN npm run build
RUN npm install serve -g
CMD ["sh", "-c", "serve -l tcp://0.0.0.0:${PORT} -s /app/build"]
```

The image size is 427MB. Without Alpine it would be much larger. 

The Dockerfile can be optimized by 
- combining RUN statements,
- using a two-stage build,
- using a lighter weight web server,
- running the app with a non-root user.

```Dockerfile
FROM node:16.14-alpine as build
WORKDIR /app
COPY ./ /app
RUN npm ci  && npm run build

FROM alpine
WORKDIR /app
COPY --from=build /app/build/ /app/build/
RUN apk add thttpd \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup \
  && chown -R appuser:appgroup /app/build
EXPOSE 5000
USER appuser
CMD ["thttpd", "-D", "-h", "0.0.0.0", "-p", "5000", "-d", "build", "-u", "appuser", "-l", "-", "-M", "60"]
```
Note: This example was made to work locally on my own machine. To work on Heroku the port would need to be specified like in the original dockerfile. 

> Result: The size of the image decreased from 427MB to 11MB.

