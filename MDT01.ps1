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
