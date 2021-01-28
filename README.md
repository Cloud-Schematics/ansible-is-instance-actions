# IBM Cloud Virtual Servers for VPC

Ansible playbook for [IBM Cloud Virtual Servers on VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-advanced-virtual-servers) to perform the following operations:
* Start VM
* Stop VM
* Reboot VM

You can create a Schematics Action, using these playbooks; and allow your team members to perform these Actions in a controller manner.  
Follow the instruction to onboard these Ansible playbooks as Schematics Action, and run them as Schematics Jobs. 

## Prerequisite:
- A Virtual Server instance (VSI) in your IBM Cloud account

## Inputs:
- Instance ID or IP Address of the VSI
- IAM token, with access to the VSI (optional, if the VSI is in running in the same account as Schematics Action).

## Run the ansible playbook using Schematics API

In this example, we will use the Schematics Actions API to create a new `Start VSI` Action, using the `start-vsi-playbook.yml` playbook.  
Further, use the Schematics Job API to run the newly created `Start VSI` action.

- Create a Schematics Action: "Start-VSI"

  Use the `POST {url}/v2/actions` with the following payload:
 
  Url: https://schematics.cloud.ibm.com
 
  Pass header: Authorization: {bearer token}
 
  ```
  {
      "name": "Start-VSI",
      "description": "This Action can be used to Start the VSI",
      "location": "us-east",
      "resource_group": "Default",
       "source": {
           "source_type" : "git",
           "git" : {
                "git_repo_url": "https://github.com/Cloud-Schematics/ansible-is-instance-actions"
           }
      },
      "command_parameter": "start-vsi-playbook.yml",
      "tags": [
        "string"
      ],
      "source_readme_url": "https://github.com/Cloud-Schematics/ansible-is-instance-actions/blob/master/README.md",
      "source_type": "GitHub",
      "inputs": [
        {
          "name": "instance_ip",
          "value": "<your vsi ip here>",
        }
      ]
  }
  ```
  In the request payload, pass the IP address of the VSI that must be started as a value in the "inputs".  
  The response payload will include the Action ID for the newly created Schematics Action definition.

- Create & run the Schematics Job for "Start-VSI"

  Use the `POST {url}/v2/jobs` with the following payload:
  
  Url: https://schematics.cloud.ibm.com
  
  Pass header: Authorization: {bearer token}
 
    ```
    {
      "command_object": "action",
      "command_object_id": "<action-id for Start-VSI>",
      "command_name": "ansible_playbook_run",
      "command_parameter": "start-vsi-playbook.yml"
    }
    ```

- Check the Schematics Job status and the ansible logs:

  Use the `GET {url}/v2/jobs/{job-id}/logs`.  
  With the header - Authorization: {bearer token}

## Run the ansible playbook using Schematics UI

In this example, we will use the Schematics Actions UI to create a new `Start VSI` Action, using the `start-vsi-playbook.yml` playbook.  
Further, use the Schematics Job API to run the newly created `Start VSI` action.

Steps:

- Open https://cloud.ibm.com/schematics/actions to view the list of Schematics Actions.
- Click `Create action` button to create a new Schematics Action definition
- In the Create action page - section 1, provide the following inputs, to create a `Start-VSI` action in `Draft` state.
  * Action name : Start-VSI
  * Resource group: default
  * Location : us-east
- In the Create action page - section 2, provide the following input
  * Github url : https://github.com/Cloud-Schematics/ansible-is-instance-actions
  * Click on `Retrieve playbooks` button
  * Select `start-vsi-playbook.yml` from the dropdown
- In the Create action page - Advanced options, provide the following input
  * Add `instance_ip` as key and `<ip address of VSI>` as value
- Press the `Next` button, and wait for the newly created `Start-VSI` action to move to `Normal` state.
- Once the `Start-VSI` action is in `Normal` state, you can run press the `Run action` button to initiate the Schematics Job
  * You can view the job status and the job logs (or Ansible logs) in the Jobs page of the `Start-VSI` Schematics Action
  * Jobs page of the `Start-VSI` Schematics Action will list all the historical jobs that was executed using this Action definition

## Reference:

VSI instance UI: https://cloud.ibm.com/vpc-ext/compute/vs
