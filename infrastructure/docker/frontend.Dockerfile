# Use official Node.js image as base
FROM node:20

# Set working directory inside the container
WORKDIR /app/frontend

# Copy package.json and package-lock.json to install dependencies
COPY app/frontend/package*.json ./

# Copy the rest of the frontend source code
COPY app/frontend/ .

# Install dependencies including 'serve' globally
RUN npm install && npm install -g serve

# Build the React app for production
RUN npm run build

# Expose port 3000 (commonly used for React apps)
EXPOSE 3000

# Start the app using 'serve' to serve static files from the build folder
CMD ["serve", "-s", "build", "-l", "3000"]