#!/bin/sh

pulumi-cleanup() { npm run pulumi:cleanup -- --stack $1 --auto --remove-stack; }

pulumi-setup() { npm run pulumi:setup -- --properties "../$1" --auto; }

 pulumi-trash{
  rm -rf .instances
  rm -rf infrastructure/.pulumi; rm infrastructure/Pulumi.*.yaml
}



gitacp() {
    git add -A && git commit -m "$*" && git push && git --no-pager diff --name-status HEAD~1
}


# source <(curl -s https://raw.githubusercontent.com/azoth-tech/cdn-assets/refs/heads/main/scripts/tools.sh)
