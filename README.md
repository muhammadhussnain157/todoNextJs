# TODO App - Docker & Jenkins Deployment

A Next.js TODO application with MongoDB backend, configured for containerized deployment on AWS EC2 using Docker and Jenkins CI/CD pipeline with automated Selenium testing.

## 📋 Project Structure

```
todo-app-main/
├── components/          # React components
├── lib/                # Database connection utilities
├── models/             # MongoDB models
├── pages/              # Next.js pages and API routes
├── public/             # Static assets
├── styles/             # CSS modules
├── tests/              # Selenium automated tests
│   ├── auth.test.js        # Authentication tests
│   ├── todo.test.js        # Todo management tests
│   └── helpers/
│       └── driverHelper.js # Selenium utilities
├── Dockerfile          # Docker image configuration (Part-I)
├── Dockerfile.test     # Docker image for Selenium tests
├── docker-compose.yml  # Docker Compose for Part-I deployment
├── docker-compose.jenkins.yml  # Docker Compose for Part-II (Jenkins)
├── Jenkinsfile         # Jenkins pipeline configuration
├── jest.config.js      # Jest test configuration
├── .dockerignore       # Files to exclude from Docker build
├── .env                # Environment variables (local development)
├── TESTING_DOCUMENTATION.md  # Complete testing guide
├── QUICK_START.md      # Quick start guide
└── Assignment2_Guide.md  # Complete deployment guide
```

## 🚀 Features

- ✅ Create, read, update, and delete todos
- ✅ Mark todos as important
- ✅ Track task completion
- ✅ Filter by pending and important tasks
- ✅ Persistent MongoDB database
- ✅ Dockerized deployment
- ✅ Jenkins CI/CD automation
- ✅ **Automated Selenium testing (14 test cases)**
- ✅ **Email notifications with test results**

## 🛠 Tech Stack

- **Frontend:** Next.js 12, React 17
- **Backend:** Next.js API Routes
- **Database:** MongoDB 7.0
- **Containerization:** Docker, Docker Compose
- **CI/CD:** Jenkins
- **Testing:** Selenium WebDriver, Jest
- **Browser:** Headless Chrome
- **Cloud:** AWS EC2
- **Icons:** FontAwesome

## 📦 Prerequisites

### For Local Development:
- Node.js 18+ 
- MongoDB (local or cloud)
- Chrome browser & ChromeDriver (for testing)

### For Cloud Deployment:
- AWS Account
- EC2 instance (t2.medium recommended)
- Docker & Docker Compose
- Jenkins (for Part-II)
- GitHub account

## 🏃‍♂️ Local Development

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/todo-app-main.git
cd todo-app-main
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

The `.env` file is already configured for local development:

```env
MONGODB_URI=mongodb://localhost:27017/tododb
```

### 4. Start MongoDB locally

```bash
# Using Docker
docker run -d -p 27017:27017 --name mongodb mongo:7.0

# Or use local MongoDB installation
```

### 5. Run the development server

```bash
npm run dev
```

Visit `http://localhost:3000` to see the application.

### 6. Run Automated Tests

```bash
# Run all Selenium tests
npm test

# Run with specific URL
TEST_BASE_URL=http://localhost:3000 npm test
```

## 🧪 Automated Testing (Part-I)

This project includes **14 comprehensive Selenium test cases**:

### Authentication Tests (5 tests)
1. **TC1** - User Signup
2. **TC2** - Valid Login
3. **TC3** - Invalid Login
4. **TC4** - Duplicate Signup Prevention
5. **TC5** - Form Validation

### Todo Management Tests (9 tests)
6. **TC6** - Create Todo
7. **TC7** - Mark Complete
8. **TC8** - Mark Important
9. **TC9** - Delete Todo
10. **TC10** - Navigate Important Page
11. **TC11** - Navigate Pending Page
12. **TC12** - Create Multiple Todos
13. **TC13** - Todo Persistence
14. **TC14** - Authentication Redirect

**Testing Technology:**
- Language: JavaScript (Node.js)
- Framework: Jest
- Browser Automation: Selenium WebDriver
- Browser: Headless Chrome
- Reports: JUnit XML for Jenkins

**📖 See [TESTING_DOCUMENTATION.md](./TESTING_DOCUMENTATION.md) for complete testing guide**

## 🐳 Docker Deployment (Part-I)

### Quick Start

```bash
# Build and start containers
docker-compose up -d

# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

**Access:** `http://localhost:3000`

### MongoDB Credentials
- Username: `admin`
- Password: `todoapp123`
- Database: `tododb`

## 🔄 Jenkins Deployment (Part-II)

### Jenkins Pipeline Features

The Jenkins pipeline automates:
- ✅ Code checkout from GitHub
- ✅ Docker container deployment
- ✅ **Automated Selenium test execution**
- ✅ **Test result reporting (JUnit XML)**
- ✅ **Email notifications with test summary**

