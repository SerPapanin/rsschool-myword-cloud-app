pipeline {
    agent {
        kubernetes {
            yaml """
              apiVersion: v1
              kind: Pod
              metadatakey:
                name: kaniko
              spec:
                containers:
                - name: kaniko
                  image: gcr.io/kaniko-project/executor:debug
                  args:
                  - "--dockerfile=/workspace/Dockerfile"
                  - "--context=/workspace"
                  - "--destination=\${AWS_ECR_REPOSITORY_URI}:\${IMAGE_TAG}"
"""
        }
    }
    environment {
        AWS_REGION = 'us-east-1' // Replace with your AWS region
        AWS_ACCOUNT_ID = '440744237104' // Replace with your AWS Account ID
        AWS_ECR_REPOSITORY_NAME = 'rs-school/word-cloud' // Replace with your ECR repository name
        IMAGE_TAG = '0.2' // Replace with your desired image tag
    }
    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    // ECR Repository URI
                    env.AWS_ECR_REPOSITORY_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor --dockerfile=/workspace/Dockerfile --context=/workspace --destination=${AWS_ECR_REPOSITORY_URI}:${IMAGE_TAG} --log-level=debug
                    """
                }
            }
        }
    }
}
