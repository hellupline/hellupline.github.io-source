---
title: aws
weight: 120
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## describe ec2, get name, ami, private ip, id, ssm start-session

```bash
aws --profile=default --region=us-east-1 ec2 describe-instances | jq --raw-output '
[
    .Reservations[].Instances[]
    | select(.State.Name == "running")
    | . as $instance
    | [
        first($instance.Tags[] | select(.Key == "Name")).Value // "NoName",
        $instance.ImageId,
        $instance.PrivateIpAddress,
        $instance.InstanceId,
        "aws ssm start-session --target \($instance.InstanceId)"
    ]
]
| sort_by(.[0], .[1], .[2])[]
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

## list instance and private ips, filter by beanstalk environment

```bash
aws --profile=default --region=us-east-1 ec2 describe-instances
         --filter "Name=tag:elasticbeanstalk:environment-name,Values=my-app" | \
   jq --raw-output '
      (
         [["instance-id", "private-ip"]] +
         [.Reservations[].Instances[] | [.InstanceId, .PrivateIpAddress]]
      )[] | @csv'
```


## list elastic ips

```bash
aws --profile=default --region=us-east-1 ec2 describe-addresses \
         --public-ips \
         --filter "Name=public-ip,Values=[10.0.0.1]" |
   jq --raw-output '
      (
         [["public-ip"]] +
         [.Addresses[] | [.PublicIp]]
      )[] | @csv
   '
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
