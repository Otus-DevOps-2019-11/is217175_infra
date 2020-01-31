#!/usr/bin/python
import argparse
import json
import googleapiclient.discovery

PROJECT_ID="infra-123456"
ZONE="europe-west4-b"

def list_hostname():
    compute = googleapiclient.discovery.build('compute', 'v1')
    result = compute.instances().list(project=PROJECT_ID, zone=ZONE, filter="labels.ansible_group=*").execute()

    instances_list = dict()

    for inst in result['items']:
        if inst['labels']['ansible_group'] in instances_list:
            instances_list[inst['labels']['ansible_group']]['hosts'].append(inst['networkInterfaces'][0]['accessConfigs'][0]['natIP'])
        else:
            instances_list[inst['labels']['ansible_group']]={'hosts': [inst['networkInterfaces'][0]['accessConfigs'][0]['natIP']]}

    print json.dumps(instances_list)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    args = parser.parse_args()
    if args.list:
        list_hostname()
