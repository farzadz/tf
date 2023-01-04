locals {

  az_subnets = {
    "us-east-1a" = {
      "reserved" = {
        cidr_block = "10.16.0.0/20"
      }
      "db" = {
        cidr_block = "10.16.16.0/20"
      }
      "app" = {
        cidr_block = "10.16.32.0/20"
      }
      "web" = {
        cidr_block = "10.16.48.0/20"
      }
    }
    "us-east-1b" = {
      "reserved" = {
        cidr_block = "10.16.64.0/20"
      }
      "db" = {
        cidr_block = "10.16.80.0/20"
      }
      "app" = {
        cidr_block = "10.16.96.0/20"
      }
      "web" = {
        cidr_block = "10.16.112.0/20"
      }
    }
    "us-east-1c" = {
      "reserved" = {
        cidr_block = "10.16.128.0/20"
      }
      "db" = {
        cidr_block = "10.16.144.0/20"
      }
      "app" = {
        cidr_block = "10.16.160.0/20"
      }
      "web" = {
        cidr_block = "10.16.176.0/20"
      }
    }
  }

  instance = {
    ports_in  = [22]
    ports_out = [0]
  }
}