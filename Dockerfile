FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-maven:1.1.60 AS java
WORKDIR /build

ADD pom.xml ./
RUN mvn package -DskipTests  --fail-never

ADD . .
RUN mvn clean package -DskipTests -q  &&    mv target/app.jar /home/app.jar && rm -rf *


FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-node:1.1.60 AS web
WORKDIR /build

ADD web/package.json ./
RUN pnpm install

ADD web/ ./
RUN pnpm run build


FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-jdk
WORKDIR /home
COPY --from=JAVA /home/ ./
COPY --from=web /build/dist/ ./static/
EXPOSE 80

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Duser.timezone=Asia/Shanghai","-jar","/home/app.jar"]
