#!/bin/sh
pulumi-list() { 
    echo "npm run pulumi:list";
    npm run pulumi:list;
}
pulumi-cleanup() { 
    pulumi-list;
    echo "npm run pulumi:cleanup -- --stack $1";
    npm run pulumi:cleanup -- --stack $1 ; 
}
pulumi-setup() { 
    echo "npm run pulumi:setup -- --properties ../$1"
    npm run pulumi:setup -- --properties "../$1"; 
}
pulumi-trash() {
    if [ -z "$1" ]; then
        echo "Usage: pulumi-trash <stackname>"
        return 1
    fi
    local SEARCH_NAME="$1"
    local SEARCH_DIR="./pulumi"
    
    # Check if pulumi directory exists
    if [ ! -d "$SEARCH_DIR" ]; then
        echo "Error: Directory '$SEARCH_DIR' does not exist"
        return 1
    fi
    
    echo "Searching for files and folders named: $SEARCH_NAME"
    echo "Search directory: $SEARCH_DIR"
    echo "================================================"
    
    # Find all matching files and directories
    local MATCHES=$(find "$SEARCH_DIR" -name "$SEARCH_NAME" 2>/dev/null)
    
    if [ -z "$MATCHES" ]; then
        echo "No matches found for '$SEARCH_NAME'"
        return 0
    fi
    
    # Display all matches
    echo "Found the following matches:"
    echo "$MATCHES"
    echo ""
    
    # Count matches
    local COUNT=$(echo "$MATCHES" | wc -l)
    echo "Total matches: $COUNT"
    echo ""
    
    # Ask for confirmation
    printf "Do you want to delete all these files/folders? (yes/no): "
    read CONFIRM
    
    if [ "$CONFIRM" = "yes" ]; then
        echo "Deleting..."
        echo "$MATCHES" | while read -r item; do
            if [ -e "$item" ]; then
                rm -rf "$item"
                echo "Deleted: $item"
            fi
        done
        echo "Deletion complete!"
    else
        echo "Deletion cancelled."
    fi
}
export-d1() {
    if [ -z "$1" ]; then
        echo "Usage: export-d1 <stackname>"
        return 1
    fi
    local full_name=$1
    local service_name="${full_name%%-*}"
    local config_path="pulumi/instances/$full_name/wrangler.toml"
    
    if [ ! -f "$config_path" ]; then
        echo "Error: Configuration file not found: $config_path"
        return 1
    fi
    
    echo "Exporting data for: $full_name, Database: d1_db_$service_name"
    
    npx wrangler d1 export "d1_db_$service_name" \
        --remote \
        --output="./data-${service_name}.sql" \
        --no-schema \
        --config "$config_path"
    
    if [ $? -eq 0 ]; then
        echo "Export completed: ./data-${service_name}.sql"
    else
        echo "Export failed"
        return 1
    fi
}
import-d1() {
    if [ -z "$1" ]; then
        echo "Usage: import-d1 <stackname> [sql_file]"
        return 1
    fi
    local full_name=$1
    local service_name="${full_name%%-*}"
    local config_path="pulumi/instances/$full_name/wrangler.toml"
    local sql_file="${2:-./data-${service_name}.sql}"
    
    if [ ! -f "$config_path" ]; then
        echo "Error: Configuration file not found: $config_path"
        return 1
    fi
    if [ ! -f "$sql_file" ]; then
        echo "Error: SQL file not found: $sql_file"
        return 1
    fi
    
    echo "SQL: $sql_file,Database: d1_db_$service_name , Config: $config_path"
    
    printf "This will overwrite existing data. Continue? (y/N) "
    read response
    case "$response" in
        [Yy]* ) ;;
        * ) echo "Aborted"; return 1;;
    esac
    
    npx wrangler d1 execute "d1_db_$service_name" \
        --remote \
        --file="$sql_file" \
        --config "$config_path"
    
    if [ $? -eq 0 ]; then
        echo "Import completed successfully"
    else
        echo "Import failed"
        return 1
    fi
}
gitacp() {
    git add -A && git commit -m "$*" && git push && git --no-pager diff --name-status HEAD~1
}
