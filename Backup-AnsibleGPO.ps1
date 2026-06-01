function Backup-AnsibleGPO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$GPOName,
        [Parameter(Mandatory)]
        [string]$SourceDomain,
        [Parameter(Mandatory)]
        [string]$BackupPath
    )

    Write-Output "Backing up GPO '$GPOName' from $SourceDomain"
    $backup = Backup-GPO -Name $GPOName -Domain $SourceDomain -Path $BackupPath -ErrorAction Stop

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $details = @"
Policy Name : $GPOName
Domain      : $SourceDomain
Timestamp   : $timestamp
"@

    $backupFolder = Join-Path $backup.BackupDirectory "{$($backup.Id)}"

    $details | Out-File -FilePath (Join-Path $backupFolder 'PolicyDetails.txt') -Encoding utf8

    if (Test-Path $backupFolder) {
        Write-Output $details
    } else {
        Write-Error "Backup directory not found: $backupFolder"
    }
}
