
$SitecorePackageName = "Sitecore 9.1.0 rev. 001564 (WDP XP0 packages)"
$SitecoreConfigName = "XP0 Configuration files 9.1.0 rev. 001564"
$IdentityServerPackageName = "Sitecore.IdentityServer.2.0.0-r00157.scwdp"

choco install jre8 --version 8.0.191 -Y
choco install nssm -Y

refreshenv

c:\vagrant\scripts\install-solr.ps1

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 

Install-Module SitecoreInstallFramework -Force 
Install-Module SitecoreFundamentals -Force

Import-Module SitecoreFundamentals
Import-Module SitecoreInstallFramework

New-Item c:\provision -ItemType Directory
Copy-Item -Path "c:\vagrant\files\$SitecorePackageName.zip" -Destination c:\provision

New-Item c:\provision\license -ItemType Directory
Copy-Item -Path c:\vagrant\files\license\license.xml -Destination c:\provision\license\license.xml

Expand-Archive "c:\provision\$SitecorePackageName.zip" -DestinationPath "c:\provision\$SitecorePackageName"
Expand-Archive "c:\provision\$SitecorePackageName\$SitecoreConfigName.zip" -DestinationPath "c:\provision\$SitecorePackageName"
 
Copy-Item -Path "c:\vagrant\files\$IdentityServerPackageName.zip" -Destination "c:\provision\$SitecorePackageName"
Copy-Item -path c:\vagrant\scripts\Deploy-Sitecore-XP.ps1 -Destination c:\provision

c:\provision\Deploy-Sitecore-XP.ps1


