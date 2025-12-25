#!/usr/bin/env bash
# ENV Var Shame - Because your memory is as reliable as a politician's promise

# Colors for maximum shame visibility
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# The shame file - where undocumented env vars go to be judged
SHAME_FILE=".env.shame"

# Function to add shame (I mean, document an env var)
add_shame() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Usage: $0 add VAR_NAME 'Description of what this does (or should do)'${NC}"
        exit 1
    fi
    
    # Check if already shamed (documented)
    if grep -q "^$1=" "$SHAME_FILE" 2>/dev/null; then
        echo -e "${YELLOW}$1 is already feeling enough shame. Use 'update' if you want to add more.${NC}"
        exit 1
    fi
    
    echo "$1=$2" >> "$SHAME_FILE"
    echo -e "${GREEN}Added $1 to the Wall of Shame! Now your teammates won't hate you (as much).${NC}"
}

# Function to update existing shame
update_shame() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Usage: $0 update VAR_NAME 'Updated description'${NC}"
        exit 1
    fi
    
    if [ ! -f "$SHAME_FILE" ]; then
        echo -e "${RED}No shame file found. Create some shame first with 'add'.${NC}"
        exit 1
    fi
    
    # Create temp file, update or add entry
    grep -v "^$1=" "$SHAME_FILE" > "$SHAME_FILE.tmp" 2>/dev/null
    echo "$1=$2" >> "$SHAME_FILE.tmp"
    mv "$SHAME_FILE.tmp" "$SHAME_FILE"
    echo -e "${GREEN}Updated shame for $1. The guilt continues...${NC}"
}

# Function to list all shame (documented env vars)
list_shame() {
    if [ ! -f "$SHAME_FILE" ]; then
        echo -e "${YELLOW}No shame found! This is actually shameful. Add some env vars.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}=== WALL OF SHAME ===${NC}"
    echo -e "${YELLOW}Environment variables that actually have documentation:${NC}"
    echo ""
    
    while IFS='=' read -r var desc; do
        echo -e "${GREEN}$var${NC}: $desc"
    done < "$SHAME_FILE"
    
    echo -e "\n${YELLOW}Total documented vars: $(wc -l < "$SHAME_FILE")${NC}"
}

# Function to check for undocumented env vars in a file
check_shame() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 check filename.sh${NC}"
        exit 1
    fi
    
    if [ ! -f "$SHAME_FILE" ]; then
        echo -e "${RED}No shame file! Run '$0 list' to see what's missing.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Scanning $1 for undocumented shame...${NC}"
    echo ""
    
    # Extract env vars from file (simple grep for common patterns)
    grep -oE '\$\{[A-Z_][A-Z0-9_]*\}|\$[A-Z_][A-Z0-9_]*' "$1" | \
        sed 's/\${\|\$//g' | sed 's/}//g' | sort -u | \
        while read var; do
            if ! grep -q "^$var=" "$SHAME_FILE"; then
                echo -e "${RED}SHAME: $var is undocumented!${NC}"
            fi
        done
}

# Main shame dispatcher
case "$1" in
    add)
        add_shame "$2" "$3"
        ;;
    update)
        update_shame "$2" "$3"
        ;;
    list)
        list_shame
        ;;
    check)
        check_shame "$2"
        ;;
    *)
        echo -e "${YELLOW}ENV Var Shame - Because guessing env vars is not a fun game${NC}"
        echo ""
        echo "Commands:"
        echo "  add VAR_NAME 'Description'    - Add shame (documentation)"
        echo "  update VAR_NAME 'Description' - Update existing shame"
        echo "  list                         - List all documented shame"
        echo "  check filename.sh            - Check for undocumented vars"
        echo ""
        echo -e "${RED}Remember: Undocumented env vars make kittens cry.${NC}"
        ;;
esac
