pipeline {
  agent any

  environment {
    IMAGE_NAME = "ebrahimmohammed/jenkins-theme"   // غيّر لو لازم
    MAVEN_IMAGE = "maven:3.8.8-openjdk-11"         // صورة Maven لاستخدامها في container
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build with Maven') {
      steps {
        // نشغل Maven داخل حاوية مؤقتة عشان ما نصبش maven داخل Jenkins
        sh 'docker run --rm -v $WORKSPACE:/workspace -w /workspace ${MAVEN_IMAGE} mvn -B clean package'
      }
    }

    stage('Run Unit Tests') {
      steps {
        // ينشر تقارير JUnit (Maven يولدها في target/surefire-reports)
        junit 'target/surefire-reports/*.xml'
      }
    }

    stage('Archive artifact') {
      steps {
        // يأرشف الـ JAR الناتج لسهولة التحميل من UI
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Build Docker image') {
      steps {
        // يبني صورة Docker من Dockerfile الموجود في repo
        sh 'docker build -t $IMAGE_NAME:$BRANCH_NAME-$BUILD_NUMBER .'
        // اختياري: نعمل tag :latest (سيكون مفيد للـ main)
        sh 'docker tag $IMAGE_NAME:$BRANCH_NAME-$BUILD_NUMBER $IMAGE_NAME:latest || true'
      }
    }

    stage('Push to Docker Hub') {
      // ندفع على Docker Hub فقط لما الفرع main (غير ذلك احذف when أو عدّله)
      when { branch 'main' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker push $IMAGE_NAME:$BRANCH_NAME-$BUILD_NUMBER'
          sh 'docker push $IMAGE_NAME:latest || true'
        }
      }
    }
  }

  post {
    always {
      // تنظيف صور مؤقتة محلياً لتفريغ مساحة (اختياري)
      sh 'docker image prune -f || true'
    }
    success { echo "BUILD SUCCESS: ${env.BUILD_URL}" }
    failure { echo "BUILD FAILED: ${env.BUILD_URL}" }
  }
}
