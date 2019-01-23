#!/bin/bash

# need terraform init avant

terraform apply

terraform destroy -target=aws_instance.sugarCRM-builder
