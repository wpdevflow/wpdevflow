#!/bin/bash

# Function to display usage
show_usage() {
    echo "Usage: ./dev.sh [command]"
    echo "Commands:"
    echo "  start       - Start the Docker containers"
    echo "  stop        - Stop the Docker containers"
    echo "  restart     - Restart the Docker containers"
    echo "  logs        - View Docker logs"
    echo "  shell       - Open shell in WordPress container"
    echo "  db          - Open MySQL shell"
    echo "  install     - Install WordPress and theme dependencies"
    echo "  build       - Build theme assets"
    echo "  watch       - Watch theme assets for changes"
    echo "  clean       - Remove Docker volumes and containers"
    echo "  help        - Show this help message"
}

# Function to start containers
start_containers() {
    docker compose up -d
    echo "Containers started. Access WordPress at http://localhost:8080"
    echo "Access phpMyAdmin at http://localhost:8081"
}

# Function to stop containers
stop_containers() {
    docker compose down
    echo "Containers stopped"
}

# Function to restart containers
restart_containers() {
    docker compose restart
    echo "Containers restarted"
}

# Function to view logs
view_logs() {
    docker compose logs -f
}

# Function to open shell in WordPress container
open_shell() {
    docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && bash"
}

# Function to open MySQL shell
open_db() {
    docker compose exec db mysql -uwordpress -pwordpress_password wordpress
}

# Function to install dependencies
install_deps() {
    docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && composer install"
    docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && npm install"
}

# Function to build theme assets
build_assets() {
    docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && npm run build" 
}

# Function to watch theme assets
watch_assets() {
    docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && npm run dev" 
}

# Function to clean Docker environment
clean_docker() {
    docker compose down -v
    echo "Docker volumes and containers removed"
}

# Main script
case "$1" in
    "start")
        start_containers
        ;;
    "stop")
        stop_containers
        ;;
    "restart")
        restart_containers
        ;;
    "logs")
        view_logs
        ;;
    "shell")
        open_shell
        ;;
    "db")
        open_db
        ;;
    "install")
        install_deps
        ;;
    "build")
        build_assets
        ;;
    "watch")
        watch_assets
        ;;
    "clean")
        clean_docker
        ;;
    "help"|"")
        show_usage
        ;;
    *)
        echo "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac 