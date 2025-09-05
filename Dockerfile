# ======================
# مرحلة البناء (Build)
# ======================
FROM maven:3.9.0-eclipse-temurin-11 AS build
WORKDIR /app

# نسخ ملفات Maven الأساسية
COPY pom.xml .
COPY src ./src

# بناء المشروع بدون اختبارات
RUN mvn -B -DskipTests=true clean package

# ======================
# مرحلة التشغيل (Runtime)
# ======================
FROM eclipse-temurin:11-jre-jammy
WORKDIR /app

# نسخ الـ JAR الناتج من مرحلة البناء
COPY --from=build /app/target/*.jar app.jar

# نقطة البداية لتشغيل التطبيق
ENTRYPOINT ["java","-jar","/app/app.jar"]
