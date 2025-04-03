#!/bin/bash

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

# ASCII Art Logo (enhanced readability)
LOGO="
${MAGENTA}██╗    ██╗ ██████╗     ██████╗ ███████╗██╗   ██╗    ███████╗██╗      ██████╗ ██╗    ██╗
${MAGENTA}██║    ██║ ██╔══██╗    ██╔══██╗██╔════╝██║   ██║    ██╔════╝██║     ██╔═══██╗██║    ██║
${MAGENTA}██║ █╗ ██║ ██████╔╝    ██║  ██║█████╗  ██║   ██║    █████╗  ██║     ██║   ██║██║ █╗ ██║
${MAGENTA}██║███╗██║ ██╔═══╝     ██║  ██║██╔══╝  ╚██╗ ██╔╝    ██╔══╝  ██║     ██║   ██║██║███╗██║
${MAGENTA}╚███╔███╔╝ ██║         ██████╔╝███████╗ ╚████╔╝     ██║     ███████╗╚██████╔╝╚███╔███╔╝
${MAGENTA} ╚══╝╚══╝  ╚═╝         ╚═════╝ ╚══════╝  ╚═══╝      ╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝ 
${NC}"

pause() {
    echo -e "\n${CYAN}→ Press ${YELLOW}[Enter]${CYAN} to continue...${NC}"
    read -r
}

