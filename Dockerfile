# Base image مع OpenJDK 11
FROM eclipse-temurin:11-jdk

# تثبيت Maven
ENV MAVEN_VERSION=3.9.0
RUN apt-get update && apt-get install -y curl unzip git \
    && curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.zip -o /tmp/maven.zip \
    && unzip /tmp/maven.zip -d /opt \
    && rm /tmp/maven.zip \
    && ln -s /opt/apache-maven-$MAVEN_VERSION /opt/maven

# إعداد متغيرات البيئة لـ Maven
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# نسخ المشروع داخل الـ container
WORKDIR /app
COPY . /app

# Build المشروع مباشرة (skip tests لتسريع)
RUN mvn -B clean package -DskipTests=true

# تحديد الـ entrypoint إذا حبيت تشغل التطبيق مباشرة
CMD ["java","-jar","target/*.jar"]
