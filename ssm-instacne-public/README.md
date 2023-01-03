## ssm enabled instance

Creates an Ubuntu based instance with SSM session manager enabled. The key used for managing the instance must already
exist.

    terraform init
    TF_VAR_instance_public_key_name=id_rsa_default terraform apply -auto-approve