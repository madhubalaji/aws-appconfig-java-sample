#!/bin/bash
# Comprehensive Security Scanning Script
# This script runs all security scanning tools (SAST, DAST, SCA, SBOM)

set -e

# Create output directory
REPORT_DIR="target/security-reports"
mkdir -p $REPORT_DIR

echo "Starting comprehensive security scan..."

# Determine build system (Maven or Gradle)
if [ -f "pom.xml" ]; then
    BUILD_SYSTEM="maven"
    echo "Detected Maven build system"
elif [ -f "build.gradle" ]; then
    BUILD_SYSTEM="gradle"
    echo "Detected Gradle build system"
else
    echo "Error: No supported build system detected (Maven or Gradle)"
    exit 1
fi

# Run Static Application Security Testing (SAST)
echo "Running SAST scan..."
if [ "$BUILD_SYSTEM" == "maven" ]; then
    mvn spotbugs:check -DskipTests
else
    ./gradlew spotbugsMain
fi

# Run Software Composition Analysis (SCA)
echo "Running SCA scan..."
if [ "$BUILD_SYSTEM" == "maven" ]; then
    mvn dependency-check:check -DskipTests
else
    ./gradlew dependencyCheckAnalyze
fi

# Generate Software Bill of Materials (SBOM)
echo "Generating SBOM..."
if [ "$BUILD_SYSTEM" == "maven" ]; then
    mvn cyclonedx:makeAggregateBom -DskipTests
else
    ./gradlew cyclonedxBom
fi

# Check if application is running for DAST
echo "Checking if application is running for DAST scan..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "Application is running, proceeding with DAST scan..."
    
    # Run Dynamic Application Security Testing (DAST)
    echo "Running DAST scan..."
    bash ./run-zap-scan.sh http://localhost:8080
else
    echo "Warning: Application is not running on http://localhost:8080"
    echo "Skipping DAST scan. Start the application and run DAST separately:"
    echo "  bash ./run-zap-scan.sh http://localhost:8080"
fi

# Generate summary report
echo "Generating security scan summary..."
cat > "$REPORT_DIR/security-scan-summary.txt" << EOF
Security Scan Summary
====================
Date: $(date)
Repository: $(basename $(pwd))

Security Scans Performed:
- Static Application Security Testing (SAST) using SpotBugs + FindSecBugs
- Software Composition Analysis (SCA) using OWASP Dependency Check
- Software Bill of Materials (SBOM) using CycloneDX
- Dynamic Application Security Testing (DAST) using OWASP ZAP (if application was running)

Report Locations:
- SAST: $REPORT_DIR/spotbugs/
- SCA: $REPORT_DIR/dependency-check/
- SBOM: $REPORT_DIR/sbom/
- DAST: $REPORT_DIR/zap/ (if performed)

Next Steps:
1. Review the detailed reports in the directories above
2. Address any critical or high severity findings
3. Update dependencies with known vulnerabilities
4. Re-run the scan to verify fixes
EOF

echo "Security scan completed. Summary available at $REPORT_DIR/security-scan-summary.txt"
echo "Detailed reports available in $REPORT_DIR/"