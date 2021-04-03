# Day-2 operations for IBM Cloud Virtual Servers for VPC

Virtual servers for VPC is an Infrastructure-as-a-Service (IaaS) offering that gives you access to all of the benefits of IBM Cloud VPC, including network isolation, security, and flexibility. 

This playbook is designed to perform simple day-2 operations on the Virtual servers for VPC.  This includes operations, such as `start`, `stop` & `reboot` on a single Virtual server.

IBM Cloud Schematics provides powerful tools to automate your cloud infrastructure provisioning and management process, the configuration and operation of your cloud resources, and the deployment of your app workloads.  To do so, Schematics leverages open source projects, such as Terraform, Ansible, OpenShift, Operators, and Helm, and delivers these capabilities to you as a managed service. Rather than installing each open source project on your machine, and learning the API or CLI, you declare the tasks that you want to run in IBM Cloud and watch Schematics run these tasks for you. For more information about Schematics, see [About IBM Cloud Schematics](https://cloud.ibm.com/docs/schematics?topic=schematics-about-schematics).

## About this playbook

Ansible playbook for performing the following Day-2 operations on [IBM Cloud Virtual Servers on VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-advanced-virtual-servers):
* Start VSI
* Stop VSI
* Reboot VSI

You can create a Schematics Action, using these playbooks; and allow your team members to perform these Actions in a controller manner.

## Prerequisite:
- Make sure that you have the required permissions to [create an IBM Cloud Schematics action](https://cloud.ibm.com/docs/schematics?topic=schematics-access).
- A Virtual Server instance (VSI) in your IBM Cloud account

## Input variables

|Input variable|Required/ optional|Data type|Description|
|--|--|--|--|
|Instance ID or IP|Required|String|Instance ID or IP Address of the VSI|

## Running the playbook in Schematics by using UI

1. Open the [Schematics action configuration page](https://cloud.ibm.com/schematics/actions/create?name=is_actions&url=https://github.com/Cloud-Schematics/ansible-is-instance-actions).
2. Review the name for your action `startvsi`, and the resource group and region where you want to create the action. Then, click **Create**.
3. Select the `start-vsi-playbook.yml` playbook
   * You can separate action for `stopvsi` using the `stop-vsi-playbook.yml` playbook; or a `rebootvsi` using the/ reboot-vsi-playbook.yml playbook.
4. Select the **Verbosity** level to control the depth of information that will be shown when you run the playbook in Schematics.
5. Expand the **Advanced options**.
6. Enter all required input variables as key-value pairs. Then, click **Next**.
   * The `startvsi` action will operate on the `Instance ID` or `Instance IP`, specified as input.
7. Click **Check action** to verify your action details. The **Jobs** page opens automatically. You can view the results of this check by looking at the logs.
8. Click **Run action** to run instance actions for the specified VSI in your IBM Cloud account. You can monitor the progress of this action by reviewing the logs on the **Jobs** page.

## Running the playbook in Schematics by using the command line

1. Create the Schematics action. Enter all the input variable values that you retrieved earlier. When you run this command and are prompted to enter a GitHub token, enter the return key to skip this prompt.
   ```
   ibmcloud schematics action create --name startvsi --location us-south --resource-group default --template https://github.com/Cloud-Schematics/ansible-is-instance-actions --playbook-name start-vsi-playbook.yml --input "instance_ip": "<IP_Adress_of_instance>"
   ```

   Example output:
   ```
   Enter github-token>
   The given --inputs option region: is not correctly specified. Must be a variable name and value separated by an equals sign, like --inputs key=value.

   ID               us-south.ACTION.startvsi.1aa11a1a
   Name             startvsi
   Description
   Resource Group   default
   user State       live

   OK
   ```

2. Verify that your Schematics action is created and note the ID that was assigned to your action.
   ```
   ibmcloud schematics action list
   ```

3. Check your `startvsi` action, by creating a job to run ansible_playbook_check command. Replace `<action_ID>` with the action ID that you retrieved. In your CLI output, note the **ID** that was assigned to your job.
   ```
   ibmcloud schematics job create --command-object action --command-object-id <action_ID> --command-name ansible_playbook_check
   ```

   Example output:
   ```
   ID                  us-south.JOB.startvsi.fedd2fab
   Command Object      action
   Command Object ID   us-south.ACTION.startvsi.1aa11a1a
   Command Name        ansible_playbook_check
   Name                JOB.startvsi.ansible_playbook_check.2
   Resource Group      a1a12aaad12b123bbd1d12ab1a123ca1
   ```

4. Verify that your ansible_playbook_check job ran successfully by retrieving the logs.
   ```
   ibmcloud schematics job logs --id <job_ID>
   ```

5. Run your `startvsi` action, by creating another job and run the ansible_playbook_run command. Replace `<action_ID>` with your action ID.
   ```
   ibmcloud schematics job create --command-object action --command-object-id <action_ID> --command-name ansible_playbook_run
   ```

6. Verify that your job ran successfully by retrieving the logs.
   ```
   ibmcloud schematics job logs --id <job_ID>
   ```

## Verification

List all the steps to view the job{: external}, edit the settings{: external}, and observe the status of the job activities.

  - Verify that your virtual server instance is stopped.
      - From the Virtual server instances for VPC dashboard{: external}, find your virtual server instance.
      - Verify that your instance shows a Stopped status.
  - Optional: Repeat the steps in this getting started tutorial and select the start-vsi-playbook.yaml, Ansible playbook to start your virtual server instance again.


## Delete an action

1. From the [Schematics actions dashboard](https://cloud.ibm.com/schematics/actions){: external}, find the action that you want to delete.
2. From the actions menu, click **Delete**.

## Reference

Review the following links to find more information about Schematics and IBM Cloud VSI

- [IBM Cloud Schematics documentation](https://cloud.ibm.com/docs/schematics)
- [VSI instance UI](https://cloud.ibm.com/vpc-ext/compute/vs)

## Getting help

For help and support with using this template in IBM Cloud Schematics, see [Getting help and support](https://cloud.ibm.com/docs/schematics?topic=schematics-schematics-help).
