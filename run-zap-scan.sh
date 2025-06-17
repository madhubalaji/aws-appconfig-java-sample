#!/bin/bash
# OWASP ZAP Dynamic Application Security Testing (DAST) Script
# This script runs OWASP ZAP to perform dynamic security testing on a running application

set -e

# Default target URL if not provided
TARGET_URL=${1:-"http://localhost:8080"}
REPORT_DIR="target/security-reports/zap"
ZAP_OPTIONS="-config api.disablekey=true"

echo "Starting OWASP ZAP DAST scan against $TARGET_URL"

# Create report directory
mkdir -p $REPORT_DIR

# Check if Docker is available (preferred method)
if command -v docker &> /dev/null; then
    echo "Running ZAP scan using Docker..."
    
    # Run ZAP baseline scan using Docker
    docker run --rm -v "$(pwd)/$REPORT_DIR:/zap/wrk" owasp/zap2docker-stable:latest zap-baseline.py \
        -t "$TARGET_URL" \
        -g gen.conf \
        -r zap-report.html \
        -J zap-report.json \
        -w zap-report.md \
        -a
    
    echo "ZAP scan completed. Reports available in $REPORT_DIR"
    
else
    # Check if ZAP is installed locally
    if command -v zap.sh &> /dev/null; then
        echo "Running ZAP scan using local installation..."
        
        # Start ZAP daemon
        zap.sh -daemon $ZAP_OPTIONS -port 8090 &
        ZAP_PID=$!
        
        # Wait for ZAP to initialize
        echo "Waiting for ZAP to initialize..."
        sleep 10
        
        # Run ZAP spider
        echo "Running ZAP spider..."
        zap-cli --zap-url http://localhost:8090 spider "$TARGET_URL"
        
        # Run ZAP active scan
        echo "Running ZAP active scan..."
        zap-cli --zap-url http://localhost:8090 active-scan "$TARGET_URL"
        
        # Generate reports
        echo "Generating reports..."
        zap-cli --zap-url http://localhost:8090 report -o "$REPORT_DIR/zap-report.html" -f html
        zap-cli --zap-url http://localhost:8090 report -o "$REPORT_DIR/zap-report.xml" -f xml
        
        # Stop ZAP
        kill $ZAP_PID
        
        echo "ZAP scan completed. Reports available in $REPORT_DIR"
    else
        echo "Error: OWASP ZAP is not installed. Please install ZAP or use Docker."
        echo "For Docker installation: https://docs.docker.com/get-docker/"
        echo "For ZAP installation: https://www.zaproxy.org/download/"
        exit 1
    fi
fi

# Check for high severity findings
if grep -q "High" "$REPORT_DIR/zap-report.html"; then
    echo "WARNING: High severity vulnerabilities found!"
    # Uncomment the line below to fail the build on high severity findings
    # exit 1
fi

echo "DAST scan completed successfully"