pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code..'
                git branch: 'main', url: 'https://github.com/anirbanb13/spring-boot-app.git'
            }
        }
        stage('Build & Test') {
            steps {
                echo 'Building and testing..'
                sh 'ls -ltr'
                sh 'cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && mvn clean package'
            }
        }
        stage('Static Code Analysis') {
            environment {
                SONARQUBE_URL = 'http://localhost:9000'  // localhost
            }
            steps {
                echo 'Analyzing code...'
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh "cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && mvn sonar:sonar -Dsonar.projectKey=spring-boot-app -Dsonar.host.url=${SONARQUBE_URL} -Dsonar.token=${SONAR_TOKEN}"
                }
            }
        }
        stage('Build & Push Docker Image') {
            environment {
                DOCKER_IMAGE = "anirbanb13/spring-boot-app:${BUILD_NUMBER}"  // fix: double quotes
            }
            steps {
                echo 'Building and pushing Docker image...'
                sh 'cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && docker build -t ${DOCKER_IMAGE} .'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                    sh "docker tag ${DOCKER_IMAGE}"  // fix: double quotes + use var
                    sh "docker push ${DOCKER_IMAGE}"                        // fix: double quotes + use var
                }
            }
        }
        stage('Update Deployment File') {
            steps {
                echo 'Updating deployment file...'
                sh "cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && sed -i 's/replaceImageTag/${BUILD_NUMBER}/g' deployment.yml"
                sh 'git config user.email "jenkins@ci.local"'   // fix: set git identity
                sh 'git config user.name "Jenkins CI"'
                sh 'cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && git add deployment.yml'
                sh "cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && git commit -m 'Update deployment image to version ${BUILD_NUMBER}'"
                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                    sh "cd cicd-jenkins-argoCD-helm-k8s/spring-boot-app && git push https://${GITHUB_TOKEN}@github.com/anirbanb13/spring-boot-app.git"  // fix: double quotes
                }
            }
        }
    }
}