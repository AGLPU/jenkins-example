# Use NGINX as the base image
FROM nginx:alpine

# Copy the index.html file into the default NGINX directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to access the app via HTTP
EXPOSE 80
