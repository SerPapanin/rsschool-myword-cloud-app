pipeline {
    agent any
    stages {
        stage('Build application') {
            steps {
                git url: 'https://github.com/jenkins-hero/spring-boot-api-example.git', branch: 'kaniko'
                sh "./gradlew assemble dockerPrepare -Porg.gradle.jvmargs=-Xmx2g"
                sh "tar c build/docker | gzip | aws s3 cp - 's3://$KANIKO_BUILD_CONTEXT_BUCKET_NAME/context.tar.gz'"
            }
        }
        stage('Build and publish image') {
            steps {
                sh 'envsubst < ecs-run-task-template.json > ecs-run-task.json'
                script {
                    LATEST_TASK_DEFINITION = sh(returnStdout: true, script: "/bin/bash -c 'aws ecs list-task-definitions \
                        --status active --sort DESC \
                        --family-prefix $KANIKO_TASK_FAMILY_PREFIX \
                        --query \'taskDefinitionArns[0]\' \
                        --output text \
                        | sed \'s:.*/::\''").trim()
                    TASK_ARN = sh(returnStdout: true, script: "/bin/bash -c 'aws ecs run-task \
                        --task-definition $LATEST_TASK_DEFINITION \
                         --cli-input-json file://ecs-run-task.json \
                        | jq -j \'.tasks[0].taskArn\''").trim()
                }
                echo "Submitted task $TASK_ARN"

                sh "aws ecs wait tasks-running --cluster jenkins-cluster --task $TASK_ARN"
                echo "Task is running"

                sh "aws ecs wait tasks-stopped --cluster jenkins-cluster --task $TASK_ARN"
                echo "Task has stopped"
                script {
                    EXIT_CODE = sh(returnStdout: true, script: "/bin/bash -c 'aws ecs describe-tasks \
                    --cluster jenkins-cluster \
                    --tasks $TASK_ARN \
                    --query \'tasks[0].containers[0].exitCode\' \
                    --output text'").trim()

                    if (EXIT_CODE == '0') {
                        echo 'Successfully built and published Docker image'
                    }
                    else {
                        error("Container exited with unexpected exit code $EXIT_CODE. Check the logs for details.")
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deployment in progress'
            }
        }
    }
}
