#!/bin/bash

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Default values
SKIP_GIT=false
BUILD_ONLY=false

# Parse command line arguments
while [ $# -gt 0 ]; do
    case $1 in
        --skip-git)
            SKIP_GIT=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --skip-git    Skip git fetch and checkout, only build and restart"
            echo "  --build-only  Only build, don't restart services"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Git operations
if [ "$SKIP_GIT" = "false" ]; then
    echo -e "${YELLOW}Fetching and checking out latest code...${NC}"
    git fetch origin dev/staging
    git checkout origin/dev/staging
else
    echo -e "${YELLOW}Skipping git operations...${NC}"
fi

# Build main application
echo -e "${YELLOW}Building main application...${NC}"
go build cmd/app/main.go

# Restart main service
if [ "$BUILD_ONLY" = "false" ]; then
    echo -e "${YELLOW}Restarting main service...${NC}"
    sudo service service_name restart
else
    echo -e "${YELLOW}Skipping service restart...${NC}"
fi

# Build command application
echo -e "${YELLOW}Building command application...${NC}"
go build -o commands cmd/command/main.go

# Restart command service
if [ "$BUILD_ONLY" = "false" ]; then
    echo -e "${YELLOW}Restarting command service...${NC}"
    sudo service service_name-cmd restart
else
    echo -e "${YELLOW}Skipping command service restart...${NC}"
fi

echo -e "${GREEN}Deployment completed!${NC}"