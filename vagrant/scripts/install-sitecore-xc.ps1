
Copy-Item -Path c:\vagrant\files\Sitecore.Commerce.2018.12-2.4.63.zip  -Destination c:\provision -Force

Expand-Archive c:\provision\Sitecore.Commerce.2018.12-2.4.63.zip -DestinationPath c:\provision\Sitecore.Commerce.2018.12-2.4.63 -Force

Copy-Item -Path "c:\vagrant\files\Sitecore Experience Accelerator 1.8 rev. 181112 for 9.0.zip"  -Destination c:\provision\Sitecore.Commerce.2018.12-2.4.63 -Force
Copy-Item -Path "c:\vagrant\files\Sitecore PowerShell Extensions-4.7.2 for Sitecore 8.zip"  -Destination c:\provision\Sitecore.Commerce.2018.12-2.4.63 -Force

Expand-Archive c:\provision\Sitecore.Commerce.2018.12-2.4.63\SIF.Sitecore.Commerce.1.4.7.zip -DestinationPath c:\provision\Sitecore.Commerce.2018.12-2.4.63\SIF.Sitecore.Commerce.1.4.7 -Force 
Expand-Archive c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.BizFX.1.4.1.zip -DestinationPath c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.BizFX.1.4.1 -Force
Expand-Archive c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.Commerce.Engine.SDK.2.4.43.zip -DestinationPath c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.Commerce.Engine.SDK.2.4.43 -Force

Remove-Item c:\provision\Sitecore.Commerce.2018.12-2.4.63\SIF.Sitecore.Commerce.1.4.7.zip
Remove-Item c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.BizFX.1.4.1.zip
Remove-Item c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.BizFX.SDK.1.4.1.zip
Remove-Item c:\provision\Sitecore.Commerce.2018.12-2.4.63\Sitecore.Commerce.Engine.SDK.2.4.43.zip

$url = "https://www.nuget.org/api/v2/package/MSBuild.Microsoft.VisualStudio.Web.targets/14.0.0.3"
$output = ".\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.nupkg"
Invoke-WebRequest -Uri $url -OutFile $output

Remove-Item .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.zip
Rename-Item .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.nupkg .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.zip -Force
Expand-Archive .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.zip -DestinationPath c:\provision\Sitecore.Commerce.2018.12-2.4.63\msbuild.microsoft.visualstudio.web.targets.14.0.0.3 -Force

$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname "sitecore.commerce.cer"
Export-Certificate -cert $cert.PSPath -FilePath c:\provision\Sitecore.Commerce.2018.12-2.4.63\sitecore.commerce.cer

Copy-Item -Path "c:\vagrant\scripts\Deploy-Sitecore-Commerce.ps1" -Destination c:\provision\Sitecore.Commerce.2018.12-2.4.63\SIF.Sitecore.Commerce.1.4.7 -Force

Push-Location

Set-Location -Path c:\provision\Sitecore.Commerce.2018.12-2.4.63\SIF.Sitecore.Commerce.1.4.7

iisreset

c:\provision\Sitecore.Commerce.2018.12-2.4.63\SIF.Sitecore.Commerce.1.4.7\Deploy-Sitecore-Commerce.ps1

Pop-Location

