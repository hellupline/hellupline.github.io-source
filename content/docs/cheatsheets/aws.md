---
title: 'aws'

---


## run command on multiple ec2 instances

```bash
aws ssm send-command \
    --profile 'production' \
    --region 'us-east-1' \
    --timeout-seconds '600' \
    --max-concurrency '50' \
    --max-errors '0' \
    --document-name 'AWS-RunShellScript' \
    --document-version '$DEFAULT' \
    --parameters '{"workingDirectory": [""], "executionTimeout": ["3600"], "commands": ["echo hello world"]}' \
    --targets '[{"Key":"InstanceIds","Values":[]}]'
```


## run non interactive command on ec2 instance

```bash
aws ssm start-session \
    --profile 'production' \
    --region 'us-east-1' \
    --document-name 'AWS-StartNonInteractiveCommand' \
    --parameters '{"command": ["ps ax"]}' \
    --target 'INSTANCE_ID' \
```


## run interactive command on ec2 instance

```bash
aws ssm start-session \
    --profile 'production' \
    --region 'us-east-1' \
    --document-name 'AWS-StartInteractiveCommand' \
    --parameters '{"command": ["top"]}' \
    --target 'INSTANCE_ID' \
```


## port forward to ec2 instance

```bash
aws ssm start-session \
    --profile 'production' \
    --region 'us-east-1' \
    --document-name 'AWS-StartPortForwardingSession' \
    --parameters '{"portNumber": ["6443"], "localPortNumber": ["6443"]}' \
    --target 'INSTANCE_ID' \
```


## port forward to remote host using ec2 instance

```bash
aws ssm start-session \
    --profile 'production' \
    --region 'us-east-1' \
    --document-name 'AWS-StartPortForwardingSessionToRemoteHost' \
    --parameters '{"portNumber": ["6443"], "localPortNumber": ["6443"], "host": ["database.local"]}' \
    --target 'INSTANCE_ID' \
```


## port forward to remote host using ec2 instance, using unix socket

```bash
aws ssm start-session \
    --profile 'production' \
    --region 'us-east-1' \
    --document-name 'AWS-StartPortForwardingSessionToRemoteHost' \
    --parameters '{"portNumber": ["6443"], "localUnixSocket": ["./application.sock"]}' \
    --target 'INSTANCE_ID' \
```


## forward ssh session

```bash
# Host i-* mi-*
#     ProxyCommand sh -c "aws ssm start-session --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --target %h"
aws ssm start-session \
    --profile 'production' \
    --region 'us-east-1' \
    --document-name 'AWS-StartSSHSession' \
    --parameters '{"portNumber": ["%p"]}' \
    --target '%h' \
```


## describe ec2 as csv

filter by environment==production beanstalk:environment-name==my-app

```bash
for PROFILE_NAME in "staging" "production"; do
    for AWS_REGION_NAME in $(aws --profile "${PROFILE_NAME}" --output json ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
        aws \
            --output json \
            --profile "${PROFILE_NAME}" \
            --region="${AWS_REGION_NAME}" \
            ec2 describe-instances
    done
done | jq --raw-output --arg 'beanstalk-name' 'my-app' --arg 'environment' 'production' '
[
    .Reservations[].Instances[]
    | select(.State.Name == "running")
    | select((first(.Tags[] | select(.Key == "elasticbeanstalk:environment-name")).Value ) == $ARGS.named["beanstalk-name"])
    | select((first(.Tags[] | select(.Key == "environment")).Value ) == $ARGS.named["environment"])
    | {
        "Name": (first(.Tags[]? | select(.Key == "Name")).Value // "NoName"),
        "InstanceId": .InstanceId,
        "InstanceType": .InstanceType,
        "State": .State.Name,
        "LaunchTime": .LaunchTime,
        "ImageId": .ImageId,
        "AvailabilityZone": .Placement.AvailabilityZone,
        "IamInstanceProfile": .IamInstanceProfile.Arn,
        "SecurityGroupNames": ([.SecurityGroups[].GroupName] | sort | join(",")),
        "SecurityGroupIds": ([.SecurityGroups[].GroupId] | sort | join(",")),
        "VpcId": .VpcId,
        "SubnetId": .SubnetId,
        "PrivateIpAddress": .PrivateIpAddress,
        "KeyName": .KeyName,
        "Tags": ([.Tags[] | "\(.Key)=\(.Value)"] | sort | join("|")),
        "StartSession": "aws ssm start-session --target \(.InstanceId)"
    }
]
| sort_by(.ImageId, .InstanceType, .Name)
| [
    "Name",
    "InstanceId",
    # "InstanceType",
    # "State",
    # "LaunchTime",
    # "ImageId",
    # "AvailabilityZone",
    # "IamInstanceProfile",
    # "SecurityGroupNames",
    # "SecurityGroupIds",
    # "VpcId",
    # "SubnetId",
    # "PrivateIpAddress",
    # "KeyName",
    # "Tags",
    "StartSession"
] as $cols
| map(. as $row | $cols | map($row[.])) as $rows
| $cols, $rows[]
| @csv
' | column -t -s "," | less -RDS
```


