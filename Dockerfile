# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all application files
COPY . .

# Set build-time environment variable
ARG MONGODB_URI=mongodb://admin:todoapp123@todo-part1-db:27017/tododb?authSource=admin
ENV MONGODB_URI=$MONGODB_URI

# Build the Next.js application
RUN npm run build

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
