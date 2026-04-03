# 🚀 Production-Ready AWS 3-Tier Architecture
### Cost-Optimized & High-Availability Infrastructure with Automated NAT Failover

This project demonstrates a **production-grade AWS 3-tier architecture**
that solves real-world NAT limitations through automated failover design.

---

## ❗ Problem

- NAT-less architecture caused deployment failures (package installation, CodeDeploy instability)
- Introducing a single NAT Gateway created a single point of failure (SPOF)
- Needed a solution that balances cost, availability, and security

---

## 💡 Solution

- Introduced a **single NAT Gateway** for stable outbound connectivity
- Minimized internet exposure using **VPC Interface Endpoints (SSM, S3)**
- Designed a **Lambda-based NAT failover automation**
- Implemented **CloudWatch + EventBridge monitoring system**
- Secured infrastructure with **zero SSH access (SSM-based management only)**

---

## 🏗️ Architecture

- 3-Tier Structure: **Public / Private App / Private DB**
- Multi-AZ deployment for high availability
- Application Load Balancer + Auto Scaling Group
- RDS Multi-AZ (high availability database)

---

## ⚙️ Key Technical Highlights

- High Availability (HA)
- Cost Optimization
- Zero-Trust Security
- Full Automation (IaC & CI/CD)
- Secure Configuration via SSM

---

## 🔬 Deep Dive: NAT Failover Logic

Monitoring → Detection → Lambda Failover → Route Update → Recovery

---

## 📂 Repository Structure

infrastructure/
deploy/
buildspec.yml
appspec.yml

---

## 🛠️ Deployment

1. Deploy infrastructure.yaml via CloudFormation
2. Provide GitHub and Connection parameters
3. Validate using ALB DNS

---

## ✅ Result

- Resolved deployment instability
- Eliminated NAT SPOF
- Reduced exposure
- Balanced cost, availability, security

---

## 📄 Documentation

https://github.com/sunhapark97-star/aws-3tier-architecture/blob/main/AWS_Infrastructure_Architecture_Report.pdf
