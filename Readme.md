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

## playbooks\gpo

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
  - GPO Name (name of the new GPO once imported)
  - Backup Date
  - Backup GUID (from the **C:\Windows\Temp\GPOBackup\%domain%** folder)
- Will then check to see if the GPO name already exists. If the GPO exists, will prompt for an overwrite (yes/no), if the GPO doesn't exist, will proceed to import the GPO.

Uses the following tasks:

- task-check-gpo-prerequisites.yml
- task-check-gpo-exists.yml
- task-import-gpo.yml

### playbook-gpo-link.yml

- Prompted for the following:
  - Domain Name
  - GPO Name
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

Contains the domain, the fqdn, the backup path, and the defined OUs. Can add new domains, and specify the details for each to allow for flexibility. This allows for different OUs and backup paths to be listed, allowing you to backup to different file shares, or target different OU structures.

## playbooks\gpo\tasks

This contains various pieces of code to avoid duplicating the code across playbooks.

### task-backup-gpo-all.yml

Backs up all GPOs in a given domain to a file share. For POC purposes, this is just going to **C:\Windows\Temp\GPOBackup** on the host. Outputs success and failed backups, and will fail the step if there is any failure.

### task-check-and-link-gpo.yml

A combination task that takes **task-check-gpo-link.yml** and **task-set-gpo-link.yml** and puts it in one task. This allows for better looping of the tasks so output is not overwritten.

### task-check-gpo-exists.yml

Does a **Get-GPO** and outputs the details of the GPO.

### task-check-gpo-prerequisites.yml

Checks to make sure the domain controller is available. Also checks to make sure Group Policy Management Console is installed.

### task-import-gpo.yml

After gathering the results from **task-check-gpo-exists.yml** will then import a GPO into the domain.

### task-set-gpo-link.yml

After gathering the results from **task-check-gpo-link.yml** will then link a GPO to the OUs.
