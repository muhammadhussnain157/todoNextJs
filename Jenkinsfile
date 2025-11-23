pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        EC2_PUBLIC_IP = '13.235.97.7'
        COMPOSE_FILE = 'docker-compose.jenkins.yml'
        TEST_BASE_URL = "http://${EC2_PUBLIC_IP}:3001"
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

        stage('Run Selenium Tests') {
            agent {
                dockerfile {
                    filename 'Dockerfile.test'
                    args '-u root:root --network host -v /var/lib/jenkins/workspace:/workspace'
                    reuseNode true
                }
            }
            steps {
                echo '========== Running Automated Selenium Tests =========='
                sh '''
                    echo "Installing dependencies..."
                    npm install
                    
                    echo "Running test suite..."
                    export TEST_BASE_URL=${TEST_BASE_URL}
                    npm test || true
                    
                    echo "Tests completed!"
                '''
            }
        }

        stage('Publish Test Results') {
            steps {
                echo '========== Publishing Test Results =========='
                junit allowEmptyResults: true, testResults: '**/test-results/*.xml'
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
        always {
            script {
                echo '========== Preparing Test Results Email =========='
                
                // Get commit author email
                sh "git config --global --add safe.directory ${env.WORKSPACE}"
                def committer = sh(
                    script: "git log -1 --pretty=format:'%ae'",
                    returnStdout: true
                ).trim()

                def testResultsExist = fileExists('test-results/junit.xml')
                
                if (testResultsExist) {
                    def raw = sh(
                        script: "grep -h '<testcase' test-results/junit.xml || echo ''",
                        returnStdout: true
                    ).trim()

                    int total = 0
                    int passed = 0
                    int failed = 0
                    int skipped = 0

                    def details = ""

                    if (raw) {
                        raw.split('\n').each { line ->
                            if (line.contains('<testcase')) {
                                total++

                                def nameMatcher = (line =~ /name="([^"]+)"/)
                                def name = nameMatcher ? nameMatcher[0][1] : "Unknown Test"

                                if (line.contains('<failure')) {
                                    failed++
                                    details += "${name} — FAILED\\n"
                                } else if (line.contains('<skipped')) {
                                    skipped++
                                    details += "${name} — SKIPPED\\n"
                                } else {
                                    passed++
                                    details += "${name} — PASSED\\n"
                                }
                            }
                        }
                    }

                    def buildStatus = currentBuild.result ?: 'SUCCESS'
                    def deploymentUrl = "http://${EC2_PUBLIC_IP}:3001"

                    def emailBody = """
==============================================
Todo App - Test Results
==============================================

Build Information:
------------------
Build Number:      #${env.BUILD_NUMBER}
Build Status:      ${buildStatus}
Job Name:          ${env.JOB_NAME}
Build URL:         ${env.BUILD_URL}

Deployment Information:
-----------------------
Application URL:   ${deploymentUrl}
EC2 IP:            ${EC2_PUBLIC_IP}

Test Summary:
-------------
Total Tests:       ${total}
Passed:            ${passed}
Failed:            ${failed}
Skipped:           ${skipped}

Detailed Test Results:
----------------------
${details ?: 'No test details available'}

==============================================
Commit Information:
------------------
Committer:         ${committer}
Branch:            ${env.GIT_BRANCH ?: 'N/A'}
Commit:            ${env.GIT_COMMIT ?: 'N/A'}

==============================================
This is an automated message from Jenkins CI/CD Pipeline.
"""

                    def emailSubject = "Build #${env.BUILD_NUMBER} - ${buildStatus} - ${passed}/${total} Tests Passed"

                    emailext(
                        to: committer,
                        subject: emailSubject,
                        body: emailBody,
                        mimeType: 'text/plain'
                    )
                    
                    echo "Email sent to: ${committer}"
                } else {
                    echo "No test results found. Sending notification..."
                    
                    def buildStatus = currentBuild.result ?: 'SUCCESS'
                    def deploymentUrl = "http://${EC2_PUBLIC_IP}:3001"
                    
                    def emailBody = """
==============================================
Todo App - Build Notification
==============================================

Build Information:
------------------
Build Number:      #${env.BUILD_NUMBER}
Build Status:      ${buildStatus}
Job Name:          ${env.JOB_NAME}
Build URL:         ${env.BUILD_URL}

Deployment Information:
-----------------------
Application URL:   ${deploymentUrl}
EC2 IP:            ${EC2_PUBLIC_IP}

Note: Test results file not found.
Please check build logs for details.

==============================================
This is an automated message from Jenkins CI/CD Pipeline.
"""
                    
                    emailext(
                        to: committer,
                        subject: "Build #${env.BUILD_NUMBER} - ${buildStatus}",
                        body: emailBody,
                        mimeType: 'text/plain'
                    )
                }
            }
        }
        success {
            echo '========== DEPLOYMENT AND TESTS SUCCESSFUL =========='
            echo "Application URL: http://${EC2_PUBLIC_IP}:3001"
        }
        failure {
            echo '========== DEPLOYMENT OR TESTS FAILED =========='
            sh 'docker-compose -f ${COMPOSE_FILE} logs || true'
        }
    }
}
