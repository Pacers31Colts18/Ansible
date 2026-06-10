# Group Policy Ansible

This is a description of a Group Policy Ansible setup I've configured in my lab environment.

## Config Files

### Notes.md

Random notes on how to configure Ubuntu to work properly.

### WinRM.ps1

This is a setup file to configure WinRM on the target hosts. Using Port 5986, but in my playbooks I am ignoring certificate checking. Mainly because I did not want to stand up a CA server at the time.

### Inventory.yml

This is the inventory file to manage all the hosts that are connected to my Ansible.

### Ansible.cfg

Default config file. Does the following:

1. Loads the inventory.yml file automatically.
2. Disables SSH host key verification.

## playbooks\gpo

### playbook-gpo-assign.yml

Assigns permissions to a GPO based on the permissions and AD group defined in the var-gpo.yml file. Prompts for a domain, username/password, and GPO Name.

Uses the following tasks:

- task-check-gpo-permissions.yml
- task-check-gpo-exists.yml
- task-check-and-set-gpo-permissions.yml

### playbook-gpo-backup-all.yml

Prompted for a domain (from the **var-gpo.yml** file), will then backup all GPOs in the domain to the specified path (also from the **var-gpo.yml** file). 

Uses the following tasks:

- task-check-gpo-prerequisites.yml
- task-backup-gpo-all.yml

### playbook-gpo-check.yml

Prompted for a domain (from the **var-gpo.yml** file), and then prompts for a GPO name. From there it will check to see if the GPO exists or not in a domain.

Uses the following tasks:

- task-check-gpo-prerequisites.yml
- task-check-gpo-exists.yml

### playbook-gpo-import.yml

- Prompted for the following:
  - Domain Name
  - Username/Password
  - Import source
    - Either the customer's file share or a shared file share between multiple customers
  - Select a backup date from the folder structure for policies to import.
    - From that backup date, select the GPO to import.
- Will then check to see if the GPO name already exists. If the GPO exists, will prompt for an overwrite --- (O)verwrite policy / (N)ew policy / (A)bort
  - Overwrite - Overwrites the existing policy
  - New Policy - Creates a new policy and prompts you for the new name.
  - Abort - exits the process.
- The final step will then assign a group with the defined permissions in the var-gpo.yml file

Uses the following tasks:

- task-check-gpo-prerequisites.yml
- task-select-backup-date.yml
- task-select-gpo.yml
- task-check-gpo-exists.yml
- task-import-gpo.yml
- task-check-and-set-gpo-permissions.yml

### playbook-gpo-link.yml

- Prompted for the following:
  - Domain Name
  - Username/Password
  - GPO Name
  - 
Will then link a GPO to the OUs defined in the **var-gpo.yml** file

Uses the following tasks:

- task-check-gpo-prerequisites.yml
- task-check-gpo-exists.yml
- task-check-and-link-gpo.yml

## playbooks\gpo\files

### ConvertTo-DistinguishedName.ps1

Converts the output given by Get-GPLink into DN format instead of joeloveless.com\JoeLoveless_Workstations\Windows_11.

## playbooks\gpo\vars

### var-gpo.yml

Contains the following, the idea being that you can add multiple customers/domains and work off of this.

- Name
  - Customer Name or Domain Name
- FQDN
  - FQDN of the domain
- DC
  - Domain Controller to process everything from
- BackupPath
  - Path to backup the GPOs to. Can be a different server, local path, etc.
- Group
  - AD Group that is added to the GPOs in task-check-and-set-gpo-permissions.yml
- Group Permissions
  - Permissions that get added to the GPOs in task-check-and-set-gpo-permissions.yml
- OUs
  - Name
    - Name of the OU, can add multiple OUs. Used for the task-check-and-link.gpo.yml
  - DN
    - The full DN of the OUs. Used for the task-check-and-link.gpo.yml
- SharedImportPath
  - Similar to the BackupPath, allows you to import from a shared server across multiple customers or domains.

## playbooks\gpo\tasks

This contains various pieces of code to avoid duplicating the code across playbooks.

### task-backup-gpo-all.yml

Backs up all GPOs in a given domain to a file share. For POC purposes, this is just going to **C:\Windows\Temp\GPOBackup** on the host. Outputs success and failed backups, and will fail the step if there is any failure.

### task-check-and-link-gpo.yml

A combination task that takes **task-check-gpo-link.yml** and **task-set-gpo-link.yml** and puts it in one task. This allows for better looping of the tasks so output is not overwritten.

### task-check-and-set-gpo-permissions.yml

Used in conjuction with **task-check-gpo-permissions.yml** to check and set the permissions on a GPO.

### task-check-gpo-exists.yml

Does a **Get-GPO** and outputs the details of the GPO.

### task-check-gpo-link.yml

Checks to see if a GPO is linked to the OUs defined in the **var-gpo.yml** file.

### task-check-gpo-permissions.yml

Checks the permissions on a GPO. Used in conjunction with **task-check-and-set-gpo-permissions.yml**

### task-check-gpo-prerequisites.yml

Checks to make sure the domain controller is available. Also checks to make sure Group Policy Management Console is installed.

### task-import-gpo.yml

After gathering the results from **task-check-gpo-exists.yml** will then import a GPO into the domain.

### task-select-backup-date.yml

Gathers the importPath, then displays the list of folders (in a proper date format), tehn allows you to select that date.

### task-select-gpo.yml

After the backup date is selected, then displays all the GPOs that are backed up in the child folder. All folder are named with their GPOName\GUID.

### task-set-gpo-link.yml

After gathering the results from **task-check-gpo-link.yml** will then link a GPO to the OUs.
