#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}🔍 Resilient URL Scanner - Quick Status${NC}"
echo "=========================================="

# Check if scanner is initialized
if [ ! -f "urls.txt" ]; then
    echo -e "${RED}❌ Scanner not initialized${NC}"
    echo "Run ./setup.sh to get started"
    exit 1
fi

# Get basic counts
TOTAL_URLS=$(wc -l < urls.txt 2>/dev/null || echo 0)
TOTAL_CHUNKS=$(ls chunk_* 2>/dev/null | wc -l)
COMPLETED_CHUNKS=$(ls completed/ 2>/dev/null | wc -l)
LIVE_URLS=$(wc -l < results/live_urls.txt 2>/dev/null || echo 0)
ERROR_COUNT=$(wc -l < logs/errors.log 2>/dev/null || echo 0)

# Calculate progress
if [ $TOTAL_CHUNKS -gt 0 ]; then
    PERCENT=$((COMPLETED_CHUNKS * 100 / TOTAL_CHUNKS))
else
    PERCENT=0
fi

# Calculate success rate
PROCESSED_URLS=$((COMPLETED_CHUNKS * 5000)) # Assuming 5000 per chunk
if [ $PROCESSED_URLS -gt $TOTAL_URLS ]; then
    PROCESSED_URLS=$TOTAL_URLS
fi

if [ $PROCESSED_URLS -gt 0 ]; then
    SUCCESS_RATE=$((LIVE_URLS * 100 / PROCESSED_URLS))
else
    SUCCESS_RATE=0
fi

# Display status
echo -e "${BOLD}📊 Overview:${NC}"
printf "%-20s %'d\n" "Total URLs:" $TOTAL_URLS
printf "%-20s %'d\n" "Processed URLs:" $PROCESSED_URLS
printf "%-20s ${GREEN}%'d${NC}\n" "Live URLs:" $LIVE_URLS
printf "%-20s ${CYAN}%d%%${NC}\n" "Success Rate:" $SUCCESS_RATE
echo

echo -e "${BOLD}📈 Progress:${NC}"
printf "%-20s %d / %d\n" "Chunks:" $COMPLETED_CHUNKS $TOTAL_CHUNKS
printf "%-20s ${BLUE}%d%%${NC}\n" "Completion:" $PERCENT

if [ $ERROR_COUNT -gt 0 ]; then
    printf "%-20s ${RED}%d${NC}\n" "Errors:" $ERROR_COUNT
fi

echo

# Status determination
if [ $TOTAL_CHUNKS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Status: NOT STARTED${NC}"
    echo "Run ./scan.sh to begin scanning"
elif [ $COMPLETED_CHUNKS -eq $TOTAL_CHUNKS ]; then
    echo -e "${GREEN}✅ Status: COMPLETED${NC}"
    echo "All chunks have been processed"
else
    # Check if scanner is currently running
    if pgrep -f "httpx" > /dev/null || pgrep -f "scan.sh" > /dev/null; then
        echo -e "${GREEN}🔄 Status: RUNNING${NC}"
        
        # Show current chunk
        CURRENT_CHUNK=$(ls chunk_* | grep -v -f <(ls completed/ 2>/dev/null || echo) | head -1)
        if [ ! -z "$CURRENT_CHUNK" ]; then
            echo "Currently processing: $CURRENT_CHUNK"
        fi
    else
        echo -e "${YELLOW}⏸️  Status: PAUSED/STOPPED${NC}"
        echo "Run ./scan.sh to resume scanning"
    fi
fi

echo

# Quick commands
echo -e "${BOLD}🚀 Quick Commands:${NC}"
echo "Start/Resume:  ./scan.sh"
echo "Monitor:       ./monitor.sh"
echo "View Results:  cat results/live_urls.txt"
echo "View Errors:   cat logs/errors.log"

# Show recent activity if available
if [ -d "completed" ] && [ "$(ls completed/ 2>/dev/null | wc -l)" -gt 0 ]; then
    echo
    echo -e "${BOLD}📋 Last Completed:${NC}"
    LAST_CHUNK=$(ls -t completed/ | head -1)
    if [ ! -z "$LAST_CHUNK" ]; then
        LAST_TIME=$(stat -c %y "completed/$LAST_CHUNK" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
        echo "$LAST_CHUNK ($LAST_TIME)"
    fi
fi

echo