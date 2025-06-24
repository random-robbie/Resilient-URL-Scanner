#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to display header
show_header() {
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║                   URL Scanner Monitor                        ║${NC}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Time: $(date)${NC}"
    echo
}

# Function to show progress bar
show_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    
    if [ $total -eq 0 ]; then
        return
    fi
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "${GREEN}Progress: ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% (%d/%d)${NC}\n" $percentage $current $total
}

# Function to estimate time remaining
estimate_time() {
    local completed=$1
    local total=$2
    local start_time=$3
    
    if [ $completed -eq 0 ]; then
        echo "Calculating..."
        return
    fi
    
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local rate=$((completed * 3600 / elapsed)) # chunks per hour
    
    if [ $rate -eq 0 ]; then
        echo "Calculating..."
        return
    fi
    
    local remaining=$((total - completed))
    local eta_hours=$((remaining / rate))
    local eta_minutes=$(((remaining * 60 / rate) % 60))
    
    if [ $eta_hours -gt 0 ]; then
        echo "${eta_hours}h ${eta_minutes}m"
    else
        echo "${eta_minutes}m"
    fi
}

# Main monitoring loop
main() {
    echo -e "${YELLOW}🔍 Starting URL Scanner Monitor...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
    echo
    
    # Try to detect scan start time from first completed chunk
    local start_time=$(date +%s)
    if [ -d "completed" ] && [ "$(ls completed/ 2>/dev/null | wc -l)" -gt 0 ]; then
        local first_completed=$(ls -t completed/ | tail -1)
        if [ ! -z "$first_completed" ]; then
            start_time=$(stat -c %Y "completed/$first_completed" 2>/dev/null || date +%s)
        fi
    fi
    
    while true; do
        clear
        show_header
        
        # Check if scan files exist
        if [ ! -f "urls.txt" ]; then
            echo -e "${RED}❌ urls.txt not found - scanner not initialized${NC}"
            echo -e "${YELLOW}Run ./scan.sh to start scanning${NC}"
            sleep 5
            continue
        fi
        
        # Get statistics
        local total_chunks=$(ls chunk_* 2>/dev/null | wc -l)
        local completed_chunks=$(ls completed/ 2>/dev/null | wc -l)
        local total_urls=$(wc -l < urls.txt 2>/dev/null || echo 0)
        local live_urls=$(wc -l < results/live_urls.txt 2>/dev/null || echo 0)
        local error_count=$(wc -l < logs/errors.log 2>/dev/null || echo 0)
        
        # Calculate rates and percentages
        local percent=0
        if [ $total_chunks -gt 0 ]; then
            percent=$((completed_chunks * 100 / total_chunks))
        fi
        
        local success_rate=0
        local processed_urls=$((completed_chunks * 5000)) # Assuming 5000 per chunk
        if [ $processed_urls -gt $total_urls ]; then
            processed_urls=$total_urls
        fi
        
        if [ $processed_urls -gt 0 ]; then
            success_rate=$((live_urls * 100 / processed_urls))
        fi
        
        # Display main statistics
        echo -e "${BOLD}📊 Scan Statistics:${NC}"
        echo "─────────────────────────────────────────────────────────────"
        
        show_progress_bar $completed_chunks $total_chunks
        echo
        
        printf "%-20s ${GREEN}%'d${NC}\n" "Total URLs:" $total_urls
        printf "%-20s ${BLUE}%'d${NC}\n" "Processed URLs:" $processed_urls
        printf "%-20s ${GREEN}%'d${NC}\n" "Live URLs:" $live_urls
        printf "%-20s ${CYAN}%d%%${NC}\n" "Success Rate:" $success_rate
        echo
        
        printf "%-20s ${BLUE}%d / %d${NC}\n" "Chunks:" $completed_chunks $total_chunks
        printf "%-20s ${CYAN}%d%%${NC}\n" "Completion:" $percent
        
        if [ $error_count -gt 0 ]; then
            printf "%-20s ${RED}%d${NC}\n" "Errors:" $error_count
        fi
        
        echo
        
        # Time estimates
        if [ $completed_chunks -gt 0 ]; then
            local eta=$(estimate_time $completed_chunks $total_chunks $start_time)
            printf "%-20s ${YELLOW}%s${NC}\n" "ETA:" "$eta"
        fi
        
        # Current chunk being processed
        if [ $total_chunks -gt 0 ] && [ $completed_chunks -lt $total_chunks ]; then
            local current_chunk=$(ls chunk_* | grep -v -f <(ls completed/ 2>/dev/null || echo) | head -1)
            if [ ! -z "$current_chunk" ]; then
                echo
                echo -e "${BOLD}🔄 Current Status:${NC}"
                echo "─────────────────────────────────────────────────────────────"
                echo -e "${YELLOW}Processing: $current_chunk${NC}"
                echo -e "${GREEN}Scanner: RUNNING${NC}"
            fi
        elif [ $completed_chunks -eq $total_chunks ] && [ $total_chunks -gt 0 ]; then
            echo
            echo -e "${BOLD}✅ Scan Status:${NC}"
            echo "─────────────────────────────────────────────────────────────"
            echo -e "${GREEN}COMPLETED${NC}"
            echo -e "${BLUE}All chunks processed successfully!${NC}"
        fi
        
        # Recent activity (last 5 completed chunks)
        if [ -d "completed" ] && [ "$(ls completed/ 2>/dev/null | wc -l)" -gt 0 ]; then
            echo
            echo -e "${BOLD}📋 Recent Activity:${NC}"
            echo "─────────────────────────────────────────────────────────────"
            ls -lt completed/ | head -6 | tail -5 | while read line; do
                local chunk_name=$(echo $line | awk '{print $9}')
                local chunk_time=$(echo $line | awk '{print $6, $7, $8}')
                if [ ! -z "$chunk_name" ]; then
                    echo -e "${GREEN}✓${NC} $chunk_name ${CYAN}($chunk_time)${NC}"
                fi
            done
        fi
        
        echo
        echo -e "${YELLOW}Refreshing in 30 seconds... (Ctrl+C to exit)${NC}"
        
        # Wait with interrupt handling
        sleep 30
    done
}

# Handle Ctrl+C gracefully
trap 'echo -e "\n${YELLOW}Monitor stopped.${NC}"; exit 0' SIGINT SIGTERM

main