# 🚀 Production-Ready AWS 3-Tier Architecture

### Cost-Optimized & High-Availability Infrastructure with Automated NAT Failover

This project demonstrates a **production-grade AWS 3-tier architecture** designed to solve real-world NAT limitations through automated failover.

---

## 📌 Architecture Overview

![Architecture](docs/architecture.png)

→ Detailed design decisions:
📄 https://github.com/sunhapark97-star/aws-3tier-architecture/blob/main/docs/AWS_3Tier_Architecture_ADR.pdf

---

## ❗ Problem

* NAT-less architecture caused deployment failures (package installation, CodeDeploy instability)
* A single NAT Gateway introduced a **single point of failure (SPOF)**
* Needed a solution balancing **cost, availability, and security**

---

## 💡 Solution

* Introduced a **single NAT Gateway** for stable outbound connectivity
* Minimized exposure using **VPC Interface Endpoints (SSM, S3)**
* Designed a **Lambda-based NAT failover automation**
* Implemented **CloudWatch + EventBridge monitoring**
* Enforced **zero-SSH access (SSM-only management)**

---

## 🏗️ Architecture

* 3-Tier Structure: **Public / Private App / Private DB**
* Multi-AZ deployment for high availability
* **ALB + Auto Scaling Group**
* **RDS Multi-AZ**

---

## ⚙️ Key Technical Highlights

* High Availability (HA)
* Cost Optimization
* Zero-Trust Security
* Full Automation (IaC & CI/CD)
* Secure Configuration via SSM

---

## 🔬 NAT Failover Logic

Monitoring → Detection → Lambda → Route Update → Recovery

---

## 📂 Repository Structure

```
docs/
infrastructure/
deploy/
cicd/
```

---

## 🛠️ Deployment

1. Deploy `infrastructure.yaml` via CloudFormation
2. Provide GitHub + Connection parameters
3. Validate via ALB DNS endpoint

---

## ✅ Result

* Resolved deployment instability
* Eliminated NAT SPOF
* Reduced external exposure
* Balanced cost, availability, and security
