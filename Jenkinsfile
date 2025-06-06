pipeline {
  agent { label 'slave1' }

  environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
    ECS_CLUSTER = 'Dev'
    ECS_SERVICE = 'ecs-4-ECSService-z7wZlnUXOnhj'
    ECS_TASK_DEFINITION = 'dev-task-1'
    AWS_ACCOUNT_ID = '686588766365'
    AWS_ECR_REPO = 'jenkins-example'
    APP_NAME = 'jenkins-example'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
         sh """
          docker build -t ${APP_NAME}:${IMAGE_TAG} .
          docker tag ${APP_NAME}:${IMAGE_TAG} ${APP_NAME}:latest
          """
        }
      }
    }

    stage('Push to ECR') {
      steps {
         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                          credentialsId: 'd40eb6b3-10b1-4fc7-bf12-1ddf551583ff']]) {
          sh """
            aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
            docker tag ${APP_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${AWS_ECR_REPO}:${IMAGE_TAG}
            docker tag ${APP_NAME}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${AWS_ECR_REPO}:latest
            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${AWS_ECR_REPO}:${IMAGE_TAG}
            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${AWS_ECR_REPO}:latest
          """
        }
      }
    }

  stage('Deploy to ECS') {
   steps {
     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                      credentialsId: 'd40eb6b3-10b1-4fc7-bf12-1ddf551583ff']]) {
      sh '''
        aws ecs update-service \
          --cluster $ECS_CLUSTER \
          --service $ECS_SERVICE \
          --force-new-deployment \
          --region $AWS_DEFAULT_REGION
      '''
    }
  }
}

  }

  post {
    success {
      echo '✅ Deployment to ECS Fargate was successful.'
    }
    failure {
      echo '❌ Deployment failed.'
    }
  }
}
