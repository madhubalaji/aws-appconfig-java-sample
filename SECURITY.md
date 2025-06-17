# Security Scanning Guide

This repository includes comprehensive security scanning capabilities, including Static Application Security Testing (SAST), Dynamic Application Security Testing (DAST), Software Composition Analysis (SCA), and Software Bill of Materials (SBOM) generation.

## Quick Start

To run all security scans at once:

```bash
# Make scripts executable
chmod +x run-security-scan.sh run-zap-scan.sh

# Run all security scans
./run-security-scan.sh
```

## Available Security Tools

### 1. Static Application Security Testing (SAST)

SAST analyzes source code for security vulnerabilities without executing the application.

**Tools Used:**
- SpotBugs with FindSecBugs plugin

**How to Run:**

Maven:
```bash
mvn spotbugs:check
```

Gradle:
```bash
./gradlew spotbugsMain
```

**Reports Location:** `target/security-reports/spotbugs/`

### 2. Dynamic Application Security Testing (DAST)

DAST analyzes the running application by simulating attacks against it.

**Tools Used:**
- OWASP ZAP (Zed Attack Proxy)

**Prerequisites:**
- Application must be running (e.g., on http://localhost:8080)
- Docker installed (preferred) or ZAP installed locally

**How to Run:**
```bash
./run-zap-scan.sh http://localhost:8080
```

**Reports Location:** `target/security-reports/zap/`

### 3. Software Composition Analysis (SCA)

SCA identifies open source components and their known vulnerabilities.

**Tools Used:**
- OWASP Dependency Check

**How to Run:**

Maven:
```bash
mvn dependency-check:check
```

Gradle:
```bash
./gradlew dependencyCheckAnalyze
```

**Reports Location:** `target/security-reports/dependency-check/`

### 4. Software Bill of Materials (SBOM)

SBOM provides a detailed inventory of all components used in the application.

**Tools Used:**
- CycloneDX Maven/Gradle Plugin

**How to Run:**

Maven:
```bash
mvn cyclonedx:makeAggregateBom
```

Gradle:
```bash
./gradlew cyclonedxBom
```

**Reports Location:** `target/security-reports/sbom/`

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly scan

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '8'
          distribution: 'adopt'
          
      - name: Run Security Scans
        run: |
          chmod +x run-security-scan.sh
          ./run-security-scan.sh
          
      - name: Upload Security Reports
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: target/security-reports/
```

### Jenkins Pipeline Example

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'chmod +x run-security-scan.sh'
                sh './run-security-scan.sh'
            }
        }
        
        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'target/security-reports/**/*', fingerprint: true
            }
        }
    }
    
    post {
        always {
            // Publish HTML reports
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target/security-reports/dependency-check',
                reportFiles: 'dependency-check-report.html',
                reportName: 'Dependency Check Report'
            ])
            
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'target/security-reports/spotbugs',
                reportFiles: 'spotbugsXml.html',
                reportName: 'SpotBugs Report'
            ])
        }
    }
}
```

## Customization

### Suppressing False Positives

For OWASP Dependency Check, edit `dependency-check-suppressions.xml`:

```xml
<suppress>
    <notes>Reason for suppression</notes>
    <cve>CVE-XXXX-XXXX</cve>
</suppress>
```

For SpotBugs, edit `spotbugs-security-exclude.xml` to exclude specific patterns.

## Troubleshooting

### Common Issues

1. **ZAP scan fails:**
   - Ensure the application is running
   - Check Docker is installed or ZAP is in PATH
   
2. **Build fails due to vulnerabilities:**
   - Review the reports to identify critical issues
   - Update vulnerable dependencies
   - Add suppressions for false positives

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CycloneDX SBOM Specification](https://cyclonedx.org/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
- [SpotBugs](https://spotbugs.github.io/)
- [FindSecBugs](https://find-sec-bugs.github.io/)
- [OWASP ZAP](https://www.zaproxy.org/)