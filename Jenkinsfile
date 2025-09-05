pipeline {  
    agent any  

    environment {  
        IMAGE_NAME = "ebrahimmohammed/jenkins-theme" 
    }  

    stages {  
        stage('Checkout') {  
            steps {  
                checkout scm  
                sh "ls -l \$WORKSPACE"  // التأكد من وجود pom.xml وملفات المشروع
            }  
        }  

        stage('Build Docker image') {  
            steps {  
                // بناء الصورة وتشغيل الـ build داخل الـ container
                sh "docker build -t \$IMAGE_NAME:\$BRANCH_NAME-\$BUILD_NUMBER ."  
                sh "docker tag \$IMAGE_NAME:\$BRANCH_NAME-\$BUILD_NUMBER \$IMAGE_NAME:latest || true"  
            }  
        }  

        stage('Push to Docker Hub') {  
            when { branch 'main' }  
