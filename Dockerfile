ARG repo=alpine
ARG image=git
ARG version=:1.0.21
ARG digest=@sha256:8715680f27333935bb384a678256faf8e8832a5f2a0d4a00c9d481111c5a29c0
FROM $repo/$image$version$digest AS clone
ARG hostname=github.com
ARG username=openshift-academia-online
ARG project=spring-petclinic
ARG dir=/clone
WORKDIR $dir
RUN git clone https://$hostname/$username/$project


FROM maven:alpine AS build
ARG project=spring-petclinic
ARG dir=/build
ARG dir_old=/clone
WORKDIR $dir
COPY --from=clone $dir_old/$project .
RUN mvn install && mv target/$project-*.jar target/$project.jar


FROM openjdk:jre-alpine AS production
ARG dir=/app
ARG dir_old=/build/target
ARG project=spring-petclinic
WORKDIR $dir
COPY --from=build $dir_old/$project.jar .

ENTRYPOINT ["java","-jar"]
CMD ["spring-petclinic.jar"]
