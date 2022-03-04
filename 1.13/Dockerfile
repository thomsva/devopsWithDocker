FROM golang:1.16-alpine

ENV REQUEST_ORIGIN=http://localhost:5000

WORKDIR ./app

COPY . . 

RUN go build

ENV PORT=8080

EXPOSE 8080

CMD ./server