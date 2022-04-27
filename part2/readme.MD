## Exercise 2.5 Scaling

Start the services with the command `docker-compose up --scale compute=3` to run 3 instances of compute.   

## Excerise 2.11

For this excercise I configured a simple development environment for my React/NodeJs project.  

The docker-compose.yml file:
```yml
version: "3.8"

services:
  web:
    build: ./web
    ports:
      - 3000:3000
    container_name: metricsGreen_web
    volumes:
      - ./web:/usr/src/web

  server:
    build: ./server
    volumes:
      - ./server:/usr/src/server
    ports:
      - 4000:4000
    container_name: metricsGreen_server

  db:
    image: postgres:14.2-alpine3.15
    container_name: metricsGreen_db
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - db:/var/lib/postgresql/data
    ports:
      - 5432:5432

  adminer:
    image: adminer
    restart: always
    environment:
      ADMINER_DEFAULT_SERVER: db
    ports:
      - 3003:8080

volumes:
  db:
```


The Dockerfile for the frontend:
```dockerfile
FROM node:16.14-alpine3.14
COPY ./ /usr/src/web
WORKDIR /usr/src/web
EXPOSE 3000
CMD [ -d "node_modules" ] && npm start || npm ci && npm start
```
The Dockerfile for the backend: 
```dockerfile
FROM node:16.14-alpine3.14
COPY ./ /usr/src/web
WORKDIR /usr/src/web
EXPOSE 4000
CMD [ -d "node_modules" ] && npm run dev || npm ci && npm run dev
```
The last line of the Dockerfile runs `npm ci` in the case that the node_modules folder is missing. This gives a potential benefit of consistency between different development computers as dependencies are always installed from inside the container after node_modules have been deleted. 
