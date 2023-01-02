locals {

  az_subnets = {
    "us-east-1a" = {
      "reserved" = {
        cidr_block = "10.16.0.0/20"
        public     = false
      }
      "db" = {
        cidr_block = "10.16.16.0/20"
        public     = false
      }
      "app" = {
        cidr_block = "10.16.32.0/20"
        public     = false
      }
      "web" = {
        cidr_block = "10.16.48.0/20"
        public     = true
      }
    }
    "us-east-1b" = {
      "reserved" = {
        cidr_block = "10.16.64.0/20"
        public     = false
      }
      "db" = {
        cidr_block = "10.16.80.0/20"
        public     = false
      }
      "app" = {
        cidr_block = "10.16.96.0/20"
        public     = false
      }
      "web" = {
        cidr_block = "10.16.112.0/20"
        public     = true
      }
    }
    "us-east-1c" = {
      "reserved" = {
        cidr_block = "10.16.128.0/20"
        public     = false
      }
      "db" = {
        cidr_block = "10.16.144.0/20"
        public     = false
      }
      "app" = {
        cidr_block = "10.16.160.0/20"
        public     = false
      }
      "web" = {
        cidr_block = "10.16.176.0/20"
        public     = true
      }
    }
  }



  subnets = flatten([
  for az_name, params in local.az_subnets :[
  for subnet_type, subnet_params in params :{
    az_name     = az_name
    subnet_type = subnet_type
    cidr_block  = subnet_params.cidr_block
    public      = subnet_params.public
  }
  ]
  ])


  instance = {
    ports_in  = [22]
    ports_out = [0]
  }
}