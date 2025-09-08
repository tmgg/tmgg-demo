FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-node:1.1.34 AS web

WORKDIR /build

ADD web/package.json ./
RUN pnpm install

ADD web/ ./
RUN pnpm run build


FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-maven:1.1.34 AS java
WORKDIR /build
ADD pom.xml ./
RUN mvn dependency:go-offline  -q --fail-never
ADD . .
RUN mvn clean package -DskipTests -q  &&    mv target/*.jar /app.jar && rm -rf *


FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-jdk
WORKDIR /home
COPY --from=java /app.jar ./
COPY --from=web /build/dist/ ./static/
EXPOSE 80

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Duser.timezone=Asia/Shanghai","-jar","app.jar"]
