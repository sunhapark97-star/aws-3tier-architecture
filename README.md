# 🚀 Production-Ready AWS 3-Tier Architecture

**Cost-Optimized & High-Availability Infrastructure with Automated NAT Failover**

This project demonstrates a highly available, secure, and cost-efficient AWS 3-tier infrastructure, fully automated via Infrastructure as Code (IaC) and CI/CD pipelines.

---

## 🏗️ Architecture Diagram

---

## 🌟 Key Technical Highlights

- **High Availability (HA):** A robust 3-tier architecture deployed across 2 Availability Zones (AZs) using ALB, ASG, and RDS Multi-AZ.
- **Cost-Optimization with Lambda Failover:** Optimized for cost by using a single NAT Gateway, with a custom **Lambda-based automation** that creates a failover NAT in real-time during outages.
- **Zero-Trust Security:** No SSH ports are exposed; all instance management is performed securely through **AWS SSM Interface Endpoints**.
- **Full Automation (IaC & CI/CD):** Entire infrastructure defined in CloudFormation, with automated deployments triggered by GitHub commits via **CodePipeline, CodeBuild, and CodeDeploy**.
- **Automated Env Injection:** Sensitive credentials and configurations are securely retrieved from **SSM Parameter Store** during deployment.

---

## 📂 Repository Structure

- `infrastructure/` : Contains `infrastructure.yaml` which defines the entire VPC, IAM, RDS, and CI/CD resources.
- `deploy/scripts/` : Shell scripts for environment injection, service validation, and deployment hooks.
- `deploy/nginx/` & `deploy/systemd/` : Configuration files for Nginx (reverse proxy) and Gunicorn (WSGI).
- `buildspec.yml` & `appspec.yml` : Definition files for AWS CodeBuild and CodeDeploy stages.

---

## 🛠️ Deployment & Operations

### 1. Prerequisites

- Create a GitHub connection in **AWS CodeStar Connections** and note the ARN.
- Prepare your GitHub repository with this source code.

### 2. Launch Infrastructure

- Deploy the `infrastructure/infrastructure.yaml` stack via AWS CloudFormation.
- Provide parameters for your GitHub ID, Repo name, and Connection ARN.

### 3. Validation

- Once the pipeline succeeds, access the ALB DNS URL.
- The `/healthz` endpoint provides an immediate `200 OK` status for health checks.

---

## 🔬 Deep Dive: The NAT Failover Logic

To minimize hourly NAT Gateway costs, this architecture defaults to a **Single NAT** configuration. However, to prevent a single point of failure:

1. **Monitoring:** CloudWatch Alarms track NAT packet drops and port allocation errors.
2. **Detection:** EventBridge detects the alarm state change and triggers the **Failover Lambda**.
3. **Healing:** The Lambda creates an EIP and a secondary NAT in the redundant AZ, then updates the private route tables instantly.
4. **Rollback:** Once the primary NAT recovers, the system restores the original routes and deletes the temporary failover resources.

---

## 📝 Troubleshooting & Logs

- **CodeDeploy Logs:** `sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log`
- **Service Health:** `systemctl status nginx` or `systemctl status gunicorn-app`
- **Local Test:** `curl -i http://127.0.0.1/healthz`
