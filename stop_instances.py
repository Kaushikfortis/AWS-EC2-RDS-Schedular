import boto3

def stop_instances(event, context):
    ec2 = boto3.client("ec2")
    response = ec2.describe_instances(
        Filters=[
            {
                "Name": "tag:AutoOff",
                "Values": ["true"]
            }
        ]
    )
    
    instance_ids = []
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            if instance["State"]["Name"] == "running":
                instance_ids.append(instance["InstanceId"])
    
    if len(instance_ids) > 0:
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopped {len(instance_ids)} instance(s): {', '.join(instance_ids)}")
    else:
        print("No instances to stop.")
