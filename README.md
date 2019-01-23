# formation-aws
formation aws 21/01/2019


## install terraform

```
$ terraform/install.sh
```

## prepare our AMI

This script create an AMI

```
$ cd ../sugarCRM
$ terraform init
$ ./ami.sh
```

## deploy

```
$ cd ../terraform
$ terraform apply
```