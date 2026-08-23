FROM maven:3.9-eclipse-temurin-11 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:11-jre

WORKDIR /app

COPY --from=builder /app/target/spring-boot-web.jar /app/spring-boot-web.jar

EXPOSE 8080

CMD ["java", "-jar", "/app/spring-boot-web.jar"]
