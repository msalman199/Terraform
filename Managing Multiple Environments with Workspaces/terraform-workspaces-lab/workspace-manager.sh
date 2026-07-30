#!/bin/bash

# Workspace management script
case "$1" in
    "list")
        echo "Available workspaces:"
        terraform workspace list
        ;;
    "current")
        echo "Current workspace: $(terraform workspace show)"
        ;;
    "switch")
        if [ -z "$2" ]; then
            echo "Usage: $0 switch <workspace-name>"
            exit 1
        fi
        terraform workspace select "$2"
        echo "Switched to workspace: $(terraform workspace show)"
        ;;
    "status")
        echo "=== Workspace Status ==="
        echo "Current workspace: $(terraform workspace show)"
        echo "Resources in current workspace:"
        terraform state list
        ;;
    "deploy")
        if [ -z "$2" ]; then
            echo "Usage: $0 deploy <environment>"
            exit 1
        fi
        workspace="$2"
        terraform workspace select "$workspace"
        terraform apply -var-file="${workspace}.tfvars" -auto-approve
        ;;
    *)
        echo "Usage: $0 {list|current|switch|status|deploy} [workspace-name]"
        echo "Commands:"
        echo "  list     - List all workspaces"
        echo "  current  - Show current workspace"
        echo "  switch   - Switch to specified workspace"
        echo "  status   - Show current workspace status"
        echo "  deploy   - Deploy to specified environment"
        ;;
esac
