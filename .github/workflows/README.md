# GitHub Workflow Actions

This directory contains GitHub workflow actions for the AWS AppConfig Java Sample project.

## Available Workflows

### 1. Java Upgrade Workflow (`java-upgrade.yml`)

This workflow automates the process of upgrading the project from Java 1.8 to Java 17.

**Trigger:**
- Push to `wkflow-test` branch
- Pull request to `wkflow-test` branch

**Actions:**
- Checks out the code
- Sets up JDK 17
- Updates Java version in pom.xml from 1.8 to 17
- Updates Java version in build.gradle from 1.8 to 17
- Updates Dockerfile to use Java 17 instead of Java 8
- Builds the project with Maven
- Runs tests with Maven
- Builds the project with Gradle
- Creates a summary of the changes made

### 2. Q Code Transformation (`maven.yml`)

This workflow is used for Amazon Q Developer agent for Code Transformation.

**Trigger:**
- Push to branches starting with `Q-TRANSFORM-issue-`
- Pull requests

**Actions:**
- Checks out the code
- Sets up Java (version 8 or 17 depending on the branch)
- Builds the project and copies dependencies
- Uploads artifacts

## How to Use

### Java Upgrade Workflow

To use the Java upgrade workflow:

1. Create and checkout the `wkflow-test` branch:
   ```bash
   git checkout -b wkflow-test
   ```

2. Push the branch to trigger the workflow:
   ```bash
   git push origin wkflow-test
   ```

3. The workflow will automatically run and upgrade the Java version from 1.8 to 17.

4. After the workflow completes, you can create a pull request to merge the changes into your main branch.

### Q Code Transformation

This workflow is triggered automatically when pushing to branches with the prefix `Q-TRANSFORM-issue-` or when creating pull requests.