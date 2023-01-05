## AWS vpc

Creates a VPC in three availability zones, and for four web, app, db, and reserved tiers.

    terraform init
    terraform apply -auto-approve


To see the plan beforehand:

    TF_VAR_instance_public_key_name=id_rsa_default terraform plan -out=output.tfplan
    terraform show -no-color -json output.tfplan > output.json

Creates a jumpbox and a private instance (manageable by ssm session manager). The private instance(s) have internet access
using NAT Gateways present in each AZ.  