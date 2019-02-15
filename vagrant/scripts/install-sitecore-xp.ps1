
choco install jre8 --version 8.0.181 -Y

refreshenv

c:\vagrant\scripts\install-solr.ps1

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 

Install-Module SitecoreInstallFramework -Force -RequiredVersion 1.2.1
Install-Module SitecoreFundamentals -Force -RequiredVersion 1.1.0

Import-Module SitecoreFundamentals
Import-Module SitecoreInstallFramework

New-Item c:\provision -ItemType Directory
Copy-Item -Path "c:\vagrant\files\Sitecore 9.0.2 rev. 180604 (WDP XP0 packages).zip"  -Destination c:\provision

New-Item c:\provision\license -ItemType Directory
Copy-Item -Path c:\vagrant\files\license\license.xml -Destination c:\provision\license\license.xml

Expand-Archive "c:\provision\Sitecore 9.0.2 rev. 180604 (WDP XP0 packages).zip" -DestinationPath "c:\provision\Sitecore 9.0.2 rev. 180604 (WDP XP0 packages)"
Expand-Archive "c:\provision\Sitecore 9.0.2 rev. 180604 (WDP XP0 packages)\XP0 Configuration files 9.0.2 rev. 180604.zip" -DestinationPath "c:\provision\Sitecore 9.0.2 rev. 180604 (WDP XP0 packages)"
 
Copy-Item -path c:\vagrant\scripts\Deploy-Sitecore-XP.ps1 -Destination c:\provision

c:\provision\Deploy-Sitecore-XP.ps1


