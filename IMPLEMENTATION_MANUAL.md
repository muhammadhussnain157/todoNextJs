# Complete Implementation Manual - Selenium Testing & Jenkins CI/CD

## 📚 Table of Contents
1. [Important Note - Two Repository Structure](#important-note---two-repository-structure)
2. [AWS EC2 Setup](#aws-ec2-setup)
3. [Part I: Setting Up Todo Application Repository](#part-i-setting-up-todo-application-repository)
4. [Part II: Setting Up Selenium Tests Repository](#part-ii-setting-up-selenium-tests-repository)
5. [Part III: Jenkins Installation & Configuration](#part-iii-jenkins-installation--configuration)
6. [Part IV: Jenkins Pipeline Configuration](#part-iv-jenkins-pipeline-configuration)
7. [Part V: Email Notification Setup](#part-v-email-notification-setup)
8. [Part VI: Running & Verifying Tests](#part-vi-running--verifying-tests)
9. [Troubleshooting Guide](#troubleshooting-guide)

---

## Important Note - Two Repository Structure

**IMPORTANT:** This implementation uses **TWO separate GitHub repositories** as per teacher's requirements:

1. **Repository 1: Todo Application** (`todo-app`)
   - Contains the Next.js application code
   - docker-compose.jenkins.yml
   - Application Dockerfile
   - All application components

2. **Repository 2: Selenium Tests** (`todo-app-tests`)
   - Contains all test files (tests/ folder)
   - Dockerfile.test
   - jest.config.js
   - package.json (with test dependencies)
   - Jenkinsfile (pulls from BOTH repositories)

**Why Two Repositories?**
- Separates application code from test code
- Follows testing best practices
- Allows independent versioning
- Meets teacher's requirements
- Jenkins will pull application from repo 1 and tests from repo 2

---

## AWS EC2 Setup

---

## Part I: Setting Up Todo Application Repository

### Step 1: Create AWS Account (if you don't have one)

1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Enter email address
4. Follow the registration process
5. Enter payment information (required, but we'll use free tier)
6. Verify your phone number
7. Choose "Basic Support - Free"
8. Wait for account activation (may take a few minutes)

### Step 2: Launch EC2 Instance

1. Log in to AWS Console: https://console.aws.amazon.com/
2. In the search bar at top, type "EC2" and click on "EC2"
3. Click orange "Launch Instance" button
4. **Configure the instance:**

   **Step 2.1: Name**
   - Name: `Todo-App-Server`

   **Step 2.2: Choose AMI (Operating System)**
   - Select "Ubuntu Server 22.04 LTS"
   - Make sure it says "Free tier eligible"

   **Step 2.3: Choose Instance Type**
   - Select `t2.medium` (required for Jenkins + Docker)
   - Note: This is NOT free tier, but necessary for performance

   **Step 2.4: Create Key Pair**
   - Click "Create new key pair"
   - Key pair name: `todo-app-key`
   - Key pair type: RSA
   - Private key file format: 
     - Choose `.pem` if using Mac/Linux
     - Choose `.ppk` if using Windows with PuTTY
   - Click "Create key pair"
   - **IMPORTANT:** Save the downloaded file in a safe place (you'll need it to connect)

   **Step 2.5: Network Settings**
   - Click "Edit" next to Network settings
   - Keep default VPC and Subnet
   - Auto-assign public IP: **Enable**
   - Firewall (Security Groups): "Create security group"
   - Security group name: `todo-app-sg`
   - Description: `Security group for todo app`
   
   **Step 2.6: Add Security Group Rules**
   - Rule 1 (already there):
     - Type: SSH
     - Port: 22
     - Source: My IP (or Anywhere if you'll connect from different locations)
   
   - Click "Add security group rule" for each of these:
   
   - Rule 2:
     - Type: Custom TCP
     - Port: 3000
     - Source: Anywhere (0.0.0.0/0)
     - Description: Todo App Part 1
   
   - Rule 3:
     - Type: Custom TCP
     - Port: 3001
     - Source: Anywhere (0.0.0.0/0)
     - Description: Todo App Part 2
   
   - Rule 4:
     - Type: Custom TCP
     - Port: 8080
     - Source: Anywhere (0.0.0.0/0)
     - Description: Jenkins
   
   **Step 2.7: Configure Storage**
   - Size: 30 GB (minimum for Jenkins + Docker)
   - Volume type: gp3

   **Step 2.8: Advanced Details**
   - Keep all defaults

5. Click orange "Launch Instance" button at the bottom
6. Wait for "Success" message
7. Click "View Instances"
8. Wait until "Instance state" shows "Running" (2-3 minutes)
9. **Write down your instance's Public IP address** (you'll need this many times)

### Step 3: Connect to EC2 Instance

**Note:** We'll perform all operations on EC2 Ubuntu instance.

1. Open Terminal on your local machine
2. Move key file to safe location:
   ```bash
   mkdir -p ~/.ssh
   mv ~/Downloads/todo-app-key.pem ~/.ssh/
   chmod 400 ~/.ssh/todo-app-key.pem
   ```

3. Connect to EC2:
   ```bash
   ssh -i ~/.ssh/todo-app-key.pem ubuntu@13.235.97.7
   ```
   Replace `13.235.97.7` with your actual EC2 IP if different

4. Type "yes" when prompted to accept fingerprint

5. You should now see Ubuntu prompt:
   ```
   ubuntu@ip-xxx-xxx-xxx-xxx:~$
   ```

### Step 4: Install Docker on EC2

Once connected to EC2, run these commands **one by one**:

1. Update package list:
   ```bash
   sudo apt-get update
   ```
   (Wait for completion - 1-2 minutes)

2. Install Docker:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```
   (Wait for completion - 2-3 minutes)

3. Add ubuntu user to docker group:
   ```bash
   sudo usermod -aG docker ubuntu
   ```

4. Install Docker Compose:
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

5. **Log out and log back in** (important for docker group to take effect):
   ```bash
   exit
   ```
   Then reconnect using the ssh command from Step 3

6. Verify installations:
   ```bash
   docker --version
   docker-compose --version
   ```
   You should see version numbers

---

## Part III: Jenkins Installation & Configuration

### Step 1: Install Jenkins on EC2

**Make sure you're connected to EC2 via SSH**, then run:

1. Install Java (Jenkins requires it):
   ```bash
   sudo apt-get update
   sudo apt-get install -y fontconfig openjdk-17-jre
   ```
   (Wait 2-3 minutes)

2. Verify Java installation:
   ```bash
   java -version
   ```
   Should show Java 17

3. Add Jenkins repository:
   ```bash
   sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
     https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
   
   echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
     https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
     /etc/apt/sources.list.d/jenkins.list > /dev/null
   ```

4. Install Jenkins:
   ```bash
   sudo apt-get update
   sudo apt-get install -y jenkins
   ```
   (Wait 2-3 minutes)

5. Start Jenkins:
   ```bash
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   ```

6. Check Jenkins status:
   ```bash
   sudo systemctl status jenkins
   ```
   Should show "active (running)" in green
   Press `q` to exit

### Step 2: Add Jenkins User to Docker Group

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```
Wait 30 seconds for Jenkins to restart

### Step 3: Access Jenkins Web Interface

1. Open your web browser
2. Go to: `http://13.235.97.7:8080`
   (Replace 13.235.97.7 with your actual IP if different)
3. You should see "Unlock Jenkins" page

### Step 4: Unlock Jenkins

1. On EC2 terminal, get the initial admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
2. Copy the password (it's a long string like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)
3. Paste it in the "Administrator password" field in your browser
4. Click "Continue"

### Step 5: Install Plugins

1. You'll see "Customize Jenkins" page
2. Click "Install suggested plugins"
3. Wait for all plugins to install (5-10 minutes)
4. Don't close the browser during installation

### Step 6: Create Admin User

1. After plugins install, you'll see "Create First Admin User"
2. Fill in:
   - Username: `admin` (or your preferred username)
   - Password: `admin123` (or your preferred password) - **WRITE THIS DOWN!**
   - Confirm password: Same as above
   - Full name: `Admin User`
   - Email: Your email address (important for receiving test results!)
3. Click "Save and Continue"

### Step 7: Configure Jenkins URL

1. You'll see "Instance Configuration"
2. Jenkins URL should be: `http://13.235.97.7:8080/`
3. Click "Save and Finish"
4. Click "Start using Jenkins"

### Step 8: Install Additional Required Plugins

1. Click "Manage Jenkins" (left sidebar)
2. Click "Plugins" (or "Manage Plugins")
3. Click "Available plugins" tab
4. In the search box at top right, search for and check each of these:
   - `Docker Pipeline`
   - `Email Extension Plugin`
   - `Email Extension Template Plugin`
5. After checking all boxes, click "Install" button at bottom
6. Check "Restart Jenkins when installation is complete"
7. Wait for Jenkins to restart (2-3 minutes)
8. Log back in with your admin credentials

### Step 9: Clone Todo Application Repository on EC2

**Still connected to EC2 via SSH:**

1. Navigate to home directory:
   ```bash
   cd ~
   ```

2. Clone the todo application repository:
   ```bash
   git clone https://github.com/muhammadhussnain157/todo.git
   cd todo
   ```

3. Verify files exist:
   ```bash
   ls -la
   ```
   You should see:
   - components/
   - pages/
   - models/
   - docker-compose.jenkins.yml
   - Dockerfile
   - package.json

---

## Part II: Setting Up Selenium Tests Repository

### Step 1: Create Separate GitHub Repository for Tests

**On your local machine (or GitHub web interface):**

1. Go to https://github.com/ and log in
2. Click "+" icon → "New repository"
3. Repository name: `todo-app-tests`
4. Description: `Selenium automated tests for todo application`
5. Keep it **Public**
6. **DO NOT** check "Initialize with README"
7. Click "Create repository"
8. **Keep this page open**

### Step 2: Create GitHub Personal Access Token

1. Click your profile picture (top right) → Settings
2. Scroll down to "Developer settings" (left sidebar)
3. Click "Personal access tokens" → "Tokens (classic)"
4. Click "Generate new token" → "Generate new token (classic)"
5. Note: `Jenkins and Git access`
6. Expiration: 90 days
7. Check these scopes:
   - `repo` (all sub-items)
   - `admin:repo_hook` (all sub-items)
8. Click "Generate token"
9. **COPY THE TOKEN IMMEDIATELY** (you won't see it again!)
10. Save it somewhere safe

### Step 3: Prepare Test Files on EC2

**SSH to EC2 and create test repository structure:**

1. Create a new directory for tests:
   ```bash
   cd ~
   mkdir todo-app-tests
   cd todo-app-tests
   ```

2. Initialize git:
   ```bash
   git init
   git config user.name "Your Name"
   git config user.email "your.email@example.com"
   ```

3. Create necessary directories:
   ```bash
   mkdir -p tests/helpers
   mkdir -p test-results
   ```

### Step 4: Create Test Files

**Create all test files on EC2:**

1. Create package.json:
   ```bash
   nano package.json
   ```
   
   Paste this content:
   ```json
   {
     "name": "todo-app-tests",
     "version": "1.0.0",
     "description": "Selenium tests for todo application",
     "scripts": {
       "test": "jest --runInBand --detectOpenHandles --forceExit",
       "test:headless": "jest --runInBand --detectOpenHandles --forceExit"
     },
     "dependencies": {},
     "devDependencies": {
       "jest": "^29.7.0",
       "jest-junit": "^16.0.0",
       "selenium-webdriver": "^4.15.0"
     }
   }
   ```
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

2. Create jest.config.js:
   ```bash
   nano jest.config.js
   ```
   
   Paste the configuration from your existing jest.config.js file
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

3. Create Dockerfile.test:
   ```bash
   nano Dockerfile.test
   ```
   
   Paste the Dockerfile.test content
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

4. Create test helper:
   ```bash
   nano tests/helpers/driverHelper.js
   ```
   
   Paste the driverHelper.js content
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

5. Create auth tests:
   ```bash
   nano tests/auth.test.js
   ```
   
   Paste the auth.test.js content
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

6. Create todo tests:
   ```bash
   nano tests/todo.test.js
   ```
   
   Paste the todo.test.js content
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

7. Create .gitignore:
   ```bash
   nano .gitignore
   ```
   
   Paste:
   ```
   node_modules/
   test-results/
   screenshots/
   *.png
   .env
   ```
   
   Save: `Ctrl + O`, Enter, `Ctrl + X`

### Step 5: Create Jenkinsfile for Tests Repository

**This Jenkinsfile will pull from BOTH repositories:**

```bash
nano Jenkinsfile
```

Paste this content:
```groovy
pipeline {
    agent any
    
    environment {
        EC2_PUBLIC_IP = '13.235.97.7'
        TEST_BASE_URL = "http://${EC2_PUBLIC_IP}:3001"
        APP_REPO = 'https://github.com/muhammadhussnain157/todo.git'
        TEST_REPO = 'https://github.com/muhammadhussnain157/todo-app-tests.git'
    }

    stages {
        stage('Checkout Application Code') {
            steps {
                echo '========== Checking out Application from GitHub =========='
                dir('app') {
                    git branch: 'main', url: "${APP_REPO}"
                }
            }
        }

        stage('Checkout Test Code') {
            steps {
                echo '========== Checking out Tests from GitHub =========='
                dir('tests') {
                    git branch: 'main', url: "${TEST_REPO}"
                }
            }
        }

        stage('Verify Files') {
            steps {
                echo '========== Verifying required files =========='
                sh '''
                    echo "Application files:"
                    ls -la app/
                    
                    echo "Test files:"
                    ls -la tests/
                    
                    if [ ! -f "app/docker-compose.jenkins.yml" ]; then
                        echo "ERROR: docker-compose.jenkins.yml not found!"
                        exit 1
                    fi
                '''
            }
        }

        stage('Stop Existing Containers') {
            steps {
                echo '========== Stopping existing containers =========='
                dir('app') {
                    sh '''
                        docker-compose -f docker-compose.jenkins.yml down || true
                        docker system prune -f
                    '''
                }
            }
        }

        stage('Build and Run Application') {
            steps {
                echo '========== Building and running application =========='
                dir('app') {
                    sh '''
                        docker-compose -f docker-compose.jenkins.yml up -d --build
                        
                        echo "Waiting 120 seconds for containers to be ready..."
                        sleep 120
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '========== Verifying deployment =========='
                sh '''
                    echo "Checking running containers:"
                    docker ps
                    
                    echo "\\nTesting application accessibility:"
                    curl -f http://localhost:3001 || echo "App not responding yet"
                '''
            }
        }

        stage('Run Selenium Tests') {
            agent {
                dockerfile {
                    filename 'Dockerfile.test'
                    dir 'tests'
                    args '-u root:root --network host'
                    reuseNode true
                }
            }
            steps {
                echo '========== Running Automated Selenium Tests =========='
                dir('tests') {
                    sh '''
                        echo "Installing test dependencies..."
                        npm install
                        
                        echo "Running test suite..."
                        export TEST_BASE_URL=${TEST_BASE_URL}
                        npm test || true
                        
                        echo "Tests completed!"
                    '''
                }
            }
        }

        stage('Publish Test Results') {
            steps {
                echo '========== Publishing Test Results =========='
                dir('tests') {
                    junit allowEmptyResults: true, testResults: '**/test-results/*.xml'
                }
            }
        }

        stage('Display Container Logs') {
            steps {
                echo '========== Container Logs =========='
                sh '''
                    echo "=== Web Container Logs ==="
                    docker logs todo-jenkins-web --tail 50 || true
                    
                    echo "\\n=== Database Container Logs ==="
                    docker logs todo-jenkins-db --tail 20 || true
                '''
            }
        }
    }

    post {
        always {
            script {
                echo '========== Preparing Test Results Email =========='
                
                // Get commit author email from test repository
                def committer = sh(
                    script: "cd tests && git log -1 --pretty=format:'%ae'",
                    returnStdout: true
                ).trim()

                def testResultsExist = fileExists('tests/test-results/junit.xml')
                
                if (testResultsExist) {
                    def raw = sh(
                        script: "grep -h '<testcase' tests/test-results/junit.xml || echo ''",
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

Repository Information:
-----------------------
Application Repo:  ${APP_REPO}
Test Repo:         ${TEST_REPO}

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
                }
            }
        }
        success {
            echo '========== DEPLOYMENT AND TESTS SUCCESSFUL =========='
            echo "Application URL: http://${EC2_PUBLIC_IP}:3001"
        }
        failure {
            echo '========== DEPLOYMENT OR TESTS FAILED =========='
            sh 'cd app && docker-compose -f docker-compose.jenkins.yml logs || true'
        }
    }
}
```

Save: `Ctrl + O`, Enter, `Ctrl + X`

### Step 6: Push Tests to GitHub

1. Add all files:
   ```bash
   git add .
   ```

2. Commit:
   ```bash
   git commit -m "Initial commit - Selenium test suite"
   ```

3. Add remote (replace with your test repo URL):
   ```bash
   git remote add origin https://github.com/muhammadhussnain157/todo-app-tests.git
   ```

4. Rename branch to main:
   ```bash
   git branch -M main
   ```

5. Push to GitHub (use your GitHub username and Personal Access Token):
   ```bash
   git push -u origin main
   ```
   
   - Username: Your GitHub username
   - Password: Your Personal Access Token (from Step 2)

### Step 7: Verify Test Repository

1. Open browser and go to your test repository
2. Verify these files are present:
   - `Jenkinsfile`
   - `Dockerfile.test`
   - `jest.config.js`
   - `package.json`
   - `tests/auth.test.js`
   - `tests/todo.test.js`
   - `tests/helpers/driverHelper.js`

---

## Part IV: Jenkins Pipeline Configuration

### Step 1: Create Jenkins Pipeline Job

1. Open Jenkins in browser: `http://13.235.97.7:8080`
2. Log in with your admin credentials
3. Click "New Item" (left sidebar)
4. Enter item name: `todo-app-pipeline`
5. Select "Pipeline"
6. Click "OK" at bottom

### Step 3: Configure Pipeline - General Settings

1. Check "GitHub project"
2. Project url: `https://github.com/muhammadhussnain157/todo-app-tests/`
   (This should be your TEST repository URL, NOT the app repository)

### Step 4: Configure Pipeline - Build Triggers

1. Check "GitHub hook trigger for GITScm polling"
   (This allows GitHub to trigger builds automatically)

### Step 5: Configure Pipeline - Pipeline Definition

1. Definition: Select "Pipeline script from SCM"
2. SCM: Select "Git"
3. Repository URL: `https://github.com/muhammadhussnain157/todo-app-tests.git`
   **IMPORTANT:** Use your TEST repository URL (the one with Jenkinsfile and tests)
4. Credentials: Click "Add" → "Jenkins"

   **In the popup:**
   - Kind: "Username with password"
   - Username: Your GitHub username
   - Password: Your GitHub Personal Access Token
   - ID: `github-credentials`
   - Description: `GitHub Access Token`
   - Click "Add"

5. Back on pipeline config, select the credential you just created
6. Branches to build: `*/main`
7. Script Path: `Jenkinsfile`
8. Uncheck "Lightweight checkout"

### Step 6: Save Pipeline Configuration

1. Click "Save" at the bottom
2. You'll be taken to the pipeline page

### Step 7: Configure GitHub Webhook

**You need to add webhooks to BOTH repositories:**

#### Webhook for Test Repository:

1. Go to your **test repository**: `https://github.com/YOUR_USERNAME/todo-app-tests`
2. Click "Settings" tab
3. Click "Webhooks" (left sidebar)
4. Click "Add webhook"
5. Fill in:
   - Payload URL: `http://13.235.97.7:8080/github-webhook/`
   - Content type: `application/json`
   - Secret: Leave empty
   - Which events: "Just the push event"
   - Active: Check
6. Click "Add webhook"

#### Webhook for Application Repository:

1. Go to your **app repository**: `https://github.com/YOUR_USERNAME/todo`
2. Click "Settings" tab
3. Click "Webhooks" (left sidebar)
4. Click "Add webhook"
5. Fill in same details as above
6. Click "Add webhook"

**Why Both?** 
- Changes to tests trigger pipeline
- Changes to app also trigger pipeline for integration testing

### Step 8: Test Manual Build

1. Go back to Jenkins: `http://13.235.97.7:8080`
2. Click on your pipeline: `todo-app-pipeline`
3. Click "Build Now" (left sidebar)
4. Watch the build progress under "Build History"
5. Click on the build number (e.g., #1)
6. Click "Console Output" to see logs
7. Wait for build to complete (10-15 minutes first time)

**What should happen:**
- Checkout Application Code ✓
- Checkout Test Code ✓
- Verify Files ✓
- Stop existing containers ✓
- Build and run application ✓
- Verify deployment ✓
- Run Selenium tests ✓
- Publish test results ✓
- Display logs ✓
- Send email ✓

---

## Part V: Email Notification Setup

### Step 1: Configure Email Server in Jenkins

1. Go to Jenkins: `http://13.235.97.7:8080`
2. Click "Manage Jenkins"
3. Click "System" (or "Configure System")
4. Scroll down to find "Extended E-mail Notification" section

### Step 2: Gmail SMTP Configuration (Recommended)

**First, create an App Password in Gmail:**

1. Go to https://myaccount.google.com/
2. Click "Security" (left sidebar)
3. Under "How you sign in to Google":
   - Enable "2-Step Verification" if not already enabled
   - Click "2-Step Verification"
   - Scroll to bottom, click "App passwords"
4. Create app password:
   - Select app: "Mail"
   - Select device: "Other (Custom name)"
   - Name it: "Jenkins"
   - Click "Generate"
5. **Copy the 16-character password** (looks like: `abcd efgh ijkl mnop`)

**Now configure Jenkins:**

1. In Extended E-mail Notification section:
   - SMTP server: `smtp.gmail.com`
   - SMTP Port: `587`
   - Click "Advanced" button

2. In Advanced settings:
   - Click "Add" next to Credentials
   - Kind: "Username with password"
   - Username: Your full Gmail address (e.g., `youremail@gmail.com`)
   - Password: The 16-character app password you just created
   - ID: `gmail-smtp`
   - Description: `Gmail SMTP Credentials`
   - Click "Add"

3. Select the credential you just created
4. Check "Use SSL"
5. Default Content Type: `text/plain`
6. Default Recipients: Your email (same as admin email)

### Step 3: Configure Standard Email Notification

1. Scroll down further to "E-mail Notification" section
2. SMTP server: `smtp.gmail.com`
3. Click "Advanced"
4. Check "Use SMTP Authentication"
5. User Name: Your Gmail address
6. Password: The 16-character app password
7. Check "Use SSL"
8. SMTP Port: `465`

### Step 4: Test Email Configuration

1. Check "Test configuration by sending test e-mail"
2. Test e-mail recipient: Your email address
3. Click "Test configuration"
4. You should see "Email was successfully sent"
5. Check your email inbox for test message

### Step 5: Save Configuration

1. Scroll to bottom
2. Click "Save"

---

## Part VI: Running & Verifying Tests

### Step 1: Make a Code Change to Trigger Build

**On EC2, in the test repository:**

1. SSH to EC2:
   ```bash
   ssh -i ~/.ssh/todo-app-key.pem ubuntu@13.235.97.7
   ```

2. Navigate to test repository:
   ```bash
   cd ~/todo-app-tests
   ```

3. Make a small change (add a comment to README):
   ```bash
   echo "# Test change" >> README.md
   ```

4. Commit and push:
   ```bash
   git add .
   git commit -m "Test automatic build trigger"
   git push
   ```
   
   Enter GitHub username and Personal Access Token when prompted

### Step 2: Watch Jenkins Build Automatically

1. Go to Jenkins: `http://13.235.97.7:8080`
2. Click on your pipeline
3. Within 1-2 minutes, you should see a new build start automatically
4. Click on the build number
5. Click "Console Output"
6. Watch the build progress

### Step 3: Verify Build Stages

Monitor the console output for these stages:

1. ✅ **Checkout Application Code** - Pulls app from GitHub
2. ✅ **Checkout Test Code** - Pulls tests from GitHub
3. ✅ **Verify Files** - Checks both repositories
4. ✅ **Stop Existing Containers** - Cleanup
5. ✅ **Build and Run Application** - Starts app containers
6. ✅ **Verify Deployment** - Health check
7. ✅ **Run Selenium Tests** - Executes all 14 test cases
8. ✅ **Publish Test Results** - Uploads to Jenkins
9. ✅ **Display Container Logs** - Shows app logs
10. ✅ **Post Actions** - Sends email

### Step 4: View Test Results in Jenkins

1. After build completes, go back to the build page
2. You should see "Test Result" link (left sidebar)
3. Click it to see:
   - Total tests run
   - Passed tests (green)
   - Failed tests (red)
   - Test duration
4. Click on individual tests to see details

### Step 5: Check Email Notification

1. Open your email inbox
2. Look for email with subject: `Build #X - SUCCESS - Y/14 Tests Passed`
3. Open the email
4. Verify it contains:
   - Build information
   - Test summary (Total, Passed, Failed, Skipped)
   - Detailed test results
   - Application URL
   - Commit information

### Step 6: Access Deployed Application

1. Open browser
2. Go to: `http://13.235.97.7:3001`
3. You should see the todo app login page
4. Try to sign up and use the application

### Step 7: Verify Containers are Running on EC2

SSH into your EC2 instance:

```bash
ssh -i ~/.ssh/todo-app-key.pem ubuntu@13.235.97.7
```

Then check:

```bash
docker ps
```

You should see:
- `todo-jenkins-web` - Running on port 3001
- `todo-jenkins-db` - MongoDB on port 27018

Check logs:
```bash
docker logs todo-jenkins-web
docker logs todo-jenkins-db
```

---

## Troubleshooting Guide

### Problem 1: Tests Fail with "Connection Refused"

**Symptoms:**
- Tests fail with error message about connection
- Console shows "ECONNREFUSED"

**Solution:**
1. Check if application is running:
   ```bash
   curl http://13.235.97.7:3001
   ```
2. If not responding, check container status:
   ```bash
   docker ps
   docker logs todo-jenkins-web
   ```
3. May need to increase wait time in Jenkinsfile:
   - Find line `sleep 120`
   - Change to `sleep 180` (3 minutes)
   - Commit and push

### Problem 2: Email Not Sending

**Symptoms:**
- Build succeeds but no email received
- Console shows email error

**Solution:**
1. Check spam folder
2. Verify Gmail app password is correct
3. Check Jenkins email configuration:
   - Manage Jenkins → System
   - Extended E-mail Notification
   - Test email configuration again
4. Check Jenkins console output for email errors
5. Verify git commit has an email:
   ```bash
   git log -1 --pretty=format:'%ae'
   ```

### Problem 3: Docker Build Fails in Jenkins

**Symptoms:**
- "Run Selenium Tests" stage fails
- Error about Docker

**Solution:**
1. SSH to EC2
2. Verify Jenkins can use Docker:
   ```bash
   sudo su - jenkins
   docker ps
   exit
   ```
3. If permission denied:
   ```bash
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```
4. Wait 2 minutes, then retry build

### Problem 4: GitHub Webhook Not Triggering

**Symptoms:**
- Push to GitHub doesn't trigger build
- Must click "Build Now" manually

**Solution:**
1. Check webhook status:
   - GitHub → Repo → Settings → Webhooks
   - Click on the webhook
   - Scroll to "Recent Deliveries"
   - Should show green checkmarks
2. If red X:
   - Check EC2 Security Group has port 8080 open
   - Check Jenkins URL ends with `/github-webhook/`
3. Redeliver webhook:
   - Click on a delivery
   - Click "Redeliver"

### Problem 5: MongoDB Connection Error

**Symptoms:**
- App can't connect to database
- Error about MongoDB in logs

**Solution:**
1. Check MongoDB container:
   ```bash
   docker ps -a | grep mongo
   docker logs todo-jenkins-db
   ```
2. Restart containers:
   ```bash
   docker-compose -f docker-compose.jenkins.yml down
   docker-compose -f docker-compose.jenkins.yml up -d
   ```

### Problem 6: ChromeDriver Version Mismatch

**Symptoms:**
- Tests fail with ChromeDriver error
- Version mismatch message

**Solution:**
1. The Dockerfile.test automatically matches versions
2. If still failing, rebuild Docker image:
   ```bash
   docker build -f Dockerfile.test -t test-image .
   ```
3. Delete old image from Jenkins workspace

### Problem 7: Out of Memory on EC2

**Symptoms:**
- Jenkins becomes unresponsive
- Build hangs or crashes

**Solution:**
1. Check memory:
   ```bash
   free -h
   ```
2. If low, restart Jenkins:
   ```bash
   sudo systemctl restart jenkins
   ```
3. Consider upgrading to t2.large if budget allows

### Problem 8: Tests Pass Locally But Fail in Jenkins

**Symptoms:**
- npm test works on your computer
- Same tests fail in Jenkins

**Solution:**
1. Check TEST_BASE_URL is correct in Jenkinsfile
2. Wait longer for app to be ready:
   - Increase sleep time in Build stage
3. Check EC2 security groups allow port 3001
4. SSH to EC2 and manually test:
   ```bash
   curl http://localhost:3001
   ```

### Problem 9: Cannot SSH to EC2

**Symptoms:**
- Connection timeout or refused
- Can't connect to EC2 instance

**Solution:**
1. Check EC2 is running:
   - AWS Console → EC2 → Instances
   - Should show "Running"
2. Check security group:
   - Instances → Security → Security groups
   - Inbound rules should have port 22 from your IP
3. Check key file permissions:
   ```bash
   chmod 400 ~/.ssh/todo-app-key.pem
   ```

### Problem 10: Jenkins Build Takes Too Long

**Symptoms:**
- Build runs for 30+ minutes
- Never completes

**Solution:**
1. Check console output to see where it's stuck
2. Common issues:
   - npm install taking long: Network issue, retry
   - Docker build stuck: Increase timeout
   - Tests running forever: Check app is responding
3. Click "Cancel" (X button) on build
4. Fix issue and rebuild

---

## Quick Reference Commands

### Git Commands (On EC2)
```bash
# Check status
git status

# Add all changes
git add .

# Commit
git commit -m "Your message"

# Push
git push

# View log
git log --oneline
```

### EC2 Commands
```bash
# Connect
ssh -i ~/.ssh/todo-app-key.pem ubuntu@13.235.97.7

# Check Docker containers
docker ps

# View logs
docker logs todo-jenkins-web
docker logs todo-jenkins-db

# Restart containers
docker-compose -f docker-compose.jenkins.yml restart

# Stop all
docker-compose -f docker-compose.jenkins.yml down

# Start all
docker-compose -f docker-compose.jenkins.yml up -d
```

### Jenkins URLs
- Main: `http://13.235.97.7:8080`
- Manage: `http://13.235.97.7:8080/manage`
- Jobs: `http://13.235.97.7:8080/view/all/builds`

---

## Success Checklist

### Part I - Repository Setup ✅
- [ ] Todo application repository created on GitHub
- [ ] Test repository created separately on GitHub
- [ ] Both repositories cloned on EC2
- [ ] All 14 test cases in test repository
- [ ] Jenkinsfile in test repository
- [ ] Dockerfile.test in test repository

### Part II - Jenkins CI/CD ✅
- [ ] EC2 instance running (Ubuntu)
- [ ] Docker installed on EC2
- [ ] Jenkins installed and accessible
- [ ] All required plugins installed
- [ ] Pipeline job created
- [ ] GitHub webhooks configured for BOTH repos
- [ ] Email notifications working
- [ ] Jenkins pulls from both repositories

### Verification ✅
- [ ] Push to test repo → Build triggers
- [ ] Push to app repo → Build triggers
- [ ] All 10 stages complete successfully
- [ ] 14 tests pass in Jenkins
- [ ] Test results visible in Jenkins UI
- [ ] Email received with test summary
- [ ] App accessible at `http://EC2_IP:3001`
- [ ] Can sign up and use todo app

---

## Final Notes

**Congratulations!** If you've completed all steps, you now have:

1. ✅ **Two-repository architecture** separating application and test code
2. ✅ **14 automated Selenium test cases** testing authentication, CRUD operations, navigation, and data persistence
3. ✅ **Fully automated Jenkins CI/CD pipeline** that pulls from both repositories, builds, deploys, tests, and notifies
4. ✅ **Containerized deployment** using Docker and Docker Compose
5. ✅ **Email notifications** with detailed test results
6. ✅ **Production-ready application** running on AWS EC2 Ubuntu

**What you learned:**
- Multi-repository project structure
- Selenium WebDriver automation with headless Chrome
- Jest testing framework
- Jenkins pipeline configuration with multiple SCM sources
- Docker containerization and multi-stage builds
- AWS EC2 deployment on Linux
- GitHub webhooks for multiple repositories
- Email integration with Gmail SMTP
- CI/CD best practices and automation

**Key Differences from Standard Setup:**
- ✅ Tests in separate repository (teacher's requirement)
- ✅ Jenkins pulls from TWO GitHub repositories
- ✅ All operations performed on EC2 Ubuntu (no Windows/Mac)
- ✅ Jenkinsfile manages both app and test code
- ✅ Email sent based on test repository commits

**Next Steps:**
- Add more test cases for edge cases
- Implement test coverage reports
- Add Slack notifications
- Set up staging environment
- Implement blue-green deployment
- Add performance testing

**Need Help?**
- Review console output carefully
- Check troubleshooting section
- Verify all prerequisites are installed
- Ensure security groups are configured correctly
- Double-check email addresses match

---

**Document Version:** 2.0 (Two-Repository Architecture)  
**Last Updated:** November 21, 2025  
**Author:** DevOps Assignment Guide  
**Course:** Cloud Computing - Automated Testing & CI/CD  
**Platform:** AWS EC2 Ubuntu 22.04 LTS  

---

## Quick Summary - Two Repository Structure

```
Repository 1: todo (Application Code)
├── components/
├── pages/
├── models/
├── lib/
├── docker-compose.jenkins.yml
├── Dockerfile
└── package.json

Repository 2: todo-app-tests (Test Code)
├── tests/
│   ├── auth.test.js
│   ├── todo.test.js
│   └── helpers/driverHelper.js
├── Jenkinsfile (pulls from BOTH repos)
├── Dockerfile.test
├── jest.config.js
└── package.json

Jenkins Pipeline Flow:
1. Checkout app code → app/ directory
2. Checkout test code → tests/ directory
3. Deploy app using docker-compose
4. Run tests from tests/ directory
5. Email results to committer
```

**This structure meets teacher's requirements while maintaining full CI/CD automation!**
