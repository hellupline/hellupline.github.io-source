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
    | . as $instance
    | select(.State.Name == "running")
    | select((first($instance.Tags[] | select(.Key == "elasticbeanstalk:environment-name")).Value ) == "my-app")
    | select((first($instance.Tags[] | select(.Key == "env")).Value ) == "prod")
    | {
        "Name": (first($instance.Tags[]? | select(.Key == "Name")).Value // "NoName"),
        "InstanceId": $instance.InstanceId,
        "InstanceType": $instance.InstanceType,
        "State": $instance.State.Name,
        "LaunchTime": $instance.LaunchTime,
        "ImageId": $instance.ImageId,
        "AvailabilityZone": $instance.Placement.AvailabilityZone,
        "IamInstanceProfile": $instance.IamInstanceProfile.Arn,
        "SecurityGroupNames": ([$instance.SecurityGroups[].GroupName] | sort | join(",")),
        "SecurityGroupIds": ([$instance.SecurityGroups[].GroupId] | sort | join(",")),
        "VpcId": $instance.VpcId,
        "SubnetId": $instance.SubnetId,
        "PrivateIpAddress": $instance.PrivateIpAddress,
        "KeyName": $instance.KeyName,
        "Tags": ([$instance.Tags[] | "\(.Key)=\(.Value)"] | sort | join("|")),
        "StartSession": "aws ssm start-session --target \($instance.InstanceId)"
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
