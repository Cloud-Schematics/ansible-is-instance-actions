#!/usr/bin/python

from ibm_vpc import VpcV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_cloud_sdk_core.authenticators import BearerTokenAuthenticator
from ibm_cloud_sdk_core import ApiException
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.basic import env_fallback


REQUIRED_PARAMETERS = [
    ('instance_id', 'str'),
    ('action_type', 'str'),
    #('ibmcloud_api_key', 'str'),
]

module_args = dict(
    instance_id=dict(
        required=True,
        type='str'),
    action_type=dict(
        required=True,
        type='str'),
    ibmcloud_api_key=dict(
        type='str',
        no_log=True,
        fallback=(env_fallback, ['IC_API_KEY']),
        required=False),
    env_bearer_token=dict(
        type='str',
        no_log=True,
        fallback=(env_fallback, ['IC_IAM_TOKEN']),
        required=False),
    bearer_token=dict(
        required=False,
        type='str'),
)

def run_module():

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    # New resource required arguments checks
    missing_args = []
    for arg, _ in REQUIRED_PARAMETERS:
        if module.params[arg] is None:
            missing_args.append(arg)
    if missing_args:
        module.fail_json(msg=(
            "missing required arguments: " + ", ".join(missing_args)))

    # authenticate using api-key
    if module.params["ibmcloud_api_key"]:
        authenticator = IAMAuthenticator(module.params["ibmcloud_api_key"])
    elif module.params["bearer_token"]:
        authenticator = BearerTokenAuthenticator(module.params["bearer_token"])
    else:
        authenticator = BearerTokenAuthenticator(module.params["env_bearer_token"])

    service = VpcV1('2020-06-02', authenticator=authenticator)

    # Stop Instance
    #print("Stop Instance")
    try:
        stopIns = service.create_instance_action(instance_id=module.params["instance_id"], type=module.params["action_type"])
    except ApiException as e:
        module.fail_json(msg=("Failed to get expected response"))
        print("stop instances failed with status code " + str(e.code) + ": " + e.message)

    #print(stopIns)

    if stopIns.get_status_code() != 201:
        module.fail_json(msg=("Failed to get expected response"))
    module.exit_json(**stopIns.get_result())

def main():
    run_module()

if __name__ == '__main__':
    main()