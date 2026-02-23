#!/bin/bash

# Backhaul Monitor - Sajjad-Alimadadi
# URL: https://github.com/Sajjad-Alimadadi/backhaul-monitor

# Check if already installed
if [ -f "/root/tunnel-monitor.sh" ]; then
    /root/tunnel-monitor.sh "$@"
    exit 0
fi

# First time install
clear
echo "╔════════════════════════════════════════╗"
echo "║   🤖 Backhaul Monitor - Installing..   ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📥 Creating script..."
sleep 1

cat > /root/tunnel-monitor.sh << 'EOFSCRIPT'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_FILE="/root/tunnel-monitor.conf"

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        BOT_TOKEN=""
        ADMIN_ID=""
        INTERVAL=300
        ENABLED=false
    fi
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
BOT_TOKEN="$BOT_TOKEN"
ADMIN_ID="$ADMIN_ID"
INTERVAL=$INTERVAL
ENABLED=$ENABLED
EOF
    chmod 600 "$CONFIG_FILE"
}

send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${ADMIN_ID}" \
        --data-urlencode "text=${message}" \
        -d parse_mode="HTML" > /dev/null 2>&1
}

get_server_ip() {
    local ip=""
    ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    if [ -z "$ip" ]; then
        ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null)
    fi
    if [ -z "$ip" ]; then
        ip=$(curl -s --max-time 5 https://icanhazip.com 2>/dev/null)
    fi
    if [ -z "$ip" ]; then
        ip="Unknown"
    fi
    echo "$ip"
}

get_tunnel_logs() {
    local tunnels=$(systemctl list-unit-files | grep backhaul | awk '{print $1}' | sed 's/backhaul-//g' | sed 's/.service//g')
    local tunnel_count=$(echo "$tunnels" | grep -c .)
    local server_ip=$(get_server_ip)

    local message=""
    message+="🤖 <b>Tunnel Monitor Report</b>"
    message+=$'\n'"━━━━━━━━━━━━━━━━━━━━"
    message+=$'\n'"🌐 <b>Server IP:</b> <code>$server_ip</code>"
    message+=$'\n'"📅 <b>Date:</b> $(date '+%Y/%m/%d')"
    message+=$'\n'"🕐 <b>Time:</b> $(date '+%H:%M:%S')"
    message+=$'\n'"📊 <b>Total Tunnels:</b> $tunnel_count"
    message+=$'\n'"━━━━━━━━━━━━━━━━━━━━"

    local counter=1
    for tunnel in $tunnels; do

        # فقط آخرین لاگ برای تشخیص وضعیت
        local last_log=$(journalctl -u backhaul-$tunnel -n 1 --no-pager 2>/dev/null | tail -1)

        # تشخیص وضعیت از روی آخرین لاگ
        local status_icon=""
        local status_text=""

        if echo "$last_log" | grep -q "🟢"; then
            status_icon="🟢"
            status_text="Active"
        elif echo "$last_log" | grep -q "🔴"; then
            status_icon="🔴"
            status_text="Inactive"
        else
            # Fallback به systemctl
            if [ "$(systemctl is-active backhaul-$tunnel)" = "active" ]; then
                status_icon="🟢"
                status_text="Active"
            else
                status_icon="🔴"
                status_text="Inactive"
            fi
        fi

        [ -z "$last_log" ] && last_log="No logs available"

        message+=$'\n'
        message+=$'\n'"$status_icon <b>Tunnel #$counter — <code>$tunnel</code></b>"
        message+=$'\n'"📶 Status: <b>$status_text</b>"
        message+=$'\n'"📝 Last Log:"
        message+=$'\n'"<code>${last_log}</code>"
        message+=$'\n'"─────────────────────"

        counter=$((counter + 1))
    done

    message+=$'\n'
    message+=$'\n'"✅ <b>Report Complete</b>"
    message+=$'\n'"⏱ Next report in: <b>$((INTERVAL / 60)) minutes</b>"

    send_telegram "$message"
}

setup_cron() {
    crontab -l 2>/dev/null | grep -v "tunnel-monitor.sh" > /tmp/cron.tmp

    if [ "$ENABLED" = true ]; then
        local minutes=$((INTERVAL / 60))
        echo "*/$minutes * * * * /bin/bash /root/tunnel-monitor.sh --send" >> /tmp/cron.tmp
    fi

    crontab /tmp/cron.tmp
    rm /tmp/cron.tmp
}

send_logs() {
    load_config
    if [ -z "$BOT_TOKEN" ] || [ -z "$ADMIN_ID" ]; then
        echo "Error: Bot not configured"
        exit 1
    fi
    get_tunnel_logs
}

uninstall() {
    clear
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║        ⚠️  UNINSTALL WARNING ⚠️         ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}This will remove:${NC}"
    echo -e "  ${RED}✗${NC} Cron jobs"
    echo -e "  ${RED}✗${NC} Configuration file"
    echo -e "  ${RED}✗${NC} Script file"
    echo ""
    read -p "$(echo -e ${YELLOW}Type ${RED}YES${YELLOW} to confirm uninstall:${NC} )" confirm

    if [ "$confirm" = "YES" ]; then
        echo -e "${YELLOW}🗑️  Uninstalling...${NC}"

        echo -ne "${BLUE}[1/3]${NC} Removing cron jobs... "
        crontab -l 2>/dev/null | grep -v "tunnel-monitor.sh" > /tmp/cron.tmp
        crontab /tmp/cron.tmp
        rm -f /tmp/cron.tmp
        echo -e "${GREEN}✓${NC}"
        sleep 1

        echo -ne "${BLUE}[2/3]${NC} Removing config file... "
        rm -f "$CONFIG_FILE"
        echo -e "${GREEN}✓${NC}"
        sleep 1

        echo -ne "${BLUE}[3/3]${NC} Removing script file... "
        echo -e "${GREEN}✓${NC}"
        sleep 1

        echo -e "${GREEN}✅ Uninstall Complete!${NC}"
        echo -e "${YELLOW}👋 Goodbye!${NC}"
        sleep 2

        rm -f /root/tunnel-monitor.sh
        exit 0
    else
        echo -e "${GREEN}✓ Uninstall cancelled${NC}"
        sleep 2
        show_menu
    fi
}