## list elastic ips as csv

```bash
for PROFILE_NAME in "staging" "production"; do
    for AWS_REGION_NAME in $(aws --profile "${PROFILE_NAME}" --output json ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
        aws \
            --output json \
            --profile "${PROFILE_NAME}" \
            --region="${AWS_REGION_NAME}" \
            ec2 describe-network-interfaces \
            --filters Name=group-id,Values='sg-DUMMY'
    done
done | jq --raw-output '
[
    .NetworkInterfaces[]
    | {
        "Groups": ([.Groups[].GroupId] | sort | join(",")),
        "Status": .Status,
        "AvailabilityZone": .AvailabilityZone,
        "SubnetId": .SubnetId,
        "VpcId": .VpcId,
        "PrivateIpAddress": .PrivateIpAddress,
        "NetworkInterfaceId": .NetworkInterfaceId,
        "InstanceId": .Attachment.InstanceId,
        "AttachmentId": .Attachment.AttachmentId
    }
]
| sort_by(.Groups, .InstanceId)
| [
        "Groups",
        "Status",
        "AvailabilityZone",
        "SubnetId",
        "VpcId",
        "PrivateIpAddress",
        "NetworkInterfaceId",
        "InstanceId",
        "AttachmentId"
] as $cols
| map(. as $row | $cols | map($row[.])) as $rows
| $cols, $rows[]
| @csv
' | column -t -s "," | less -RDS
```


## list security groups usage as csv

```bash
for PROFILE_NAME in "staging" "production"; do
    for AWS_REGION_NAME in $(aws --profile "${PROFILE_NAME}" --output json ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
        aws \
            --output json \
            --profile "${PROFILE_NAME}" \
            --region="${AWS_REGION_NAME}" \
            ec2 describe-addresses
    done
done | jq --raw-output '
[
    .Addresses[]
    | {
        "Name": (first(.Tags[]? | select(.Key == "Name")).Value // "NoName"),
        "PublicIp": .PublicIp,
        "Tags": ([.Tags[] | "\(.Key)=\(.Value)"] | sort | join("|"))
    }
]
| sort_by(.Name)
| [
    "Name",
    "PublicIp"
    # "Tags"
] as $cols
| map(. as $row | $cols | map($row[.])) as $rows
| $cols, $rows[]
| @csv
' | column -t -s "," | less -RDS
```


## describe rds

filter by cacertificate version

```bash
for PROFILE_NAME in "staging" "production"; do
    for AWS_REGION_NAME in $(aws --profile "${PROFILE_NAME}" --output json ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
        aws --profile="${PROFILE_NAME}" --region="${AWS_REGION_NAME}" rds describe-db-instances |
            jq --raw-output '.DBInstances[] | select(.CACertificateIdentifier == "rds-ca-2019" or .PendingModifiedValues.CACertificateIdentifier == "rds-ca-2019" | not) | .DBInstanceIdentifier' |
            while read INSTANCE_NAME; do
                echo "aws --profile='${PROFILE_NAME}' --region='${AWS_REGION_NAME}' rds modify-db-instance --db-instance-identifier '${INSTANCE_NAME}' --ca-certificate-identifier rds-ca-2019 --no-certificate-rotation-restart"
                # echo ${PROFILE_NAME}, ${AWS_REGION_NAME}, ${INSTANCE_NAME}
            done
    done
done
```


