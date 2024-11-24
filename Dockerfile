FROM golang:1.23
WORKDIR /word-cloud-generator
COPY  word-cloud/ .
RUN  make


FROM alpine:latest
RUN apk add gcompat
COPY --from=0 /word-cloud-generator/artifacts/linux/word-cloud-generator .
EXPOSE 8888
CMD /word-cloud-generator

#
# aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 440744237104.dkr.ecr.us-east-1.amazonaws.com
# docker build -t rs-school/word-cloud .
# docker tag rs-school/word-cloud:latest 440744237104.dkr.ecr.us-east-1.amazonaws.com/rs-school/word-cloud:latest
# docker push 440744237104.dkr.ecr.us-east-1.amazonaws.com/rs-school/word-cloud:latest
