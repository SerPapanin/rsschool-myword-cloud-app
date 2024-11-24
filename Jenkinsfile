pipeline {
  agent none
  environment {
      AWS_REGION = 'us-east-1' // Replace with your AWS region
      AWS_ACCOUNT_ID = '440744237104' // Replace with your AWS Account ID
      AWS_ECR_REPOSITORY_NAME = 'rs-school/word-cloud' // Replace with your ECR repository name
      IMAGE_TAG = 'latest' // Replace with your desired image tag
      AWS_ECR_REPOSITORY_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
  }
  stages {
    stage('Build and Push Docker Image') {
      agent {
        kubernetes {
            yaml """
              apiVersion: v1
              kind: Pod
              metadata:
                name: kaniko
              spec:
                containers:
                - name: jnlp
                  workingDir: /tmp/jenkins
                - name: kaniko
                  workingDir: /tmp/jenkins
                  image: gcr.io/kaniko-project/executor:debug
                  imagePullPolicy: Always
                  command:
                  - /busybox/cat
                  tty: true
            """
          }
        }
        environment {
          PATH = "/busybox:/kaniko:$PATH"
        }
        steps {
          container(name: 'kaniko', shell: '/busybox/sh') {
              sh '''#!/busybox/sh
              /kaniko/executor --dockerfile=Dockerfile --context=/tmp/jenkins/workspace/test --destination=$AWS_ECR_REPOSITORY_URI:$IMAGE_TAG --verbosity debug
              '''
          }
        }
      }
    stage('Deploy') {
      agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: helm
                image: jakexks/kubectl-helm-aws:latest
                command: ["cat"]
                tty: true
            """
        }
      }
      steps {
        container('helm') {
          withCredentials([file(credentialsId: 'k3s-config', variable: 'KUBECONFIG')]) {
            sh '''
            aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 440744237104.dkr.ecr.us-east-1.amazonaws.com
            helm upgrade --install word-cloud-generator ./helm/ \\
                        --set image.repository=${AWS_ECR_REPOSITORY_URI} \\
                        --set image.tag=${IMAGE_TAG} \\
                        -f ./helm/values.yaml \\
                        --namespace word-cloud
            '''
          }
        }
      }
    }
  }
}
