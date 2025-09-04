FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-node AS web
WORKDIR /build
# 缓存
ADD web/package.json ./
RUN npm install

# 打包
ADD web/ ./
RUN npm run build


FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-java AS java
# 缓存
ADD pom.xml ./
RUN mvn dependency:go-offline --fail-never

# 打包
ADD . .
RUN mvn clean package -DskipTests  &&    mv target/*.jar /app.jar && rm -rf *


FROM registry.cn-hangzhou.aliyuncs.com/mxvc/tmgg-base-jdk
WORKDIR /home
COPY --from=java /app.jar ./
COPY --from=web /build/dist/ ./static/
EXPOSE 80

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Duser.timezone=Asia/Shanghai","-jar","app.jar"]
