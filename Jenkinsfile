pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        EC2_PUBLIC_IP = 'YOUR_EC2_IP'
        COMPOSE_FILE = 'docker-compose.jenkins.yml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '========== Checking out code from GitHub =========='
                checkout scm
            }
        }

        stage('Verify Files') {
            steps {
                echo '========== Verifying required files =========='
                sh '''
                    echo "Listing workspace files:"
                    ls -la
                    
                    if [ ! -f "${COMPOSE_FILE}" ]; then
                        echo "ERROR: ${COMPOSE_FILE} not found!"
                        exit 1
                    fi
                    
                    echo "Docker Compose file found!"
                    cat ${COMPOSE_FILE}
                '''
            }
        }

        stage('Stop Existing Containers') {
            steps {
                echo '========== Stopping existing containers =========='
                sh '''
                    if [ -f "${COMPOSE_FILE}" ]; then
                        docker-compose -f ${COMPOSE_FILE} down || true
                        docker system prune -f
                    fi
                '''
            }
        }

        stage('Build and Run') {
            steps {
                echo '========== Building and running containers =========='
                sh '''
                    docker-compose -f ${COMPOSE_FILE} up -d --build
                    
                    echo "Waiting 120 seconds for containers to be ready..."
                    sleep 120
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '========== Verifying deployment =========='
                sh '''
                    echo "Checking running containers:"
                    docker ps
                    
                    echo "\\nChecking container health:"
                    docker-compose -f ${COMPOSE_FILE} ps
                    
                    echo "\\nApplication should be accessible at: http://${EC2_PUBLIC_IP}:3001"
                '''
            }
        }

        stage('Display Container Logs') {
            steps {
                echo '========== Container Logs =========='
                sh '''
                    echo "=== Web Container Logs ==="
                    docker logs todo-jenkins-web --tail 50
                    
                    echo "\\n=== Database Container Logs ==="
                    docker logs todo-jenkins-db --tail 20
                '''
            }
        }
    }

    post {
        success {
            echo '========== DEPLOYMENT SUCCESSFUL =========='
            echo "Application URL: http://${EC2_PUBLIC_IP}:3001"
        }
        failure {
            echo '========== DEPLOYMENT FAILED =========='
            sh 'docker-compose -f ${COMPOSE_FILE} logs'
        }
    }
}
