pipeline {
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
        AWS_REGION = 'us-east-1' // Replace with your AWS region
        AWS_ACCOUNT_ID = '440744237104' // Replace with your AWS Account ID
        AWS_ECR_REPOSITORY_NAME = 'rs-school/word-cloud' // Replace with your ECR repository name
        IMAGE_TAG = '0.2' // Replace with your desired image tag
        // env.AWS_ECR_REPOSITORY_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.AWS_ECR_REPOSITORY_NAME}"
    }
    stages {
      stage('Build and Push Docker Image') {
          environment {
            PATH = "/busybox:/kaniko:$PATH"
          }
          steps {
              container(name: 'kaniko', shell: '/busybox/sh') {
                  sh '''#!/busybox/sh
                  /kaniko/executor --dockerfile=Dockerfile --context=git://github.com/SerPapanin/rsschool-myword-cloud-app.git#refs/heads/main --destination=440744237104.dkr.ecr.us-east-1.amazonaws.com/rs-school/word-cloud:0.2 --verbosity debug
                  '''
              }
          }
      }
    }
}
