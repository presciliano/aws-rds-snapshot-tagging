#/bin/bash
for PROFILE_NAME in "staging" "production"; do
    aws --profile="${PROFILE_NAME}" --region us-east-1 ec2 describe-regions |
        jq --raw-output '.Regions[].RegionName' |
        while read REGION_NAME; do
            aws --profile="${PROFILE_NAME}" --region="${REGION_NAME}" rds describe-db-instances |
                jq --raw-output '.DBInstances[] | select(.CopyTagsToSnapshot == false) | .DBInstanceIdentifier' |
                while read INSTANCE_NAME; do
                    echo "aws --profile='${PROFILE_NAME}' --region='${REGION_NAME}' rds modify-db-instance --db-instance-identifier '${INSTANCE_NAME}' --copy-tags-to-snapshot --apply-immediately"
                    #echo ${PROFILE_NAME}, ${REGION_NAME}, ${INSTANCE_NAME}
                done
            aws --profile="${PROFILE_NAME}" --region="${REGION_NAME}" rds describe-db-clusters |
                jq --raw-output '.DBClusters[] | select(.CopyTagsToSnapshot == false) | .DBClusterIdentifier' |
                while read CLUSTER_NAME; do
                    echo "aws --profile='${PROFILE_NAME}' --region='${REGION_NAME}' rds modify-db-cluster --db-cluster-identifier '${CLUSTER_NAME}' --copy-tags-to-snapshot --apply-immediately"
                    #echo ${PROFILE_NAME}, ${REGION_NAME}, ${CLUSTER_NAME}
                done
        done
done
