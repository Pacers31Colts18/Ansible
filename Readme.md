# Group Policy Ansible

This is a description of a Group Policy Ansible setup I've configured in my lab environment.

## Config Files

### WinRM.ps1

This is a setup file to configure WinRM on the target hosts. Using Port 5986, but in my playbooks I am ignoring certificate checking. Mainly because I did not want to stand up a CA server at the time.

### Inventory.yml

This is the inventory file to manage all the hosts that are connected to my Ansible.

### Ansible.cfg

Default config file. Does the following:

1. Loads the inventory.yml file automatically.
2. Loads the password vault from my home directory (not in this repo), which contains the key to decrypt the windows.yml file.
3. Disables SSH host key verification.

### group_vars\windows.yml

Contains the credentials used to connect to my hosts. Since this is a lab and not production, this is a Domain Administrator account containing my username and password.

### vars\domains.yml

Contains a list of domains that you can manage. I only have one, but if you had multiple, you'd put it in here. Then with the playbooks you would choose which domain to manage.

### vars\ous.yml

Contains a list of organizational units that you can manage. In this case, the playbooks process all the OUs in the file.

## Playbooks

### grouppolicy-backup.yml

This playbook backs up all group policy objects in a chosen domain. Currently it is writing to **C:\Windows\Temp** on the host from the inventory.yml file. If used in production, I would have this go to a different backup server on a different host for storage. This checks to ensure that the DC and Group Policy Management Console are installed before proceeding with the backups, and will output any Success or Failures. The idea of this would be to have a staging domain of the policies you manage, that you can then import and link in other domains.

### grouppolicy-import.yml

This playbook allows you to import a group policy object into a chosen domain. Currently the base path for the backups is **C:\Windows\Temp** on the host from the inventory.yml file. You are then met with prompts:
- GPO Name
- Backup Date (which folder to process from)
- Backup ID (GUID of the policy to process)

From there the playbook will check to see if the policy already exists. If the policy does exist, the playbook will pause for a yes/no prompt to ensure you want to overwrite the policy. Next, the GPO will be imported, and display results if the policy imported or failed.

### grouppolicy-link.yml

With this, a user would choose the domain from the prompt, and enter the GPO name into the console. A check is in place to make sure the GPO exists, and if the GPO exists, will then link it to the organizational units defined in the **ous.yml** file.



