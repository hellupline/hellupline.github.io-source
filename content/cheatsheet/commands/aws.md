---
title: aws
weight: 120
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## describe ec2 as csv, filter by env==prod beanstalk:environment-name==my-app

```bash
aws ec2 describe-instances | jq --raw-output '
[
    .Reservations[].Instances[]
    | select(.State.Name == "running")
    | select((first(.Tags[] | select(.Key == "elasticbeanstalk:environment-name")).Value ) == "my-app")        
    | select((first(.Tags[] | select(.Key == "env")).Value ) == "prod")
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
    "InstanceType",
    # "State",
    "LaunchTime",
    "ImageId",
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
' | column -t -s ","
```


## list security groups usage

```bash
for AWS_REGION_NAME in $(aws --output json ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
    aws --output json --region="${AWS_REGION_NAME}" ec2 describe-network-interfaces --filters Name=group-id,Values='sg-DUMMY'
done | jq --raw-output --slurp '
[
    .[].NetworkInterfaces[]
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
' | column -t -s ","

```


## list elastic ips

```bash
aws ec2 describe-addresses | jq --raw-output '
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
' | column -t -s ","
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


## describe rds, filter by cacertificate version

```bash
for PROFILE_NAME in "staging" "production"; do
    aws --profile="${PROFILE_NAME}" ec2 describe-regions |
        jq --raw-output '.Regions[].RegionName' |
        while read REGION_NAME; do
            aws --profile="${PROFILE_NAME}" --region="${REGION_NAME}" rds describe-db-instances |
                jq --raw-output '.DBInstances[] | select(.CACertificateIdentifier == "rds-ca-2019" or .PendingModifiedValues.CACertificateIdentifier == "rds-ca-2019" | not) | .DBInstanceIdentifier' |
                while read INSTANCE_NAME; do
                    echo "aws --profile='${PROFILE_NAME}' --region='${REGION_NAME}' rds modify-db-instance --db-instance-identifier '${INSTANCE_NAME}' --ca-certificate-identifier rds-ca-2019 --no-certificate-rotation-restart"
                    # echo ${PROFILE_NAME}, ${REGION_NAME}, ${INSTANCE_NAME}
                done
        done
done
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
/opt/aws/bin/cfn-init --verbose --region us-east-1 --stack STACK_NAME --resource STACK_RESOURCE --configsets default && echo success
```


## export beanstalk settings to terraforn

```bash
aws --profile=default --region=us-east-1 \
        elasticbeanstalk describe-configuration-settings \
        --application-name 'my-app' \
        --environment-name 'my-app-development' |
    jq --raw-output '.ConfigurationSettings[].OptionSettings[] | select(.Value) | "settings {\n  namespace = \"\(.Namespace)\"\n  name = \"\(.OptionName)\"\n  value = \"\(.Value)\"\n}"'
```
