# Running day-2 operations on IBM Cloud VPC Gen 2 virtual servers with IBM Cloud Schematics

[Virtual Servers for VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-advanced-virtual-servers) is an Infrastructure-as-a-Service (IaaS) offering that gives you access to all of the benefits of IBM Cloud VPC, including network isolation, security, and flexibility.

This playbook is designed to perform simple day-2 operations on the Virtual Servers for VPC instance, such as to start, stop, and reboot the instance.

IBM Cloud Schematics provides powerful tools to automate your cloud infrastructure provisioning and management process, the configuration and operation of your cloud resources, and the deployment of your app workloads.  To do so, Schematics leverages open source projects, such as Terraform, Ansible, OpenShift, Operators, and Helm, and delivers these capabilities to you as a managed service. Rather than installing each open source project on your machine, and learning the API or CLI, you declare the tasks that you want to run in IBM Cloud and watch Schematics run these tasks for you. For more information about Schematics, see [About IBM Cloud Schematics](https://cloud.ibm.com/docs/schematics?topic=schematics-about-schematics).

## About this playbook

To run this playbook, you must have a Virtual Private Cloud (VPC) for generation 2 compute and a Virtual Server instance (VSI) that you want to start, stop, or reboot. When you run this playbook, Schematics securely connects to the target VSI by using the SSH key that you configured when you created the VSI.

To perform an operation on your VSI, choose one of the following playbooks:
- **start-vsi-playbook.yml** to start your VSI
- **stop-vsi-playbook.yml** to stop your VSI
- **reboot-vsi-playbook.yml** to reboot your VSI

If you want to run multiple operations on your VSI, such as starting and stopping the VSI, you must create separate actions in IBM Cloud Schematics.

## Prerequisites

To run this playbook, complete the following tasks:
- Make sure that you have the required permissions to [create an IBM Cloud Schematics action](https://cloud.ibm.com/docs/schematics?topic=schematics-access).
- Make sure that you have the required permissions to [create and work with IBM Cloud VPC Generation 2 infrastructure components](https://cloud.ibm.com/docs/vpc?topic=vpc-iam-getting-started).
- [Create and upload an SSH key to the VPC Gen 2 dashboard](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). This SSH key is used to access your virtual server in your VPC. Make sure that you upload the SSH key to the same region where you want to create your VSIs.
- [Create a Virtual Private Cloud and a Virtual Server in that VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-getting-started). Make sure to configure your virtual server with the SSH key that you uploaded.

## Input variables

You must retrieve the following values to run the playbook in IBM Cloud Schematics.

|Input variable|Required/ optional|Data type|Description|
|--|--|--|--|
|`instance_id`|Required if `instance_ip` is not provided|String|Enter the ID of the Virtual Server instance that you want to start, stop, or reboot. You can retrieve the ID from the [VPC Gen 2 Virtual Server dashboard](https://cloud.ibm.com/vpc-ext/compute/vs).|
|`instance_ip`|Required if `instance_id` is not provided|String|Enter the public or private IP address that was assigned to the Virtual Server instance that you want to start, stop, or reboot. You can retrieve the IP address from the [VPC Gen 2 Virtual Server dashboard](https://cloud.ibm.com/vpc-ext/compute/vs). |
|`instance_ip_list`|Optional `instance_ip` and `instance_ip` fields are not required if this field is provided|List|Enter a list of public or private IP addresses separated by comma that you want to start, stop, or reboot. E.g 10.240.64.4,10.240.64.5|

## Running the playbook in Schematics by using the UI

1. From the [Schematics action configuration page](https://cloud.ibm.com/schematics/actions/create?name=ansible-is-instance-actions&url=https://github.com/Cloud-Schematics/ansible-is-instance-actions).
2. Enter a name for your action, for example, `Start_VSIaction`, resource group, and the region where you want to create the action. Then, click **Create** to view the **Details** section.
3. In the **Ansible playbook** section, click **Edit icon** enter `https://github.com/Cloud-Schematics/ansible-is-instance-actions` in the **GitHub or GitLab repository URL** field.
4. Click **Retrieve playbooks**.
5. Select the **`start-vsi-playbook.yaml`** playbook. Refer to [floating IP address](https://cloud.ibm.com/docs/vpc?topic=vpc-using-instance-vnics#editing-network-interfaces) of the VSI to set your input variable.
6. Expand the **Advanced options**.
7. In the **Define your variables** section, enter `instance_ip` as the **key** and the floating IP address of your Virtual Servers for VPC as the **value**.

   <img src="/images/startvsiui.png" alt="Schematics action input variables overview" width="350" style="width: 350px; border-style: none"/>

8. Click **Save**.
9. Click **Check action** to verify your action details. The **Jobs** page opens automatically and you can view the results of this check by looking at the logs.
10. Click **Run action** to start the Virtual Servers for VPC. You can monitor the progress of this action by reviewing the logs on the **Jobs** page.
11. Verify that your Virtual Servers for VPC started.
    1. From the [Virtual Servers for VPC dashboard](https://cloud.ibm.com/vpc-ext/compute/vs), find your Virtual Servers for VPC.
    2. Verify that your instance shows a `Started` status.

    ![Schematics action output](/images/action_output.png)
    
12. Optional: Repeat the steps to create another Schematics action, and select the **`stop-vsi-playbook.yaml`** Ansible playbook to stop your Virtual Servers for VPC. again.

## Running the playbook in Schematics by using the command line

1. Create the Schematics action. Enter all the input variable values that you retrieved earlier. When you run this command and are prompted to enter a GitHub token, enter the return key to skip this prompt. The following example uses the `stop-vsi-playbook.yml` playbook to stop a virtual server instance with the 172.4.5.0 IP address.
   ```
   ibmcloud schematics action create --name start-vsi --location us-south --resource-group default --template https://github.com/Cloud-Schematics/ansible-is-instance-actions --playbook-name stop-vsi-playbook.yml --input instance_ip=172.4.5.0
   ```

2. Verify that your Schematics action is created and note the ID that was assigned to your action.
   ```
   ibmcloud schematics action list
   ```

3. Create a job to run a check for your action. Replace `<action_ID>` with the action ID that you retrieved. In your CLI output, note the **ID** that was assigned to your job.
   ```
   ibmcloud schematics job run --command-object action --command-object-id <action_ID> --command-name ansible_playbook_check
   ```

   Example output:
   ```
   ID                  us-south.JOB.stopvsi.fedd2fab
   Command Object      action
   Command Object ID   us-south.ACTION.stopvsi.1aa11a1a
   Command Name        ansible_playbook_check
   Name                JOB.stopvsi.ansible_playbook_check.2
   Resource Group      a1a12aaad12b123bbd1d12ab1a123ca1
   ```

4. Verify that your job ran successfully by retrieving the logs.
   ```
   ibmcloud schematics job logs --id <job_ID>
   ```

5. Create another job to run the action. Replace `<action_ID>` with your action ID.
   ```
   ibmcloud schematics job run --command-object action --command-object-id <action_ID> --command-name ansible_playbook_run
   ```

6. Verify that your job ran successfully by retrieving the logs.
   ```
   ibmcloud schematics job logs --id <job_ID>
   ```

7. Optional: Repeat the steps and create another action that uses the `start-vsi-playbook.yml` playbook to start your virtual server again.

## Verification

1. Open the [VPC Virtual Server dashboard](https://cloud.ibm.com/vpc-ext/compute/vs).
2. Find the virtual server instance that you started, stopped, or rebooted, and verify that the status of the instance changed.

## Deleting the action

1. From the [Schematics actions dashboard](https://cloud.ibm.com/schematics/actions), find the action that you want to delete.
2. From the actions menu, click **Delete**.

## Reference

Review the following links to find more information about Schematics and IBM Cloud VPC Virtual Servers:

- [IBM Cloud Schematics documentation](https://cloud.ibm.com/docs/schematics)
- [IBM Cloud VPC documentation](https://cloud.ibm.com/docs/vpc?topic=vpc-getting-started)

## Getting help

For help and support with using this template in IBM Cloud Schematics, see [Getting help and support](https://cloud.ibm.com/docs/schematics?topic=schematics-schematics-help).
