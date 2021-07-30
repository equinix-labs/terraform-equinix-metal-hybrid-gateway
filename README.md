# Hybrid-Nodes
![](https://img.shields.io/badge/Stability-Experimental-red.svg)

# Hybrid nodes deployment on Equinix Platform

This Terraform script provides hybrid nodes deployments on Equinix Metal platform where one node is deployed as the front-end node in layer-3/layer-2 Hybrid bonded mode and the reset of the nodes are deployed as the backend nodes in layer-2 bonded mode.

For information regarding Layer-3/2 hybrid bonded mode, please see the following document - https://metal.equinix.com/developers/docs/layer2-networking/hybrid-bonded-mode/. For the Layer-2 bonded mode, please see the following Equinix Metal document - https://metal.equinix.com/developers/docs/layer2-networking/layer2-mode/#pure-layer-2-modes

The frontend node can access the internet directly while the backend nodes can only access the internet via frontend. There are two VLANs in this configuration. The first VLAN is shared by the frontend and the backend nodes while the second VLAN is only shared by the backend nodes.
The first VLAN is hardcoded using 192.168.100.0/24 for IP assignments with frontend being assigned with 192.168.100.1. The second VLAN is hardcoded using 169.254.254.0/24 for IP assigments among the backend nodes.

After the nodes are sucessfully deployed, the following behaviors are expected:
1. The frontend node can ping internet, for example, $ping 1.1.1.1
2. The frontend node can ping the backend node via 192.168.100.x, for example, $ping 192.168.100.2
3. A backend node can ping internet, for example, $ping 1.1.1.1
4. A backend node can ping the frontend via 192.168.100.1
5. A backend node can ping another backend node via 169.254.254.x, for example, $ping 169.254.254.2

This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

## Install Terraform

Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path.

Here is an example for **macOS**:

```bash
curl -LO https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_darwin_amd64.zip
unzip terraform_0.12.18_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```

## Download this project

To download this project, run the following command:

```bash
git clone https://github.com/packet-labs/hybrid-nodes.git
cd hybrid-nodes
```

## Initialize Terraform

Terraform uses modules to deploy infrastructure. In order to initialize the modules your simply run: `terraform init`. This should download modules into a hidden directory `.terraform`

## Modify your variables

You will need to set the following variables at a minimum and there are a lot more you may wish to modify in `vars.tf`

```
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
auth_token = "your Equinx Metal API token"
project_id = "your Equinix Metal project you want to deploy the nodes to"
metro = "Equinx metal metro, for example da (Dallas)
plan = "Equinx metal sever plan"
operating_system = "ubuntu_20_04"
backend_count = number of backend nodes, for example 5
```
#### Note - Currently only Ubuntu is supported; Only Gen# 3 server plans support hybrid bonded mode.

## Deploy terraform template

```bash
terraform apply --auto-approve
```

Once this is complete you should get output similar to this:

```console
Apply complete! Resources: 31 added, 0 changed, 0 destroyed.

Outputs:

backend_nodes = [
  "backend-1",
  "backend-2",
  "backend-3",
  "backend-4",
  "backend-5",
]
frontend_IP = "145.40.80.131"
frontend_name = "front-end"
metrovlan_ids = [
  1002,
  1003,
]
```
