# edu-aws-ansible

Learn how to deploy an AWS EC2 instance and provision with Ansible.

## Requisites
You need to have installed:
   * Docker
   * [Dojo](https://github.com/kudulab/dojo)

## Usage
1. Generate ssh keypair locally:
```
key_owner="test"
ssh-keygen -q -b 2048 -t rsa -N '' -C ${key_owner} -f ./secrets/${key_owner}_id_rsa
```
