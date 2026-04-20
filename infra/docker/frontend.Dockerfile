
# checkov:skip=CKV_DOCKER_3: skip checkov on k8s branch
# checkov:skip=CKV_DOCKER_2: skip checkov on k8s branch

# Use official Node.js image as base
FROM node:20

# Set working directory inside the container
WORKDIR /app/frontend

# Copy package.json and package-lock.json to install dependencies
COPY ../../app/frontend/package*.json ./

# Copy the rest of the frontend source code
COPY ../../app/frontend/ .

# Install dependencies including 'serve' globally
RUN npm install && npm install -g serve

# Build the React app for production
RUN npm run build

# Run as non-root user (node user exists in the base image)
USER node

# Expose port 3000 (commonly used for React apps)
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => process.exit(r.statusCode < 400 ? 0 : 1)).on('error', () => process.exit(1))"

# Start the app using 'serve' to serve static files from the build folder
CMD ["serve", "-s", "dist", "-l", "3000"]