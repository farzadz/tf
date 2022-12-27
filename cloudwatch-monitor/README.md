## cloudwatch monitoring

Creates an instance with cloudwatch metrics that trigger an alarm once
cpu utilisation is over 15 percent for a 10 second period. 

    terraform init
    TF_VAR_instance_public_key_name=id_rsa_default terraform apply -auto-approve

with `stress` command we can put artificial cpu load on the instance to see alarm going off:

    stress -c 1 -t 3600
