# ដំណាក់កាលទី ១៖ Build កូដ Java ទៅជាឯកសារ .jar
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# ដំណាក់កាលទី ២៖ ដំណើរការកម្មវិធីដោយប្រើ OpenJDK 21
FROM openjdk:21-slim
WORKDIR /app

# បង្កើត User ធម្មតាមួយដើម្បីសុវត្ថិភាព (មិន Run ជា root)
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# ចម្លងឯកសារ .jar ពីដំណាក់កាលទី ១
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
# ចាប់យក PORT របស់ Render ដោយស្វ័យប្រវត្តិ
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT:-8080} -jar app.jar"]