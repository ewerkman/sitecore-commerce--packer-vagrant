#################################################################################################
# Choco Install
#   Additonal packages can be found at https://chocolatey.org/packages
#   1) Remove/Add packages
#################################################################################################

Write-Host "Install SQL Server"
e:\setup.exe /ConfigurationFile=c:\sql2016.ini

Write-host "Choco Started At: $((Get-Date).ToString())"

$ChocoInstallPath = "$($env:SystemDrive)\ProgramData\Chocolatey\bin"
if (!(Test-Path $ChocoInstallPath))
{
    write-host "Install Chocolatey . . . "
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) | out-null
    write-host "END Installing Chocolatey!" 
}
else
{
    write-host "Upgrade Chocolatey . . . "
    choco upgrade chocolatey
    write-host "END Upgrade Chocolatey!"
}

chocolatey feature enable -n=allowGlobalConfirmation

write-host "Install visualstudio2017community . . . "
choco install visualstudio2017community --package-parameters "--add Microsoft.VisualStudio.Workload.NetCoreTools  ==add Microsoft.VisualStudio.Workload.NetWeb --includeRecommended --includeOptional --passive --locale en-US"
write-host "END Install visualstudio2017community!"

Write-Host "Install IIS"
Install-WindowsFeature Web-Server,  Web-WebServer,  Web-Common-Http,  Web-Default-Doc,  Web-Dir-Browsing,  Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-DAV-Publishing, Web-Health, Web-Http-Logging, Web-Custom-Logging, Web-Log-Libraries, Web-ODBC-Logging, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Basic-Auth, Web-CertProvider, Web-Client-Auth, Web-Digest-Auth, Web-Cert-Auth, Web-IP-Security, Web-Url-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, NET-Framework-Features, NET-Framework-Core, NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45
Write-Host "END Install IIS"

write-host "Install 7zip . . . "
choco install 7zip -y | Out-Null
write-host "END Install 7zip!"

write-host "Install Chrome . . . "
choco install GoogleChrome -y | Out-Null
write-host "END Install Chrome!"

write-host "Install GIT . . . "
choco install git.install -y | Out-Null
write-host "END Install GIT!"

write-host "Install Visual Studio Code . . . "
choco install visualstudiocode -y | Out-Null
write-host "END Install Visual Studio Code!"

write-host "Install Visual Studio Code PowerShell Extension . . . "
choco install choco install vscode-powershell -y | Out-Null
write-host "END Install Visual Studio Code PowerShell Extension!"

Write-Host "Install Cmder"\
choco install cmder -Y | Out-Null
Write-Host "END Install Cmder"

Write-Host "Install SQL Server Management Studio"
choco install sql-server-management-studio -Y | Out-Null
Write-Host "END Install SQL Server Management Studio"

Write-Host "Install Dotnet Core"
choco install dotnetcore -Y | Out-Null
Write-Host "END Install Dotnet Core"

Write-Host "Install UrlRewrite"
choco install urlrewrite -Y | Out-Null
Write-Host "END Install UrlRewrite"

Write-Host "Install WebDeploy"
choco install webdeploy -Y | Out-Null
Write-Host "END WebDeploy"

Write-Host "Install NodeJS"
Choco install nodejs-lts -Y | Out-Null
Write-Host "END Install NodeJS"

Write-Host "Install postman"
choco install postman -Y | Out-Null
Write-Host "END Install postman"

Write-Host "Install dotpeek"
choco install dotpeek -Y | Out-Null
Write-Host "END Install dotpeek"

Write-Host "Install dotnetcore-windowshosting"
choco install dotnetcore-windowshosting --version 2.0.6.20180315 -Y | Out-Null
Write-Host "END Install dotnetcore-windowshosting"

chocolatey feature disable -n=allowGlobalConfirmation
Write-host "Choco Ended At: $((Get-Date).ToString())"