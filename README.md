# Gatepass Docker Image

This repository contains a Dockerfile for building a PHP 8.2 image with various dependencies installed
designed for Gatepass Project to have same environment everywhere by storing dependencies in Image itself

## Build and Push Image

The image is built and pushed to Docker Hub using GitHub Actions. The workflow is triggered on push events to the main branch and can also be triggered manually.

## Dependencies

The image is built with the following dependencies installed: libzip-dev, libpng-dev, libjpeg-dev, libfreetype6-dev, libonig-dev, libxml2-dev, libicu-dev, unzip, git, GD, Zip, Exif, Intl, MySQLi, PDO, XML, bcmath, mbstring.

##

Composer is installed globally, and the project's dependencies are installed using Composer.

## Caching

The GitHub Actions workflow uses caching to speed up the build process.

## Usage

To use this image, you can pull it from Docker Hub using the following command:

```bash
docker pull saurabhgroup/gatepass:8.2
```
## Docker Compose
Sample Docker Compose for this

```yaml
services:
  gatepass:
    image: saurabhgroup/gatepass:latest
    container_name: gatepass
    volumes:
      - ./gatepass:/var/www/html
      - vendor-data:/var/www/html/vendor
    networks:
      - myapp-network

volumes:
  vendor-data:

networks:
  myapp-network:
    external: true
```

then edit the .env file of the project

**Note:** It Comes along with vendor folder while Mounting host takes preference so vendor folder gets overriden inside container so keep `vendor-data:/var/www/html/vendor` 

## Reverse Proxy
Image uses php-fpm so Reverse Proxy like Nginx or Caddy is Required

<u>_Sample Caddyfile_</u>

```caddyfile
app.local {
    root * /var/www/html
    php_fastcgi gatepass:9000
    file_server
}
```
