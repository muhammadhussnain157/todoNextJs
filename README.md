# TODO App - Docker & Jenkins Deployment

A Next.js TODO application with MongoDB backend, configured for containerized deployment on AWS EC2 using Docker and Jenkins CI/CD pipeline.

## 📋 Project Structure

```
todo-app-main/
├── components/          # React components
├── lib/                # Database connection utilities
├── models/             # MongoDB models
├── pages/              # Next.js pages and API routes
├── public/             # Static assets
├── styles/             # CSS modules
├── Dockerfile          # Docker image configuration (Part-I)
├── docker-compose.yml  # Docker Compose for Part-I deployment
├── docker-compose.jenkins.yml  # Docker Compose for Part-II (Jenkins)
├── Jenkinsfile         # Jenkins pipeline configuration
├── .dockerignore       # Files to exclude from Docker build
├── .env                # Environment variables (local development)
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

## 🛠 Tech Stack

- **Frontend:** Next.js 12, React 17
- **Backend:** Next.js API Routes
- **Database:** MongoDB 7.0
- **Containerization:** Docker, Docker Compose
- **CI/CD:** Jenkins
- **Cloud:** AWS EC2
- **Icons:** FontAwesome

## 📦 Prerequisites

### For Local Development:
- Node.js 18+ 
- MongoDB (local or cloud)

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
