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
              ls -la /workspace
              #
              /kaniko/executor --dockerfile=Dockerfile --context=/workspace/word-cloud-generator --destination=$AWS_ECR_REPOSITORY_URI:$IMAGE_TAG --verbosity debug
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
                image: alpine/helm:3.16.3
                command: ["cat"]
                tty: true
            """
        }
      }
      steps {
        container('helm') {
          withCredentials([file(credentialsId: 'k3s-config', variable: 'KUBECONFIG')]) {
            sh '''
            # kubectl get namespace wordpress || kubectl create namespace wordpress
            helm repo add my-wp https://SerPapanin.github.io/rsschool-wp-helm/
            #helm upgrade --install wordpress my-wp/wordpress --namespace wordpress --version 0.1.3 --wait
            #helm install wordpress my-wp/wordpress --version 0.1.3
            '''
          }
        }
      }
    }
  }
}
