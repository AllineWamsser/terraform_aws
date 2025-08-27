## Grocery Infrastructure on AWS (Terraform)

This project provisions a simple cloud infrastructure on *AWS* using *Terraform*.  
It was built as part of my learning journey in *Cloud & DevOps* 🚀  

# Architecture

The infrastructure includes:
•⁠  ⁠*EC2 Instance* running inside a public subnet
•⁠  ⁠*Application Load Balancer (ALB)* in front of the EC2
•⁠  ⁠*Target Group* registering the EC2 instance
•⁠  ⁠*Security Groups* for ALB and EC2 (allowing HTTP/SSH traffic)
•⁠  ⁠*S3 Bucket* for object storage
•⁠  ⁠*Key Pair* for SSH access

# Diagram

```mermaid
flowchart TD
    User[User / Browser] -->|HTTP:80| ALB[Application Load Balancer]
    ALB --> TG[Target Group]
    TG --> EC2[EC2 Instance]

    S3[(S3 Bucket)]

    subgraph SecurityGroups [Security Groups]
        SG1[ALB SG: allow HTTP 80]
        SG2[EC2 SG: allow SSH 22, HTTP 80]
    end

    ALB --> SG1
    EC2 --> SG2