## compare 2 rds db cluster parameter group

```python
import boto3
from pprint import pprint

rds = boto3.client('rds')
paginator = rds.get_paginator('describe_db_cluster_parameters')
a = set(
    (parameter['ParameterName'], parameter.get('ParameterValue'))
    for page in paginator.paginate(DBClusterParameterGroupName='parameter-group-a')
    for parameter in page['Parameters']
)
b = set(
    (parameter['ParameterName'], parameter.get('ParameterValue'))
    for page in paginator.paginate(DBClusterParameterGroupName='parameter-group-b')
    for parameter in page['Parameters']
)
pprint(a - b)
pprint(b - a)
```


## compare 2 rds db parameter group

```python
import boto3
from pprint import pprint

rds = boto3.client('rds')
paginator = rds.get_paginator('describe_db_parameters')
a = set(
    (parameter['ParameterName'], parameter.get('ParameterValue'))
    for page in paginator.paginate(DBParameterGroupName='parameter-group-a')
    for parameter in page['Parameters']
)
b = set(
    (parameter['ParameterName'], parameter.get('ParameterValue'))
    for page in paginator.paginate(DBParameterGroupName='parameter-group-b')
    for parameter in page['Parameters']
)
pprint(a - b)
pprint(b - a)
```


## cost usage

```bash
# Start=$(date "+%Y-%m-01" -d "-1 Month"),End=$(date --date="$(date +'%Y-%m-01') - 1 second" -I)
# Start=$(date "+%Y-%m-01"),End=$(date --date="$(date +'%Y-%m-01') + 1 month  - 1 second" -I)
# Type=DIMENSION,Key=LINKED_ACCOUNT Type=DIMENSION,Key=SERVICE Type=TAG,Key=owner
aws ce get-cost-and-usage \
    --time-period "Start=$(date "+%Y-%m-01" -d "-1 Month"),End=$(date --date="$(date +'%Y-%m-01') - 1 second" -I)" \
    --granularity MONTHLY \
    --metrics USAGE_QUANTITY BLENDED_COST  \
    --group-by Type=TAG,Key=owner Type=DIMENSION,Key=SERVICE \
| jq --raw-output '
. as $root
| [ $root.DimensionValueAttributes[] | { "Key": .Value, "Value": .Attributes } ] | from_entries as $dimension_attributes
| [
    $root.ResultsByTime[].Groups[]
    | select((.Metrics.UsageQuantity.Amount | tonumber) > 0)
    | select((.Metrics.BlendedCost.Amount | tonumber) > 0)
    | {
        # "Account": $dimension_attributes[.Keys[0]].description,
        "tag$owner": .Keys[0],
        "Service": .Keys[1],
        "BlendedCostAmmount": .Metrics.BlendedCost.Amount | tonumber,
        "BlendedCostUnit": .Metrics.BlendedCost.Unit,
        "UsageQuantityAmmount": .Metrics.UsageQuantity.Amount | tonumber,
    }
]
| sort_by(.["tag$owner"], .BlendedCostAmmount, .Name)
| reverse
| [
    # "Account",
    "tag$owner",
    "Service",
    "BlendedCostAmmount",
    "BlendedCostUnit",
    "UsageQuantityAmmount"
] as $cols
| map(. as $row | $cols | map($row[.] | tostring)) as $rows
| $cols, $rows[]
| @csv
' | column -t -s ","
```


## query dynamodb

```bash
aws dynamodb scan \
      --table-name TABLE_NAME \
      --projection-expression "#email, #login" \
      --filter-expression "#domain = :value" \
      --expression-attribute-names '{"#domain": "domain", "#email": "email", "#login": "login"}' \
      --expression-attribute-values '{":value": {"S": "github"}}' |
    jq --raw-output '
        (
                [["email", "login"]] +
                [.Items[] | [.email.S, .login.S]]
        )[] | @csv
    ' > export.csv
```


## cloudformation ec2 init

```bash
/opt/aws/bin/cfn-init --verbose --region us-east-1 --stack STACK_NAME --resource STACK_RESOURCE --configsets default
```