### Pipeline Stages

1. **Checkout Code** - Pull from GitHub
2. **Verify Files** - Validate configuration
3. **Stop Existing Containers** - Clean up
4. **Build and Run** - Deploy application
5. **Verify Deployment** - Health checks
6. **Run Selenium Tests** ⭐ NEW - Execute automated tests
7. **Publish Test Results** ⭐ NEW - Jenkins UI integration
8. **Display Container Logs** - Debug output

### Email Notification

After each build, automatically sends email with:
- Build status and number
- Deployment URL
- Test summary (Total/Passed/Failed/Skipped)
- Detailed test results
- Commit information

### Quick Start

```bash
# Deploy using Jenkins compose file
docker-compose -f docker-compose.jenkins.yml up -d

# Check container status
docker-compose -f docker-compose.jenkins.yml ps

# Stop containers
docker-compose -f docker-compose.jenkins.yml down
```

**Access:** `http://localhost:3001`

**📖 See [QUICK_START.md](./QUICK_START.md) for step-by-step setup**

## ☁️ AWS EC2 Deployment

Follow the complete step-by-step guide in [Assignment2_Guide.md](./Assignment2_Guide.md)

### Part-I: Dockerfile Deployment
- Uses Dockerfile to build application image
- Runs on port **3000**
- MongoDB on port **27017**

### Part-II: Jenkins CI/CD with Testing
- Uses volume mounting (no Dockerfile)
- Runs on port **3001**
- MongoDB on port **27018**
- Automated builds on GitHub push
- **Automated Selenium testing**
- **Email notifications**

## 📝 Environment Variables

### Local Development (.env)
```env
MONGODB_URI=mongodb://localhost:27017/tododb
```

### Docker Deployment (docker-compose.yml)
```yaml
MONGODB_URI=mongodb://admin:todoapp123@mongodb:27017/tododb?authSource=admin
```

### Jenkins Deployment (docker-compose.jenkins.yml)
```yaml
MONGODB_URI=mongodb://admin:todoapp123@todo-jenkins-db:27017/tododb?authSource=admin
TEST_BASE_URL=http://EC2_IP:3001
```

## 🗂 Database Schema

### Todo Model

```javascript
{
  content: String,      // Todo text
  important: Boolean,   // Is it marked important?
  task_done: Boolean,   // Is it completed?
  createdAt: Date,     // Auto-generated timestamp
}
```

## 📡 API Routes

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Home page with all todos |
| GET | `/important` | View important todos |
| GET | `/pending` | View pending todos |
| POST | `/api/new` | Create new todo |
| PATCH | `/api/todo/[id]` | Update todo |
| DELETE | `/api/todo/[id]` | Delete todo |

## 🔧 Troubleshooting

### Local Development Issues

**MongoDB Connection Error:**
```bash
# Ensure MongoDB is running
docker ps
# or
systemctl status mongodb
```

**Port 3000 in use:**
```bash
# Kill process using port 3000
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill
```

### Testing Issues

**Chrome/ChromeDriver errors:**
```bash
# Check versions
google-chrome --version
chromedriver --version
```

**Tests failing:**
- Ensure application is running
- Check TEST_BASE_URL environment variable
- Review screenshots in `screenshots/` folder

### Docker Issues

**Containers not starting:**
```bash
# Check logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

**MongoDB authentication error:**
- Verify credentials in docker-compose.yml
- Check connection string format
- Remove volumes and restart: `docker-compose down -v && docker-compose up -d`

### Jenkins Issues

**Build fails:**
- Ensure Jenkins user is in docker group: `groups jenkins`
- Verify docker-compose.jenkins.yml exists
- Check Jenkins console output

**Tests not running:**
- Verify Docker Pipeline plugin installed
- Check Dockerfile.test builds successfully
- Review Jenkins console logs

**Email not sending:**
- Configure Email Extension Plugin
- Set SMTP server in Jenkins settings
- Verify git commits have valid email

**Webhook not triggering:**
- Verify EC2 security group allows port 8080
- Check GitHub webhook delivery status
- Ensure webhook URL is correct

## 📸 Screenshots

### Application
- Home page with todo list
- Create new todo
- Mark as important
- Filter pending tasks

### Testing
- Test execution screenshots
- Jenkins test results
- Email notifications

### Deployment
- Running containers (`docker ps`)
- Jenkins pipeline success
- AWS EC2 instance

## 🎓 Learning Objectives

This project demonstrates:
- ✅ Containerized application deployment using Docker
- ✅ Multi-container orchestration with Docker Compose
- ✅ Persistent data volumes for databases
- ✅ Jenkins CI/CD pipeline configuration
- ✅ GitHub webhook integration
- ✅ AWS EC2 cloud deployment
- ✅ **Automated testing with Selenium**
- ✅ **Headless Chrome browser automation**
- ✅ **Jenkins test integration and reporting**
- ✅ **Automated email notifications**
- ✅ Difference between Dockerfile builds vs volume mounting

## 📚 Documentation

- **[TESTING_DOCUMENTATION.md](./TESTING_DOCUMENTATION.md)** - Complete testing guide
- **[QUICK_START.md](./QUICK_START.md)** - Quick setup instructions
- **[Assignment2_Guide.md](./Assignment2_Guide.md)** - Deployment guide

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue in the GitHub repository.

---

**Assignment 2 - Cloud Computing Course**
**With Automated Testing & CI/CD Integration**


## 🏃‍♂️ Local Development

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/todo-app-main.git
cd todo-app-main
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

The `.env` file is already configured for local development:

```env
MONGODB_URI=mongodb://localhost:27017/tododb
```

### 4. Start MongoDB locally

```bash
# Using Docker
docker run -d -p 27017:27017 --name mongodb mongo:7.0

