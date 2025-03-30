#!/bin/bash

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
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

    local containers=$(docker ps --format "{{.Names}}|{{.Status}}|{{.Ports}}" --filter "name=wpdevflow")

    if [[ -z "$containers" ]]; then
        echo -e "${YELLOW}⚠️  No containers are currently running${NC}"
        return
    fi

    # Define column widths
    local name_width=20
    local status_width=15
    local ports_width=25

    # Generate border line (matches total table width of 70 characters)
    local line=$(printf "%70s" " " | tr ' ' '─')

    # Print header
    printf "\n${CYAN}📦 Container Status:${NC}\n"
    printf "${CYAN}┌%s┐${NC}\n" "$line"
    printf "${CYAN}│ ${GREEN}%-${name_width}s${CYAN} │ ${GREEN}%-$((status_width + 1))s${CYAN} │ ${GREEN}%-$((ports_width + 1))s${CYAN} │${NC}\n" "Name" "Status" "Ports"
    printf "${CYAN}├%s┤${NC}\n" "$line"

    # Process containers
    while IFS='|' read -r orig_name orig_status orig_ports; do
        # Status indicator
        local status_dot="${YELLOW}●${NC}"
        [[ "$orig_status" == *"Up"* ]] && status_dot="${GREEN}●${NC}"
        [[ "$orig_status" == *"Exited"* ]] && status_dot="${RED}●${NC}"

        # Name formatting
        local name=$orig_name
        if [[ ${#name} -gt $name_width ]]; then
            name="${name:0:$((name_width - 3))}..."
        fi

        # Status formatting
        local status=$orig_status
        if [[ ${#status} -gt $status_width ]]; then
            status="${status:0:$((status_width - 3))}..."
        fi

        # Ports formatting
        local ports=$orig_ports
        if [[ ${#ports} -gt $ports_width ]]; then
            ports="${ports:0:$((ports_width - 3))}..."
        fi

        # Print row with precise spacing
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
    echo -e "${CYAN}═══════════ WordPress Development Environment ═══════════${NC}\n"

    # Show container status at the top
    container_status
    echo

    options=(
        "🚀 Start Containers"
        "🛑 Stop Containers"
        "♻️  Restart Containers"
        "📋 View Logs"
        "🐚 Open WordPress Shell"
        "🐬 Open MySQL Shell"
        "📦 Install Dependencies"
        "🛠️  Build Theme Assets"
        "👀 Watch Theme Assets"
        "🧹 Clean Docker Environment"
        "❌ Exit"
    )

    for i in "${!options[@]}"; do
        printf "${GREEN}%2d)${NC} ${options[$i]}\n" "$((i+1))"
    done

    echo -ne "\n${YELLOW}➜ Enter your selection: ${NC}"
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
