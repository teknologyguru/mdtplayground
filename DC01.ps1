
# Static IP and DNS Servers
New-NetIPAddress -IPAddress 10.10.10.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.10.10.1 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses (“10.10.10.1”,”8.8.8.8”)

# Add Feature
install-windowsfeature ad-domain-services -includemanagementtools

# Sanity check forest installation
Test-ADDSForestInstallation -DomainName contoso.djvc.net -InstallDns

# Do the deed (This'll reboot the server)
Install-ADDSForest -DomainName contoso.djvc.net -InstallDns

# dcpromo. Superfluous. 
#Install-ADDSDomainController -DomainName contoso.djvc.net -InstallDNS:$True –Credential (Get-Credential)
