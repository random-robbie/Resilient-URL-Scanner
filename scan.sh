#!/bin/bash

echo "=== Resilient URL Scanner Started at $(date) ==="

# Configuration
CHUNK_SIZE=5000
THREADS=80
TIMEOUT=8
RETRIES=1

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if URLs file exists
if [ ! -f "urls.txt" ]; then
    echo -e "${RED}❌ Error: urls.txt file not found${NC}"
    echo "Please create urls.txt with your target URLs (one per line)"
    echo "Example:"
    echo "  echo 'example.com' > urls.txt"
    echo "  echo 'test.com' >> urls.txt"
    exit 1
fi

# Check if URLs file is empty
if [ ! -s "urls.txt" ]; then
    echo -e "${RED}❌ Error: urls.txt is empty${NC}"
    echo "Please add URLs to scan (one per line)"
    exit 1
fi

# Check if httpx is installed
if ! command -v httpx &> /dev/null; then
    if [ -f "/root/go/bin/httpx" ]; then
        export PATH=$PATH:/root/go/bin
        echo -e "${YELLOW}⚠️  Added /root/go/bin to PATH${NC}"
    else
        echo -e "${RED}❌ Error: httpx not found${NC}"
        echo "Please install httpx first:"
        echo "  go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
        echo "Or run: ./setup.sh"
        exit 1
    fi
fi

echo -e "${BLUE}🔧 Configuration:${NC}"
echo "   Chunk Size: $CHUNK_SIZE URLs"
echo "   Threads: $THREADS"
echo "   Timeout: ${TIMEOUT}s"
echo "   Retries: $RETRIES"
echo

# Create directories
mkdir -p completed results logs

# Split URLs into chunks (only if not already done)
if [ ! -f chunk_00000 ]; then
    echo -e "${BLUE}📦 Splitting URLs into chunks of $CHUNK_SIZE...${NC}"
    split -l $CHUNK_SIZE urls.txt chunk_ --numeric-suffixes=0 --suffix-length=5
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error: Failed to split URLs${NC}"
        exit 1
    fi
    
    CHUNK_COUNT=$(ls chunk_* | wc -l)
    echo -e "${GREEN}✅ Created $CHUNK_COUNT chunks${NC}"
else
    echo -e "${YELLOW}⚠️  Using existing URL chunks${NC}"
fi

# Count total chunks and URLs
TOTAL_CHUNKS=$(ls chunk_* 2>/dev/null | wc -l)
COMPLETED_CHUNKS=$(ls completed/ 2>/dev/null | wc -l)
TOTAL_URLS=$(wc -l < urls.txt)

if [ $TOTAL_CHUNKS -eq 0 ]; then
    echo -e "${RED}❌ Error: No chunks found${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Scan Overview:${NC}"
echo "   Total URLs: $TOTAL_URLS"
echo "   Total Chunks: $TOTAL_CHUNKS"
echo "   Completed: $COMPLETED_CHUNKS"
echo "   Remaining: $((TOTAL_CHUNKS - COMPLETED_CHUNKS))"
echo

if [ $COMPLETED_CHUNKS -eq $TOTAL_CHUNKS ]; then
    echo -e "${GREEN}🎉 All chunks already completed!${NC}"
    LIVE_COUNT=$(wc -l < "results/live_urls.txt" 2>/dev/null || echo 0)
    echo "Total live URLs found: $LIVE_COUNT"
    echo "Results saved in: results/live_urls.txt"
    exit 0
fi

echo -e "${GREEN}🚀 Starting scan with $THREADS threads, ${TIMEOUT}s timeout${NC}"
echo "Results will be saved to results/live_urls.txt"
echo "Press Ctrl+C to stop (progress will be saved)"
echo "---"

# Function to handle cleanup on exit
cleanup() {
    echo
    echo -e "${YELLOW}🛑 Scan interrupted at $(date)${NC}"
    echo "Progress has been saved. Run the script again to resume."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Process each chunk
for chunk in chunk_*; do
    # Skip if already completed
    if [ -f "completed/$chunk" ]; then
        continue
    fi
    
    echo -e "${BLUE}[$(date '+%H:%M:%S')] Processing $chunk...${NC}"
    
    # Count URLs in chunk
    URL_COUNT=$(wc -l < "$chunk")
    
    # Scan the chunk
    httpx -l "$chunk" \
          -threads $THREADS \
          -timeout $TIMEOUT \
          -retries $RETRIES \
          -status-code \
          -silent \
          -no-color >> "results/live_urls.txt" 2>> "logs/errors.log"
    
    SCAN_EXIT_CODE=$?
    
    # Check if scan completed successfully
    if [ $SCAN_EXIT_CODE -eq 0 ]; then
        # Mark as completed
        touch "completed/$chunk"
        
        # Update progress
        COMPLETED_CHUNKS=$((COMPLETED_CHUNKS + 1))
        PERCENT=$((COMPLETED_CHUNKS * 100 / TOTAL_CHUNKS))
        
        echo -e "${GREEN}[$(date '+%H:%M:%S')] ✅ Completed $chunk ($URL_COUNT URLs)${NC}"
        echo -e "${BLUE}   Progress: $COMPLETED_CHUNKS/$TOTAL_CHUNKS ($PERCENT%)${NC}"
        
        # Show live results count
        LIVE_COUNT=$(wc -l < "results/live_urls.txt" 2>/dev/null || echo 0)
        echo -e "${GREEN}   Live URLs found so far: $LIVE_COUNT${NC}"
        echo "---"
    else
        echo -e "${RED}[$(date '+%H:%M:%S')] ❌ Error processing $chunk (exit code: $SCAN_EXIT_CODE)${NC}"
        echo "Check logs/errors.log for details"
        echo "You can retry by running the script again"
        break
    fi
done

echo
echo -e "${GREEN}🎉 Scan completed at $(date)${NC}"
echo "Final results in results/live_urls.txt"

FINAL_LIVE_COUNT=$(wc -l < "results/live_urls.txt" 2>/dev/null || echo 0)
echo "Total live URLs found: $FINAL_LIVE_COUNT"

# Calculate success rate
if [ $TOTAL_URLS -gt 0 ]; then
    SUCCESS_RATE=$((FINAL_LIVE_COUNT * 100 / TOTAL_URLS))
    echo "Success rate: $SUCCESS_RATE%"
fi

echo
echo -e "${BLUE}📁 Output files:${NC}"
echo "   Live URLs: results/live_urls.txt"
echo "   Error logs: logs/errors.log"
echo "   Completed chunks: completed/"
echo
echo -e "${GREEN}Happy hunting! 🎯${NC}"