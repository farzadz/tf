## cloudwatch enabled instance

Creates an ec2 instance with cloudwatch agent installed sending logs and advanced metrics to cloudwatch.

    terraform init
    TF_VAR_instance_public_key_name=id_rsa_default terraform apply -auto-approve