pipeline {  
    agent any  

    environment {  
        IMAGE_NAME = "ebrahimmohammed/jenkins-theme" 
        BRANCH_NAME = "${env.BRANCH_NAME ?: 'main'}"
    }  

    tools {
        jdk 'jdk-1'      // اسم الـ JDK المثبت في Jenkins
        maven 'maven-1'  // اسم الـ Maven المثبت في Jenkins
    }

    stages {  
        stage('Checkout') {  
            steps {  
                checkout scm  
                sh "ls -l \$WORKSPACE"  // التأكد من وجود pom.xml 
            }  
        }  

        stage('Build with Maven') {  
            steps {  
                sh "mvn -B clean package"  // بناء المشروع باستخدام Maven المثبت
            }  
        }  

        stage('Run Unit Tests') {  
            steps {  
                junit 'target/surefire-reports/*.xml'  
            }  
        }  

        stage('Archive artifact') {  
            steps {  
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true  
            }  
        }  

        stage('Build Docker image') {  
            steps {  
                sh "docker build -t \$IMAGE_NAME:\$BRANCH_NAME-\$BUILD_NUMBER ." 
                sh "docker tag \$IMAGE_NAME:\$BRANCH_NAME-\$BUILD_NUMBER \$IMAGE_NAME:latest || true" 
            }  
        }  

        stage('Push to Docker Hub') {  
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
            sh 'docker image prune -f || true'  
        }  
        success { echo "BUILD SUCCESS: ${env.BUILD_URL}" }  
        failure { echo "BUILD FAILED: ${env.BUILD_URL}" }  
    }  
}