show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   ${GREEN}🤖 Tunnel Monitor - Telegram Bot${BLUE}   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    load_config

    echo -e "${YELLOW}⚙️  Current Settings:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ -z "$BOT_TOKEN" ]; then
        echo -e "  🔑 Bot Token: ${RED}Not Set${NC}"
    else
        echo -e "  🔑 Bot Token: ${GREEN}${BOT_TOKEN:0:15}...${NC}"
    fi
    echo -e "  👤 Admin ID: ${GREEN}${ADMIN_ID:-Not Set}${NC}"
    echo -e "  ⏱  Interval: ${GREEN}${INTERVAL}s${NC} ${BLUE}($(($INTERVAL/60)) minutes)${NC}"
    echo -e "  📊 Status: $([ "$ENABLED" = true ] && echo -e "${GREEN}●${NC} Enabled" || echo -e "${RED}●${NC} Disabled")"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${YELLOW}📋 Menu Options:${NC}"
    echo -e "  ${GREEN}1)${NC} 🔑 Set Bot Token"
    echo -e "  ${GREEN}2)${NC} 👤 Set Admin ID"
    echo -e "  ${GREEN}3)${NC} ⏱  Set Interval"
    echo -e "  ${GREEN}4)${NC} 🔄 Enable/Disable Monitor"
    echo -e "  ${GREEN}5)${NC} 📤 Send Test Report"
    echo -e "  ${GREEN}6)${NC} 🗑️  Uninstall"
    echo -e "  ${GREEN}7)${NC} 🚪 Exit"
    echo ""
    echo -ne "${YELLOW}Select option [1-7]:${NC} "
    read choice

    case $choice in
        1)
            echo ""
            read -p "🔑 Enter Bot Token: " BOT_TOKEN
            save_config
            echo -e "${GREEN}✓ Token saved!${NC}"
            sleep 2
            show_menu
            ;;
        2)
            echo ""
            read -p "👤 Enter Admin ID: " ADMIN_ID
            save_config
            echo -e "${GREEN}✓ Admin ID saved!${NC}"
            sleep 2
            show_menu
            ;;
        3)
            echo ""
            echo -e "${YELLOW}⏱  Select interval:${NC}"
            echo -e "  ${GREEN}1)${NC} 1 minute"
            echo -e "  ${GREEN}2)${NC} 5 minutes"
            echo -e "  ${GREEN}3)${NC} 10 minutes"
            echo -e "  ${GREEN}4)${NC} 15 minutes"
            echo -e "  ${GREEN}5)${NC} 30 minutes"
            echo -e "  ${GREEN}6)${NC} 1 hour"
            echo -e "  ${GREEN}7)${NC} 2 hours"
            echo -e "  ${GREEN}8)${NC} 6 hours"
            echo -e "  ${GREEN}9)${NC} 12 hours"
            echo -e "  ${GREEN}0)${NC} Custom (seconds)"
            echo ""
            read -p "Choice: " int_choice
            case $int_choice in
                1) INTERVAL=60 ;;
                2) INTERVAL=300 ;;
                3) INTERVAL=600 ;;
                4) INTERVAL=900 ;;
                5) INTERVAL=1800 ;;
                6) INTERVAL=3600 ;;
                7) INTERVAL=7200 ;;
                8) INTERVAL=21600 ;;
                9) INTERVAL=43200 ;;
                0) read -p "Enter seconds: " INTERVAL ;;
                *)
                    echo -e "${RED}Invalid choice!${NC}"
                    sleep 2
                    show_menu
                    return
                    ;;
            esac
            save_config
            setup_cron
            echo -e "${GREEN}✓ Interval set to $((INTERVAL/60)) minutes!${NC}"
            sleep 2
            show_menu
            ;;
        4)
            if [ "$ENABLED" = true ]; then
                ENABLED=false
                echo -e "${RED}✓ Monitor Disabled${NC}"
            else
                ENABLED=true
                echo -e "${GREEN}✓ Monitor Enabled${NC}"
            fi
            save_config
            setup_cron
            sleep 2
            show_menu
            ;;
        5)
            echo ""
            echo -e "${YELLOW}📤 Sending test report...${NC}"
            send_logs
            echo -e "${GREEN}✓ Report sent!${NC}"
            read -p "Press Enter to continue..."
            show_menu
            ;;
        6)
            uninstall
            ;;
        7)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            show_menu
            ;;
    esac
}

if [ "$1" = "--send" ]; then
    send_logs
else
    show_menu
fi
EOFSCRIPT

chmod +x /root/tunnel-monitor.sh

echo "✅ Installation complete!"
echo ""
echo "📂 Installed to: /root/tunnel-monitor.sh"
echo ""
echo "🚀 Starting Tunnel Monitor..."
sleep 2

/root/tunnel-monitor.sh