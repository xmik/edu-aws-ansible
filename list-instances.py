import boto3

session = boto3.session.Session()
current_region = session.region_name
print("Current region is: " + current_region)

ec2_resource = boto3.resource('ec2')
for instance in ec2_resource.instances.all():
    print(instance.id, instance.state)
