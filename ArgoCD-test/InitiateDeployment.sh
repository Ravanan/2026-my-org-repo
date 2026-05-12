#!/bin/bash

# Script to register AWS EKS clusters with ArgoCD
# Usage: ./InitiateDeployment.sh [REGION] [CLUSTER_NAME]
# If CLUSTER_NAME is omitted, all clusters in the region will be registered



set -e

# Configuration
REGION="${1:-eu-north-1}"
CLUSTER_NAME="${2:-}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verify prerequisites
verify_prerequisites() {
    log_info "Verifying prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v argocd &> /dev/null; then
        log_error "ArgoCD CLI is not installed"
        exit 1
    fi
    
    log_info "All prerequisites met"
}

# Get AWS account ID if not set
get_account_id() {
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        log_info "Fetching AWS account ID..."
        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        log_info "AWS Account ID: $AWS_ACCOUNT_ID"
    fi
}

# List clusters in the region
list_clusters() {
    log_info "Listing EKS clusters in region: $REGION"
    aws eks list-clusters --region "$REGION" --query 'clusters[]' --output text
}

# Update kubeconfig for a cluster
update_kubeconfig() {
    local cluster=$1
    log_info "Updating kubeconfig for cluster: $cluster"
    
    if aws eks update-kubeconfig --region "$REGION" --name "$cluster" 2>/dev/null; then
        log_info "Successfully updated kubeconfig for cluster: $cluster"
        return 0
    else
        log_error "Failed to update kubeconfig for cluster: $cluster"
        return 1
    fi
}

# Register cluster with ArgoCD
register_with_argocd() {
    local cluster=$1
    local cluster_arn="arn:aws:eks:${REGION}:${AWS_ACCOUNT_ID}:cluster/${cluster}"
    
    log_info "Registering cluster with ArgoCD: $cluster"
    log_info "Cluster ARN: $cluster_arn"
    
    if argocd cluster add "$cluster_arn" --in-cluster=false 2>/dev/null; then
        log_info "Successfully registered cluster with ArgoCD: $cluster"
        return 0
    else
        log_warn "Cluster may already be registered or encountered an issue: $cluster"
        return 0
    fi
}

# Process a single cluster
process_cluster() {
    local cluster=$1
    log_info "Processing cluster: $cluster"
    
    if update_kubeconfig "$cluster"; then
        register_with_argocd "$cluster"
    else
        log_error "Skipping ArgoCD registration due to kubeconfig update failure"
        return 1
    fi
}

# Main execution
main() {
    log_info "=== ArgoCD Cluster Registration Script ==="
    log_info "Region: $REGION"
    [ -n "$CLUSTER_NAME" ] && log_info "Target Cluster: $CLUSTER_NAME" || log_info "Processing all clusters in region"
    
    verify_prerequisites
    get_account_id
    
    if [ -n "$CLUSTER_NAME" ]; then
        # Process single cluster
        log_info "Processing single cluster: $CLUSTER_NAME"
        process_cluster "$CLUSTER_NAME"
    else
        # Process all clusters
        log_info "Processing all clusters in region: $REGION"
        clusters=$(list_clusters)
        
        if [ -z "$clusters" ]; then
            log_warn "No clusters found in region: $REGION"
            exit 0
        fi
        
        for cluster in $clusters; do
            process_cluster "$cluster"
            echo ""
        done
    fi
    
    log_info "=== Cluster registration complete ==="
}

# Run main function
main

