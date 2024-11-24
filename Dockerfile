FROM golang:1.23
RUN mkdir /word-cloud-generator; \
    cd /word-cloud-generator; \
    git clone https://github.com/Fenikks/word-cloud-generator.git .; \
    make

FROM alpine:latest
RUN apk add gcompat
COPY --from=0 /word-cloud-generator/artifacts/linux/word-cloud-generator .
EXPOSE 8888
CMD /word-cloud-generator
