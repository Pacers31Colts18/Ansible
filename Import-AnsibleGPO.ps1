function Import-AnsibleGPO {
    <#
    .Synopsis
    Imports a group policy backup to a domain for use with Ansible.
    .Description
    Imports a group policy backup to a domain for use with Ansible.
    .Example
    Import-AnsibleGPO -Domains "joeloveless.com"
    .Parameter Domains
    Enter the domain name or leave blank to utilize Out-GridView selection.
    #> 

    param(
        [Parameter(Mandatory = $False)]
        [array]$Domains,
        [Parameter(Mandatory = $False)]
        [string]$backupId,
        [Parameter(Mandatory = $False)]
        [string]$targetName,
        [Parameter(Mandatory = $False)]
        [string]$Path
    )

    foreach ($domain in $domains) {

    Import-GPO -path $path -TargetName $targetName -BackupId $backupId -Domain $Domain -CreateIfNeeded
    }
}
