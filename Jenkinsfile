pipeline { 
    agent any 

    environment { 
        IMAGE_NAME = "ebrahimmohammed/jenkins-theme"
        MAVEN_IMAGE = "maven:3.9.0-eclipse-temurin-11"
    } 

    stages { 
        stage('Checkout') { 
            steps { 
                checkout scm 
                // عرض محتويات المشروع للتأكد من وجود pom.xml
                sh "ls -l \$WORKSPACE"
            } 
        } 

        stage('Build with Maven') { 
            steps { 
                // تشغيل Maven داخل container مع تحديد pom.xml
                sh """
                    docker run --rm -v \$WORKSPACE:/workspace -w /workspace ${MAVEN_IMAGE} \
                    mvn -B -f pom.xml clean package
                """
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
