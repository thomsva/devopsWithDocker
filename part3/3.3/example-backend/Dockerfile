FROM golang:1.16-alpine

WORKDIR ./app

COPY . . 

RUN go build

ENV PORT=8080

EXPOSE 8080

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

CMD ./server