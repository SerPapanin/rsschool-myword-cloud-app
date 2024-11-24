FROM golang:1.23
WORKDIR /word-cloud-generator
COPY  word-cloud-generator/ .
RUN  make


FROM alpine:latest
RUN apk add gcompat
COPY --from=0 /word-cloud-generator/artifacts/linux/word-cloud-generator .
EXPOSE 8888
CMD /word-cloud-generator
