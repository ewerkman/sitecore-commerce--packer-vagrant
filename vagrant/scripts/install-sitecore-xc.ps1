$provisionFolder = "c:\provision"
$SitecoreCommercePackageName = "Sitecore.Commerce.2019.02-3.0.120"

Copy-Item -Path c:\vagrant\files\$SitecoreCommercePackageName.zip  -Destination $provisionFolder -Force

Expand-Archive $provisionFolder\$SitecoreCommercePackageName.zip -DestinationPath $provisionFolder\$SitecoreCommercePackageName -Force

Copy-Item -Path "c:\vagrant\files\Sitecore Experience Accelerator 1.8 rev. 181112 for 9.0.zip"  -Destination $provisionFolder\$SitecoreCommercePackageName -Force
Copy-Item -Path "c:\vagrant\files\Sitecore PowerShell Extensions-4.7.2 for Sitecore 8.zip"  -Destination $provisionFolder\$SitecoreCommercePackageName -Force

Expand-Archive $provisionFolder\$SitecoreCommercePackageName\SIF.Sitecore.Commerce.2.0.15.zip -DestinationPath $provisionFolder\$SitecoreCommercePackageName\SIF.Sitecore.Commerce.2.0.15 -Force 
Expand-Archive $provisionFolder\$SitecoreCommercePackageName\Sitecore.BizFX.2.0.2.zip -DestinationPath $provisionFolder\$SitecoreCommercePackageName\Sitecore.BizFX.2.0.2 -Force
Expand-Archive $provisionFolder\$SitecoreCommercePackageName\Sitecore.Commerce.Engine.SDK.3.0.31.zip -DestinationPath $provisionFolder\$SitecoreCommercePackageName\Sitecore.Commerce.Engine.SDK.3.0.31 -Force

Remove-Item $provisionFolder\$SitecoreCommercePackageName\SIF.Sitecore.Commerce.2.0.15.zip
Remove-Item $provisionFolder\$SitecoreCommercePackageName\Sitecore.BizFX.2.0.2.zip
Remove-Item $provisionFolder\$SitecoreCommercePackageName\Sitecore.BizFX.SDK.2.0.2.zip
Remove-Item $provisionFolder\$SitecoreCommercePackageName\Sitecore.Commerce.Engine.SDK.3.0.31.zip

$url = "https://www.nuget.org/api/v2/package/MSBuild.Microsoft.VisualStudio.Web.targets/14.0.0.3"
$output = ".\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.nupkg"
Invoke-WebRequest -Uri $url -OutFile $output

Remove-Item .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.zip
Rename-Item .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.nupkg .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.zip -Force
Expand-Archive .\msbuild.microsoft.visualstudio.web.targets.14.0.0.3.zip -DestinationPath $provisionFolder\$SitecoreCommercePackageName\msbuild.microsoft.visualstudio.web.targets.14.0.0.3 -Force

$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname "sitecore.commerce.cer"
Export-Certificate -cert $cert.PSPath -FilePath $provisionFolder\$SitecoreCommercePackageName\sitecore.commerce.cer

Copy-Item -Path "c:\vagrant\scripts\Deploy-Sitecore-Commerce.ps1" -Destination $provisionFolder\$SitecoreCommercePackageName\SIF.Sitecore.Commerce.2.0.15 -Force

Push-Location

Set-Location -Path "$provisionFolder\$SitecoreCommercePackageName\SIF.Sitecore.Commerce.2.0.15"

iisreset

&$provisionFolder\$SitecoreCommercePackageName\SIF.Sitecore.Commerce.2.0.15\Deploy-Sitecore-Commerce.ps1

Pop-Location