# Or use local MongoDB installation
```

### 5. Run the development server

```bash
npm run dev
```

Visit `http://localhost:3000` to see the application.

## 🐳 Docker Deployment (Part-I)

### Quick Start

```bash
# Build and start containers
docker-compose up -d

# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

**Access:** `http://localhost:3000`

### MongoDB Credentials
- Username: `admin`
- Password: `todoapp123`
- Database: `tododb`

## 🔄 Jenkins Deployment (Part-II)

### Quick Start

```bash
# Deploy using Jenkins compose file
docker-compose -f docker-compose.jenkins.yml up -d

# Check container status
docker-compose -f docker-compose.jenkins.yml ps

# Stop containers
docker-compose -f docker-compose.jenkins.yml down
```

**Access:** `http://localhost:3001`

## ☁️ AWS EC2 Deployment

Follow the complete step-by-step guide in [Assignment2_Guide.md](./Assignment2_Guide.md)

### Part-I: Dockerfile Deployment
- Uses Dockerfile to build application image
- Runs on port **3000**
- MongoDB on port **27017**

### Part-II: Jenkins CI/CD
- Uses volume mounting (no Dockerfile)
- Runs on port **3001**
- MongoDB on port **27018**
- Automated builds on GitHub push

## 📝 Environment Variables

### Local Development (.env)
```env
MONGODB_URI=mongodb://localhost:27017/tododb
```

### Docker Deployment (docker-compose.yml)
```yaml
MONGODB_URI=mongodb://admin:todoapp123@mongodb:27017/tododb?authSource=admin
```

### Jenkins Deployment (docker-compose.jenkins.yml)
```yaml
MONGODB_URI=mongodb://admin:todoapp123@todo-jenkins-db:27017/tododb?authSource=admin
```

## 🗂 Database Schema

### Todo Model

```javascript
{
  content: String,      // Todo text
  important: Boolean,   // Is it marked important?
  task_done: Boolean,   // Is it completed?
  createdAt: Date,     // Auto-generated timestamp
}
```

## 📡 API Routes

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Home page with all todos |
| GET | `/important` | View important todos |
| GET | `/pending` | View pending todos |
| POST | `/api/new` | Create new todo |
| PATCH | `/api/todo/[id]` | Update todo |
| DELETE | `/api/todo/[id]` | Delete todo |

## 🔧 Troubleshooting

### Local Development Issues

**MongoDB Connection Error:**
```bash
# Ensure MongoDB is running
docker ps
# or
systemctl status mongodb
```

**Port 3000 in use:**
```bash
# Kill process using port 3000
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill
```

### Docker Issues

**Containers not starting:**
```bash
# Check logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

**MongoDB authentication error:**
- Verify credentials in docker-compose.yml
- Check connection string format
- Remove volumes and restart: `docker-compose down -v && docker-compose up -d`

### Jenkins Issues

**Build fails:**
- Ensure Jenkins user is in docker group: `groups jenkins`
- Verify docker-compose.jenkins.yml exists
- Check Jenkins console output

**Webhook not triggering:**
- Verify EC2 security group allows port 8080
- Check GitHub webhook delivery status
- Ensure webhook URL is correct

## 📸 Screenshots

### Application
- Home page with todo list
- Create new todo
- Mark as important
- Filter pending tasks

### Deployment
- Running containers (`docker ps`)
- Jenkins pipeline success
- AWS EC2 instance

## 🎓 Learning Objectives

This project demonstrates:
- ✅ Containerized application deployment using Docker
- ✅ Multi-container orchestration with Docker Compose
- ✅ Persistent data volumes for databases
- ✅ Jenkins CI/CD pipeline configuration
- ✅ GitHub webhook integration
- ✅ AWS EC2 cloud deployment
- ✅ Difference between Dockerfile builds vs volume mounting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue in the GitHub repository.

---

**Assignment 2 - Cloud Computing Course**
