
pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = 'aws-credentials'
        ECR_REPO = '440744237104.dkr.ecr.us-east-1.amazonaws.com/rs-school/word-cloud'
        IMAGE_TAG = "latest"
        SONARQUBE_SCANNER = 'SonarQube Scanner'
        KUBECONFIG = 'kubeconfig'
        AWS_REGION = 'us-east-1'
        APP_REPO_URL = 'https://github.com/SerPapanin/rsschool-myword-cloud-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: env.APP_REPO_URL
            }
        }

        stage('Test Docker') {
            steps {
                sh 'docker --version'
            }
        }

        stage('Application Build') {
            steps {
                sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
            }
        }

        stage('Unit Test Execution') {
            steps {
                sh "docker run --rm ${ECR_REPO}:${IMAGE_TAG} npm test"
            }
        }

        stage('Security Check with SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "${SONARQUBE_SCANNER} -Dsonar.projectKey=my-project -Dsonar.sources=./src"
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}")]) {
                        sh "aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${ECR_REPOSITORY}"
                    }
                    sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes with Helm') {
            steps {
                script {
                    withCredentials([file(credentialsId: "${KUBECONFIG}", variable: 'KUBECONFIG')]) {
                        sh "helm upgrade --install my-app ./helm-chart --set image.repository=${ECR_REPOSITORY} --set image.tag=${IMAGE_TAG}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
