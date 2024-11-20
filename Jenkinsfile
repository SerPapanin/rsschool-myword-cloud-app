
pipeline {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:latest
                command:
                - cat
                tty: true
                env:
                - name: AWS_REGION
                  value: us-east-1
            """
        }
    }
    environment {
        //ECR_REPOSITORY = '440744237104.dkr.ecr.us-east-1.amazonaws.com/rs-school/word-cloud'
        AWS_ACCOUNT_ID = '440744237104'
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = 'rs-school/word-cloud'
        IMAGE_TAG = 'latest'
    }
    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }
        stage('Build and Push Image') {
            steps {
                script {
                    def ecrRepo = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY}"

                    // Authenticate to ECR using the instance role
                    sh """
                        aws ecr get-login-password --region ${env.AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ecrRepo}
                    """

                    // Build and push using Kaniko
                    kaniko(
                        image: "${ecrRepo}:${env.IMAGE_TAG}",
                        dockerfilePath: 'Dockerfile',
                        contextPath: '.'
                    )
                }
            }
        }
    }
}