# Enhanced container status check
container_status() {
    if [[ ! -f docker-compose.yml ]]; then
        echo -e "${RED}❌ No docker-compose.yml found in the current directory${NC}"
        return
    fi

    # Determine project name (default to current directory name if not set)
    local project_name="${COMPOSE_PROJECT_NAME:-$(basename "$PWD")}"

    local containers=$(docker ps --format "{{.Names}}|{{.Status}}|{{.Ports}}" --filter "name=${project_name}")

    if [[ -z "$containers" ]]; then
        # echo -e "${YELLOW}⚠️  No containers are currently running${NC}"
        return
    fi

    # Define column widths
    local name_width=10
    local status_width=18
    local ports_width=47

    # Generate border line (matches total table width of 70 characters)
    local line=$(printf "%$((name_width + status_width + ports_width + 10))s" " " | tr ' ' '─')

    # Print header
    printf "\n${CYAN} 📦 Container Status:${NC}\n"
    printf "${CYAN}┌%s┐${NC}\n" "$line"
    printf "${CYAN}│ ${GREEN}%-${name_width}s${CYAN} │ ${GREEN}%-$((status_width + 1))s${CYAN} │ ${GREEN}%-$((ports_width + 1))s${CYAN} │${NC}\n" "Name" "Status" "Ports"
    printf "${CYAN}├%s┤${NC}\n" "$line"

    # Process containers
    while IFS='|' read -r orig_name orig_status orig_ports; do
        # Strip 'project_name-' prefix from name
        local name="${orig_name#${project_name}-}"
        
        name="${name%-[0-9]}"


        if [[ ${#name} -gt $name_width ]]; then
            name="${name:0:$((name_width - 3))}..."
        fi

        # Status
        local status=$orig_status
        local status_dot="${YELLOW}●${NC}"
        [[ "$status" == *"Up"* ]] && status_dot="${GREEN}●${NC}"
        [[ "$status" == *"Exited"* ]] && status_dot="${RED}●${NC}"
        if [[ ${#status} -gt $status_width ]]; then
            status="${status:0:$((status_width - 3))}..."
        fi

        # Clean up ports by removing '0.0.0.0:' patterns
        local ports=$(echo "$orig_ports" | sed 's/0.0.0.0://g')
        if [[ ${#ports} -gt $ports_width ]]; then
            ports="${ports:0:$((ports_width - 3))}..."
        fi

        # Print row
        printf "${CYAN}│ ${NC}%-${name_width}s ${CYAN}│ ${NC}%b%-$((status_width - 1))s ${CYAN}│ ${NC}%-${ports_width}s  ${CYAN}│${NC}\n" \
            "$name" "$status_dot " "$status" "$ports"

    done <<< "$containers"

    printf "${CYAN}└%s┘${NC}\n" "$line"
    echo
}



# Function to display menu
show_menu() {
    clear
    echo -e "${LOGO}"

    # Show container status at the top
    container_status
    echo

    menu_title="${CYAN}┌─────────────────────────────────────────────────────────────────────────────────────┐\n│${MAGENTA} 🚀 WORDPRESS DEVELOPMENT OPTIONS 🚀${CYAN}                                                 │\n└─────────────────────────────────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "$menu_title"

    options=(
        "🚀 Start Containers ${GRAY}(docker compose up -d)${NC}"
        "🛑 Stop Containers ${GRAY}(docker compose down)${NC}"
        "♻️  Restart Containers ${GRAY}(docker compose restart)${NC}"
        "📋 View Docker Logs ${GRAY}(live logs, Ctrl+C to exit)${NC}"
        "🐚 WordPress Shell ${GRAY}(bash into theme directory)${NC}"
        "🐬 MySQL Shell ${GRAY}(access WordPress database)${NC}"
        "📦 Install Theme Dependencies ${GRAY}(composer & npm)${NC}"
        "🛠️  Build Theme Assets ${GRAY}(npm run build)${NC}"
        "👀 Watch Theme Assets ${GRAY}(npm run dev)${NC}"
        "🧹 Clean Docker Environment ${GRAY}(remove containers & volumes)${NC}"
        "❌ Exit ${GRAY}(quit script)${NC}"
    )

    for i in "${!options[@]}"; do
        printf " ${GREEN}%2d)${NC} ${options[$i]}\n" "$((i+1))"
    done

    echo -ne "\n${YELLOW} ➜ Enter your selection: ${NC}"
}

confirm_action() {
    read -rp "$1 (y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]]
}

# Function to handle user input
handle_choice() {
    case $1 in
        1)
            echo -e "\n${CYAN}🚀 Launching containers...${NC}"
            docker compose up -d
            echo -e "${GREEN}✅ Containers are up and running!${NC}"
            echo -e "🌐 WordPress: ${CYAN}http://localhost:8080${NC}"
            echo -e "🛠️  phpMyAdmin: ${CYAN}http://localhost:8081${NC}"
            ;;
        2)
            echo -e "\n${CYAN}🛑 Stopping containers...${NC}"
            docker compose down
            echo -e "${GREEN}✅ Containers stopped.${NC}"
            ;;
        3)
            echo -e "\n${CYAN}♻️  Restarting containers...${NC}"
            docker compose restart
            echo -e "${GREEN}✅ Containers restarted.${NC}"
            ;;
        4)
            echo -e "\n${CYAN}📋 Displaying logs (Ctrl+C to exit)...${NC}"
            docker compose logs -f
            ;;
        5)
            echo -e "\n${CYAN}🐚 Opening WordPress shell...${NC}"
            docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && bash"
            ;;
        6)
            echo -e "\n${CYAN}🐬 Opening MySQL shell...${NC}"
            docker compose exec db mysql -uwordpress -pwordpress_password wordpress
            ;;
        7)
            echo -e "\n${CYAN}📦 Installing dependencies...${NC}"
            docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && composer install && npm install"
            echo -e "${GREEN}✅ Dependencies installed successfully!${NC}"
            ;;
        8)
            echo -e "\n${CYAN}🛠️  Building theme assets...${NC}"
            docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && npm run build"
            echo -e "${GREEN}✅ Theme assets built successfully!${NC}"
            ;;
        9)
            echo -e "\n${CYAN}👀 Watching theme assets (Ctrl+C to exit)...${NC}"
            docker compose exec wordpress bash -c "cd /var/www/html/wp-content/themes/sage-theme && npm run dev"
            ;;
        10)
            echo -e "\n${RED}⚠️  WARNING: This will remove all Docker volumes and containers!${NC}"
            confirm_action "Are you absolutely sure you want to proceed?" && docker compose down -v && echo -e "${GREEN}✅ Docker environment cleaned!${NC}"
            ;;
        11)
            echo -e "\n${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}❌ Invalid option selected.${NC}"
            ;;
    esac
    pause
}

# Main loop
while true; do
    show_menu
    read -r choice
    handle_choice "$choice"
done
