#!/bin/sh

pulumi-cleanup() { npm run pulumi:cleanup -- --stack $1 ; }

pulumi-setup() { npm run pulumi:setup -- --properties "../$1"; }

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
    
    # Confirm before destructive operation
    read -p "This will overwrite existing data. Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        return 1
    fi
    
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


# source <(curl -s https://raw.githubusercontent.com/azoth-tech/cdn-assets/refs/heads/main/scripts/tools.sh)
