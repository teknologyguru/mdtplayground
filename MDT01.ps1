# Join the domain
Add-Computer –DomainName contoso.djvc.net –Credential (Get-Credential)
Restart-Computer

# Install WDS, RSAT
Install-WindowsFeature -Name RSAT
Install-WindowsFeature -Name WDS

# Grab FF
New-Item -ItemType directory -Path C:\Downloads
Invoke-WebRequest -Uri "https://ninite.com/firefox/ninite.exe" -OutFile C:\Downloads\ninite.exe
& C:\Downloads\ninite.exe

# MDT
Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" -OutFile C:\Downloads\MicrosoftDeploymentToolkit_x64.msi
& C:\Downloads\MicrosoftDeploymentToolkit_x64.msi

# ADK
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?linkid=859206" -OutFile C:\Downloads\adksetup.exe
& C:\Downloads\adksetup.exe

# Create OU Structure
<#
Contoso
    Accounts
        Admins
        Service Accounts
            # MDT_BA user
        Users
    Computers
        Servers
        Workstations
    Groups
        Security Groups
#>

# Create & share Logs folder
New-Item -Path E:\Logs -ItemType directory
New-SmbShare -Name Logs$ -Path E:\Logs -ChangeAccess EVERYONE
icacls E:\Logs /grant '"MDT_BA":(OI)(CI)(M)'

# Create Deployment Share
# Configure Permissions for Deployment Share
icacls E:\MDTBuildLab\Captures /grant '"MDT_BA":(OI)(CI)(M)'

# New folders for OSes
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "C:\MDTBuildLab"
new-item -path "DS001:\Operating Systems" -enable "True" -Name "Windows 10" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Operating Systems" -enable "True" -Name "Windows Server 2016" -Comments "" -ItemType "folder" -Verbose
import-mdtoperatingsystem -path "DS001:\Operating Systems\Windows 10" -SourcePath "C:\Downloads\CPRA_X64FREV_EN-US_DV5" -DestinationFolder "W10PROx64" -Move -Verbose
import-mdtoperatingsystem -path "DS001:\Operating Systems\Windows Server 2016" -SourcePath "C:\Downloads\SSS_X64FREV_EN-US_DV9" -DestinationFolder "WS2016x64" -Move -Verbose

# A folder for Software, and import MSO
new-item -path "DS001:\Applications" -enable "True" -Name "Microsoft" -Comments "" -ItemType "folder" -Verbose
import-MDTApplication -path "DS001:\Applications\Microsoft" -enable "True" -Name "Install - Microsoft Office 2016" -ShortName "Office" -Version "2016" -Publisher "Microsoft" -Language "" -CommandLine "setup.exe /configure .\CustomConfig.xml" -WorkingDirectory ".\Applications\MSO 2016" -ApplicationSourcePath "C:\Downloads\O2016" -DestinationFolder "MSO 2016" -Verbose

# Make Task Sequence
new-item -path "DS001:\Task Sequences" -enable "True" -Name "Windows 10" -Comments "" -ItemType "folder" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences\Windows 10" -Name "Windows 10 Pro x64 Default Image" -Template "Client.xml" -Comments "Reference Build" -ID "REFW10X64-001" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 10\Windows 10 Pro in W10PROx64 install.wim" -FullName "Contoso" -OrgName "Contoso" -HomePage "https://www.djvc.net" -Verbose
