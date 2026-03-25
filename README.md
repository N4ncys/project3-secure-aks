# project3-secure-aks
Secure AKS deployment on Azure using Terraform — private cluster, Calico network policies, Kubernetes RBAC, Workload Identity, Pod Security Standards, Microsoft Defender for Containers, and a GitHub Actions CI/CD pipeline with Trivy image scanning.

# Secure AKS Deployment on Azure

A production-grade Kubernetes security project built on Azure Kubernetes Service. This project demonstrates how to design a cluster where security is enforced at every layer — from the network perimeter down to individual pod permissions.

Every control here reflects a real-world security decision, not a checkbox exercise.

---

## The Problem This Solves

Most Kubernetes deployments are insecure by default:
- Pods can talk to each other freely
- Containers run as root
- Images are pulled without scanning
- Secrets live as environment variables
- Any developer with a kubeconfig can do anything

This project builds a cluster where none of that is possible — by design.

---

## Architecture

<img src="screenshots/aks-overview-1.png" width="700"/>

The cluster runs inside a private Virtual Network with no public API server endpoint. All infrastructure is defined as code using Terraform.

<img src="screenshots/aks-overview-2.png" width="700"/>

---

## Security Layers

### 🔒 Private Cluster
The Kubernetes API server has no public IP. It cannot be reached from the internet — only from within the VNet.

---

### 🌐 Network Policies — Default deny everything

Calico network policies enforce a default-deny posture. Traffic is only permitted where explicitly needed — from the ingress controller to app pods, and from the monitoring namespace to scrape metrics.

<img src="screenshots/network-policies.png" width="700"/>

A compromised pod cannot reach any other pod. Lateral movement is blocked at the network layer.

---

### 🪪 Workload Identity — No secrets, anywhere

Pods authenticate to Azure services using federated tokens — not passwords. There is nothing to steal, rotate, or accidentally commit to source control.

---

### 👥 RBAC — Least privilege for everyone

Azure AD is the only way to authenticate to the cluster. Every person and service has only the permissions they need:

- Developers can view and debug — nothing more
- The CI/CD pipeline can deploy — but cannot touch RBAC
- Monitoring tools can read metrics — but cannot modify anything

---

### 🛡️ Pod Security Standards — Containers cannot misbehave

The app namespace enforces the `restricted` level — the strictest available. Pods that attempt to run as root, escalate privileges, or access the host network are rejected before they start.

<img src="screenshots/pod-security-standards.png" width="700"/>

---

### 📦 Private Container Registry

Images are stored in Azure Container Registry with public network access disabled. Image pulls never leave Azure's private network.

<img src="screenshots/acr-networking.png" width="700"/>

---

### 🔍 Defender for Containers — Continuous threat detection

Microsoft Defender monitors the cluster around the clock — watching for suspicious API activity, anomalous container behavior, and known attack patterns.

<img src="screenshots/defender-overview.png" width="700"/>

---

### 🚦 CI/CD Security Gate — Vulnerabilities never reach production

Every image must pass a Trivy scan before it can be pushed to the registry or deployed. The pipeline fails automatically on any critical or high severity finding.

Trivy caught a real HIGH severity vulnerability — **CVE-2024-47874** in the starlette package — and blocked the pipeline until it was remediated.

<img src="screenshots/trivy-scan-vulnerability.png" width="700"/>

The fixed image passed the scan and was deployed successfully.

<img src="screenshots/pipeline-success.png" width="700"/>

---

## Blast Radius of a Fully Compromised Pod

Even if an attacker gains code execution inside a running container:

| Attack vector | Control that blocks it |
|---|---|
| Reach other pods | Calico default-deny network policies |
| Escalate to root | Pod Security Standards — restricted |
| Access Azure resources | No credentials exist in the container |
| Persist on the node | Read-only filesystem + ephemeral disk |
| Go undetected | Defender for Containers runtime monitoring |

---

## Tech Stack

| Category | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Container platform | Azure Kubernetes Service |
| Infrastructure as Code | Terraform |
| Container registry | Azure Container Registry |
| Identity | Azure AD + Workload Identity |
| Network security | Calico network policies |
| Threat detection | Microsoft Defender for Containers |
| Image scanning | Trivy |
| CI/CD | GitHub Actions |
| App framework | FastAPI (Python) |

---

## Project Structure
```
project3-secure-aks/
├── terraform/                  # All infrastructure as code
├── k8s/
│   ├── namespaces/             # Pod Security Standards
│   ├── rbac/                   # Roles and bindings
│   ├── network-policies/       # Calico policies
│   └── workload-identity/      # Service account config
├── app/                        # FastAPI application
└── .github/workflows/          # CI/CD with Trivy scanning
```

---



## Related Projects

- [Project 1 — Azure Secure Landing Zone](https://github.com/N4ncys/azure-secure-landing-zone-terraform)
- [Project 2 — Azure Cloud-Native Web App with CI/CD](https://github.com/N4ncys/azure-webapp-cicd)
 
 
 
