# edu-aws-ansible

Learn how to deploy an AWS EC2 instance and provision with Ansible.

## Requisites
In order to perform this setup you need to:

* have [Docker](https://www.docker.com/) installed
* have [Dojo](https://github.com/kudulab/dojo) installed
* configure AWS credentials. This can be done in many ways, e.g. in this file: `~/.aws/credentials` or by environment variables. Read [this](https://www.terraform.io/docs/providers/aws/index.html).
* git clone this github repository and change your current working directory to it

## Usage
1. Generate ssh keypair locally:
```
$ key_owner="test"
$ mkdir -p secrets
$ ssh-keygen -q -b 2048 -t rsa -N '' -C ${key_owner} -f ./secrets/${key_owner}_id_rsa
$ chmod 600 secrets/${key_owner}_id_rsa
```

2. Deploy an EC2 instance and a non default VPC, using [docker-terraform-dojo](https://github.com/kudulab/docker-terraform-dojo):
```
$ ./tasks deploy
```

  You can run this command many times and from the 2nd time on Terraform should return such output:
  ```
  No changes. Infrastructure is up-to-date.
  ```
  Which means that the infrastructure is not going to be changed.

  **Warning:** the EC2 instance type used here is not covered by the AWS free tier,
   but a smaller type was chosen. If you want to use free tier, change the type to: `t2.micro`.

  The last-invoked Terraform resource logs into the EC2 instance using SSH, so afterwards you should be able to SSH login yourself:
  ```
  $ ssh -i secrets/test_id_rsa ubuntu@$(cat ip.txt)
  ```

3. Additionally you can use [docker-aws-dojo](https://github.com/kudulab/docker-aws-dojo) to check if the EC2 instance is running:
```
$ dojo -c Dojofile.aws
# using boto3 python library
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

4. Provision that EC2 instance, using [docker-ansible-dojo](https://github.com/kudulab/docker-ansible-dojo)
```
$ ./tasks provision
```

  now you can test that some contents was written to a dummy file in an EC2 instance (which means that Ansible provisioning was successful):
  ```
  $ ssh -i secrets/test_id_rsa ubuntu@$(cat ip.txt) "cat /tmp/hello"
  Warning: Permanently added '<some-aws-public-ip>' (ECDSA) to the list of known hosts.
  hi
  ```

5. Clean up (remove the AWS resources):
```
$ ./tasks destroy
```

  This command can also be run many times and nothing should be done from the 2nd time on, because all the Terraform resources should be destroyed already.

## What could be improved?

* if this was a production use case: instead of using a default ubuntu AMI,
  we could use a custom AMI, which has e.g. Docker installed, so that we could
  other servers faster
* the Ansible provisioning step could be invoked from terraform using
`provisioner "remote-exec"`. We could achieve it
by using a custom ubuntu AMI image with Docker and Dojo preinstalled and run
docker-ansible-dojo there. This is not an improvement, just an alternative.
* instead of manually generating an SSH keypair, for test deployments, we could
 use Terraform resource: `tls_private_key`, like here: https://stackoverflow.com/a/49792833/4457564


## License

Copyright 2019 Ewa Czechowska

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
