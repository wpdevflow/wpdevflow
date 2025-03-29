# WordPress Theme Development Environment

A modern WordPress theme development environment using Docker, Sage 11, and Vite.

## 🚀 Features

- WordPress 6.x with PHP 8.2
- Sage 11 theme framework
- Vite for modern asset bundling
- Docker-based development environment
- MySQL 8.0 database
- phpMyAdmin for database management
- Hot module replacement for development
- Composer for PHP dependencies
- Node.js for frontend development

## 📋 Prerequisites

- Docker and Docker Compose
- Git

## 🛠️ Installation

1. Clone the repository:
```bash
git clone <your-repository-url>
cd <project-directory>
```

2. Make the development script executable:
```bash
chmod +x dev.sh
```

3. Start the development environment:
```bash
./dev.sh start
```

4. Install dependencies:
```bash
./dev.sh install
```

5. Build theme assets:
```bash
./dev.sh build
```

## 🔧 Development

### Available Commands

- `./dev.sh start` - Start the Docker containers
- `./dev.sh stop` - Stop the Docker containers
- `./dev.sh restart` - Restart the Docker containers
- `./dev.sh logs` - View Docker logs
- `./dev.sh shell` - Open shell in WordPress container
- `./dev.sh db` - Open MySQL shell
- `./dev.sh install` - Install WordPress and theme dependencies
- `./dev.sh build` - Build theme assets
- `./dev.sh watch` - Watch theme assets for changes
- `./dev.sh clean` - Remove Docker volumes and containers

### Access Points

- WordPress: http://localhost:8080
- phpMyAdmin: http://localhost:8081
- Vite Dev Server: http://localhost:5173

### Theme Development

The theme is built using Sage 11, which provides a modern development workflow:

- Blade templating engine
- Laravel Mix for asset compilation
- Modern PHP features
- Webpack/Vite integration

### Directory Structure

```
wp-content/themes/sage-theme/
├── app/                 # Theme PHP files
├── public/             # Compiled assets
├── resources/          # Source assets
│   ├── scripts/       # JavaScript files
│   ├── styles/        # SCSS files
│   └── views/         # Blade templates
└── vendor/            # Composer dependencies
```

## 🔒 Environment Variables

The following environment variables are available in the `docker-compose.yml`:

- `WORDPRESS_DB_HOST`: Database host
- `WORDPRESS_DB_USER`: Database user
- `WORDPRESS_DB_PASSWORD`: Database password
- `WORDPRESS_DB_NAME`: Database name
- `WORDPRESS_DEBUG`: Debug mode (1 or 0)

## 🧹 Cleanup

To completely remove the development environment:

```bash
./dev.sh clean
```

This will remove all Docker containers and volumes.

## 📚 Additional Resources

- [Sage Documentation](https://roots.io/sage/docs/)
- [WordPress Theme Development](https://developer.wordpress.org/themes/)
- [Docker Documentation](https://docs.docker.com/)
- [Vite Documentation](https://vitejs.dev/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
