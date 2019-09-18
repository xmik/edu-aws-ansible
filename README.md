# edu-aws-ansible

Learn how to deploy an AWS EC2 instance and provision with Ansible.

## Requisites
You need to have installed:
   * Docker
   * [Dojo](https://github.com/kudulab/dojo)
   * a file: `~/.aws/credentials`

## Usage
1. Generate ssh keypair locally:
```
key_owner="test"
ssh-keygen -q -b 2048 -t rsa -N '' -C ${key_owner} -f ./secrets/${key_owner}_id_rsa
chmod 700 secrets/${key_owner}_id_rsa
```

2. Deploy a EC2 instance, using docker-terraform-dojo
```
$ dojo -c Dojofile.terraform
cd terraform/
terraform init
terraform get
terraform plan -out=tf.plan
terraform apply tf.plan
terraform output ec2_public_ip > ../ip.txt
```
The last Terraform resource logs into the EC2 instance using SSH, so afterwards you should be able to SSH login yourself:
```
$ ssh -i secrets/test_id_rsa ubuntu@$(cat ip.txt)
```
3. Additionally you can use docker-aws-dojo to check if the EC2 instance is running:
```
$ dojo -c Dojofile.aws
# using the boto3 python library
$ python ./list-instances.py
Current region is: eu-west-1
('i-03b88bd67b04bacf4', {u'Code': 16, u'Name': 'running'})
# using awscli
$ aws ec2 describe-instances --filters "Name=tag:Name,Values=ec2-ansible-test"
{
    "Reservations": [
        {
            "Instances": [
                {
# ... removed the rest of the output for brevity
```

4. Provision that EC2 instance, using docker-ansible-dojo
```
$ dojo -c Dojofile.ansible
ansible-playbook -i ansible/hosts.yaml ansible/playbook.yaml -v -e "variable_ip=$(cat ip.txt)"
```

now you can test that some contents was written to a dummy file in an EC2 instance:
```
$ ssh -i secrets/test_id_rsa ubuntu@$(cat ip.txt) "cat /tmp/hello"
Warning: Permanently added '52.209.144.23' (ECDSA) to the list of known hosts.
hi
```

## What could be improved?

* instead of using a default ubuntu AMI from AWS we could have a custom AMI, which has e.g. docker installed, so that the Ansible provisioning step would be faster
* the Ansible provisioning step could be invoked from terraform using `provisioner "local-exec"` like here: https://getintodevops.com/blog/using-ansible-with-terraform . We could achieve it by using a custom ubuntu AMI image with Docker and Dojo preinstalled and run docker-ansible-dojo there.
