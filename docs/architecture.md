# Architecture

```mermaid
flowchart TB
    user((Users)) --> alb

    subgraph aws[AWS account - ap-south-1]
        subgraph vpc[VPC 10.x.0.0/16]
            subgraph pub[Public subnets - 1 per AZ]
                alb[Application Load Balancer<br/>created by AWS LB Controller]
                nat[NAT Gateway<br/>1 shared in dev / 1 per AZ in prod]
            end

            subgraph priv[Private subnets - 1 per AZ]
                subgraph eks[EKS cluster]
                    cp[Managed control plane<br/>secrets encrypted with KMS]
                    ng1[Managed node group<br/>on-demand - system]
                    ng2[Managed node group<br/>Spot - stateless]
                    addons[Add-ons: VPC CNI, CoreDNS, kube-proxy,<br/>EBS CSI, metrics-server,<br/>AWS LB Controller, Cluster Autoscaler]
                end
            end

            s3ep[S3 gateway endpoint]
        end

        ecr[(ECR<br/>scan on push, immutable tags)]
        iam[IAM OIDC provider<br/>IRSA roles per add-on]
        cw[(CloudWatch Logs<br/>control plane + VPC flow logs)]
        state[(S3 + DynamoDB<br/>Terraform state and locking)]
    end

    alb --> ng1 & ng2
    ng1 & ng2 --> nat --> internet((Internet))
    ng1 & ng2 -. image layers .-> s3ep
    ng1 & ng2 --> ecr
    addons -. assume role .-> iam
    cp --> cw

    gha[GitHub Actions] -- OIDC, no static keys --> iam
    gha --> state
```

## Design decisions

| Decision | Why |
|---|---|
| Nodes only in private subnets | Nothing on a node is reachable from the internet; traffic enters through the ALB. |
| One NAT in dev, one per AZ in prod | Dev saves roughly $30-60/month per avoided NAT gateway; prod survives the loss of an AZ. |
| S3 gateway endpoint | Free. ECR stores image layers in S3, so pulls skip the NAT and its per-GB charge. |
| EKS access entries (`API` mode) | Replaces the fragile `aws-auth` ConfigMap; access is managed through AWS APIs and Terraform. |
| IRSA per add-on | Each controller gets only the AWS permissions it needs, scoped to its own service account. |
| KMS envelope encryption for Secrets | Kubernetes Secrets are encrypted at rest with a key you control and can rotate. |
| IMDSv2 required, hop limit 2 | Blocks SSRF-style credential theft from the instance metadata service. |
| VPC CNI prefix delegation | Many more pods per node, so fewer, better-utilised nodes. |
| Spot node group with a taint | Only workloads that tolerate interruption land on Spot, for up to ~70% compute savings. |
| `desired_size` ignored by Terraform | Cluster Autoscaler owns node counts at runtime; Terraform won't fight it. |
| Pinned provider and Helm chart versions | Upgrades are deliberate and tested in dev first. |
