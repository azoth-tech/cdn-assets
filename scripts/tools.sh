#!/bin/sh

pulumi-cleanup() { npm run pulumi:cleanup -- --stack $1 --auto --remove-stack; }

pulumi-setup() { npm run pulumi:setup -- --properties "../$1" --auto; }

gitacp() {
    git add -A && git commit -m "$1" && git push && git status --short
}


# source <(curl -s https://raw.githubusercontent.com/azoth-tech/cdn-assets/refs/heads/main/scripts/tools.sh)
