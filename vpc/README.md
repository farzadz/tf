## AWS vpc

Creates a VPC in three availability zones, and for four web, app, db, and reserved tiers.

    terraform init
    terraform apply -auto-approve


To see the plan beforehand:

    TF_VAR_instance_public_key_name=id_rsa_default terraform plan -out=output.tfplan
    terraform show -no-color -json output.tfplan > output.json
