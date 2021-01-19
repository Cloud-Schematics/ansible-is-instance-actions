# VSI-start/stop/reboot

Ansible playbook to start, stop and reboot a VSI on IBM Cloud. This playbook demos how IBM Cloud VSI API can be be used to start, stop and reboot via ansible.

## Prerequisite:
- A VSI instance in running/stopped state.
- VSI instance-id or instance-ip
- IAM token with access to the instance(optional if running this action from same account as of VSI).

## Automate the playbook execution with schematics action 

Create schematics action to run Ansible playbook in IBM Cloud. In the example we will use schematics actions API to illustrate the execution of playbook.

To Start/Stop/Reboot VSI instance(To change action just change the playbook name({start/stop/reboot}-vsi-playbook.yml)):
 
- Create a Schematics action:

 Make POST request {url}/v2/actions using following payload:
 
 Url: https://schematics.cloud.ibm.com
 
 Pass header: Authorization: {bearer token}
 
  ```
  {
      "name": "Start-Stop-VSI",
      "description": "This Action can be used to Start or Stop the VSI",
      "location": "us-east",
      "resource_group": "Default",
       "source": {
           "source_type" : "git",
           "git" : {
                "git_repo_url": "https://github.ibm.com/akjain25/ic-vsi-actions"
           }
      },
      "command_parameter": "stop-vsi-playbook.yml",
      "tags": [
        "string"
      ],
      "source_readme_url": "stringtype",
      "source_type": "GitHub",
      "inputs": [
        {
          "name": "instance_ip",
          "value": <pass your vsi ip here>,
          "metadata": {
            "type": "string",
            "default_value": <any default value>
          }
        }
      ]
  }
  ```

- Create a job that will run the playbook:

  Make POST request to {url}/v2/jobs using following payload:
  
  Url: https://schematics.cloud.ibm.com
  
  Pass header: Authorization: {bearer token}
 
    ```
    {
      "command_object": "action",
      "command_object_id": {action-id from the response of above request},
      "command_name": "ansible_playbook_run",
      "command_parameter": "stop-vsi-playbook.yml"
    }
    ```

- Check the progress by getting ansible logs:

  Make GET request to {url}/v2/jobs/{job-id}/logs.
 
  Url: https://schematics.cloud.ibm.com
  
  Pass header: Authorization: {bearer token}

## Execute the playbook using Schematics UI

Steps:

- Login to cloud.ibm.com
- From top left open the Navigation menu
- Tap Schematics
- Again in left side navigation menu, tap on Actions
- Click on Create action button(right side of screen)
- Give action name, resource-group, location and hit create button
- In github url box pass: https://github.com/Cloud-Schematics/ic-vsi-actions
- Hit retrieve playbooks button
- Selete start/stop/reboot playbook from Playbooks dropdown
- Click advanced options
- Add instance_ip as key and ip address of VSI in value
- Tap next button
- Once the action come in normal state, Hit run action button.
- You can check job logs in Jobs page

Help:

VSI instance UI: https://cloud.ibm.com/vpc-ext/compute/vs
