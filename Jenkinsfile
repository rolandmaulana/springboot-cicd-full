pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rolandmaulana/springboot-cicd-full:latest"
        REGISTRY_CREDENTIALS = '20310e4b53924a06884d51f68ac9254c'   // Buat credentials ini di Jenkins
        TELEGRAM_BOT_TOKEN = credentials('t8161018250:AAEChR_GmId41XjMsj4__YPVqrIXqIZd4Ns')
        TELEGRAM_CHAT_ID = '5850915085' 
        SONARQUBE_ENV = 'MySonarQube'  // nama SonarQube server di Jenkins config
        GOOGLE_PROJECT_ID = 'rakamin-ttc-odp-it-1'
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }

        stage('Unit Test & Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Static Analysis (SonarQube)') {
            steps {
                withSonarQubeEnv(SONARQUBE_ENV) {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', REGISTRY_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }

        stage('Deploy to Cloud Run with Terraform') {
            steps {
                dir('terraform') {
                    sh """
                        terraform init
                        terraform apply -auto-approve \
                          -var="project_id=${GOOGLE_PROJECT_ID}" \
                          -var="docker_image=${DOCKER_IMAGE}"
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                def message = "Pipeline selesai: Build #${env.BUILD_NUMBER} - Status: ${currentBuild.currentResult}"
                sh """
                    curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage \
                        -d chat_id=${TELEGRAM_CHAT_ID} \
                        -d text="${message}"
                """
            }
        }
    }
}
