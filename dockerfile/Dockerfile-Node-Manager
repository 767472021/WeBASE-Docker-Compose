# build command :
#   cat Dockerfile-Node-Manager | docker build -t yuanmomo/webase-node-manager:1.3.2 -f - https://github.com/WeBankFinTech/WeBASE-Node-Manager.git#dev131
#
# run command :
#   docker run --rm --name "manager" --network=host yuanmomo/webase-node-manager:1.3.2
#

FROM gradle:6.4.0-jdk8 as cache
LABEL maintainer yuanhongbin9090@gmail.com

RUN mkdir -p /home/gradle/cache_home

ENV GRADLE_USER_HOME /home/gradle/cache_home

WORKDIR /code
COPY build.gradle build.gradle

RUN gradle clean build -i --stacktrace






FROM gradle:6.4.0-jdk8 as builder
LABEL maintainer yuanhongbin9090@gmail.com

# copy cache
COPY --from=cache /home/gradle/cache_home /home/gradle/.gradle

WORKDIR /code
ENV LANG en_US.UTF-8

# copy source code
COPY script script
COPY build.gradle build.gradle
COPY src src

# build
RUN gradle build -x test
RUN gradle build -x test -i --stacktrace






FROM openjdk:8-jdk-alpine as prod

ENV CLASSPATH "/dist/conf/:/dist/apps/*:/dist/lib/*"
ENV JAVA_OPTS " -server -Dfile.encoding=UTF-8 -Xmx256m -Xms256m -Xmn128m -Xss512k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/log/heap_error.log  -XX:+UseG1GC -XX:MaxGCPauseMillis=200 "
ENV APP_MAIN "com.webank.webase.node.mgr.Application"
ENV LANG en_US.UTF-8

RUN apk --no-cache add --update ttf-dejavu fontconfig bash curl wget

COPY --from=builder /code/dist/lib                  /dist/lib
COPY --from=builder /code/dist/conf_template        /dist/conf
COPY --from=builder /code/dist/apps                 /dist/apps

WORKDIR /dist
EXPOSE 5001

# start commond
ENTRYPOINT java ${JAVA_OPTS} -Djdk.tls.namedGroups="secp256k1", -Duser.timezone="Asia/Shanghai" -Djava.security.egd=file:/dev/./urandom, -Djava.library.path=/dist/conf -cp ${CLASSPATH}  ${APP_MAIN}
