# ConfigureRemotingForAnsible.ps1
# https://oneuptime.com/blog/post/2026-01-21-ansible-windows-configuration/view

# Run as Administrator

# Enable WinRM
Enable-PSRemoting -Force

# Set WinRM service to start automatically
Set-Service -Name WinRM -StartupType Automatic

# Configure WinRM listener
winrm quickconfig -quiet

# Set WinRM to allow unencrypted traffic (for HTTP)
# Use HTTPS in production instead
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Enable basic authentication
winrm set winrm/config/service/auth '@{Basic="true"}'

# Allow connections from any IP (restrict in production)
winrm set winrm/config/client '@{TrustedHosts="*"}'

# Increase max memory per shell for large operations
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

# Configure firewall to allow WinRM
New-NetFirewallRule -Name "WinRM HTTP" -DisplayName "WinRM HTTP" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Restart WinRM service
Restart-Service WinRM

# Verify configuration
winrm enumerate winrm/config/listener
