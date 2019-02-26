param (
    [switch]$Uninstall,
	[switch]$ForcePreReqCheck,
	[switch]$SkipValidation,
	[switch]$ValidateOnly
);


$start = Get-Date

#Requires -Version 5.1
#Requires -RunAsAdministrator


if($SkipValidation -and $ValidateOnly){
	Write-Host "What?"
	Exit
}
#Let's check if we have SIF installed...might be an older version..might not be.
if (Get-Module -Name SitecoreInstallFramework) {
  Write-Host "Removing SIF" 
  Remove-Module SitecoreInstallFramework
}

Write-Host "Loading SIF 2.0"
Import-Module SitecoreInstallFramework -RequiredVersion 2.0.0



$Prefix = "sc9"
$SitecoreAdminPassword = "b"
$SCInstallRoot = "C:\Provision\Sitecore 9.1.0 rev. 001564 (WDP XP0 packages)"
$XConnectSiteName = "sc9.xconnect"
$SitecoreSiteName = "sc9.sc"
$IdentityServerSiteName = "sc9.identityserver"
$LicenseFile = "C:\Provision\License\license.xml"
$SolrUrl = 'https://solr:8983/solr'
$SolrRoot = 'C:\solr\solr-7.2.1'
$SolrService = 'solr-7.2.1'
$SqlServer = '.'
$SqlAdminUser = 'sa'
$SqlAdminPassword = 'SitecoreRocks!'
$XConnectPackage = (Get-ChildItem "$SCInstallRoot\Sitecore 9.1.0 rev. 001564 (OnPrem)_xp0xconnect.scwdp.zip").FullName
$SitecorePackage = (Get-ChildItem "$SCInstallRoot\Sitecore 9.1.0 rev. 001564 (OnPrem)_single.scwdp.zip").FullName
$IdentityServerPackage = (Get-ChildItem "$SCInstallRoot\Sitecore.IdentityServer.2.0.0-r00157.scwdp.zip").FullName
$PasswordRecoveryUrl = "https://$SitecoreSiteName"
$SitecoreIdentityAuthority = "https://$IdentityServerSiteName"
$XConnectCollectionService = "https://$XConnectSiteName"
$ClientSecret = "SIF-Default"
$AllowedCorsOrigins = "https://$SitecoreSiteName"
$SitecoreSecurePassword = 'Sitecor3SecureP4ssword!'

$SiteFolder = "C:\inetpub\wwwroot\$SitecoreSiteName"      
$xConnectSiteFolder = "C:\inetpub\wwwroot\$XConnectSiteName"    
$IdSiteFolder = "C:\inetpub\wwwroot\$IdentityServerSiteName"      
      

if($uninstall)
{
	function RemoveService([string]$serviceName){
    $service = Get-Service $serviceName -ErrorAction SilentlyContinue
    
    if($service){
      Write-Host "Removing Service '$serviceName'"
      if($service.Status -ne "Stopped"){
        Write-Host "Stopping Service '$serviceName'"
          Stop-Service $serviceName
      }
    
      sc.exe delete $serviceName #in Powershell 6, this will be nicer...
      Write-Host "Removed Service '$serviceName'"
    }
    else {
      Write-Host "Service not found '$serviceName'"
    } 
  }

  function RemoveSolrCores(){
    $client = (New-Object System.Net.WebClient)
    $cores = $client.DownloadString("$SolrUrl/admin/cores") | ConvertFrom-Json | Select -expand Status | foreach{ $_.psobject.properties.name}
    $success = 0
    $error = 0
    
    foreach ($core in $cores) {
      if ($core.StartsWith("${prefix}_")) {
        $url = "$SolrUrl/admin/cores?action=UNLOAD&deleteIndex=true&deleteInstanceDir=true&core=$core"
        Write-Host "Deleting Core: '$core'"
        $client.DownloadString($url)
        if ($?) {$success++}
        else{ $error++}
      }
    }
    write-host "Deleted $success cores.  Had $error errors."
  }

  function RemoveDatabase([string]$dbName){
    Write-Host "Removing Database '$dbName'"
    Invoke-SQLCmd -ServerInstance $SqlServer -U $SqlAdminUser -P $SqlAdminPassword -Query "IF EXISTS(SELECT * FROM sys.databases WHERe NAME = '${prefix}_$dbName') BEGIN ALTER DATABASE [${prefix}_$dbName] SET SINGLE_USER WITH ROllBACK IMMEDIATE; DROP DATABASE [${prefix}_$dbName];END"
  }

  function RemoveWebsite([string]$site){
    Write-Host "Removing Site '$site'"
    $webSite = Get-Website -Name $site -ErrorAction SilentlyContinue
    $sitePath = $webSite.PhysicalPath
    if($webSite){
      Stop-Website -Name $site
     
      Remove-Website -Name $site

      Write-Host "Removing Application Pool '$site'"
      Remove-WebAppPool -Name $site 
    }
    else {
      Write-Host "Site not found '$site'"
    }
  }

	
  function RemoveFolder([string]$path){
	  if(Test-Path -Path $path){
		   Write-Host "Removing Folder '$path'"
			&cmd.exe /c rd /s /q $path
	  }
	  else{
		  Write-Host "Folder not found: '$path'"
	  }
   

    if(Test-Path -Path $path)      {
      Write-Error "Failed to delete site folder '$path'"
  }

  }


	
     
  RemoveService("$xConnectSiteName-MarketingAutomationService")
  RemoveService("$xConnectSiteName-IndexWorker")
  
  RemoveSolrCores
  
  RemoveDatabase("Core")
  RemoveDatabase("EXM.Master")
  RemoveDatabase("ExperienceForms")
  RemoveDatabase("MarketingAutomation")
  RemoveDatabase("Master")
  RemoveDatabase("Messaging")
  RemoveDatabase("Processing.Pools")
  RemoveDatabase("Processing.Tasks")
  RemoveDatabase("ProcessingEngineStorage")
  RemoveDatabase("ProcessingEngineTasks")
  RemoveDatabase("ReferenceData")
  RemoveDatabase("Reporting")
  RemoveDatabase("Web")
  RemoveDatabase("Xdb.Collection.Shard0")
  RemoveDatabase("Xdb.Collection.Shard1")
  RemoveDatabase("Xdb.Collection.ShardMapManager")
  
  RemoveWebsite($IdentityServerSiteName)
  RemoveWebsite($xConnectSiteName)
  RemoveWebsite($SitecoreSiteName)   
  
  RemoveFolder($SiteFolder)
  RemoveFolder($xConnectSiteFolder)   
  RemoveFolder($IdSiteFolder)   
        
}
else
{
	function ValidateSystem()
	{
		
         #Check Solr Service Status
    $service = Get-Service -Name $SolrService
    
    if($service.Status -ne "Running")
    {
      throw "Solr service '$SolrService' is not running. Current state is '$($service.Status)'"
    }

    #Check Solr Version
    $solrVerClient = (New-Object System.Net.WebClient)
    $solrAdminResp = $solrVerClient.DownloadString("$SolrUrl/admin/info/system") | ConvertFrom-Json
    $solrVersion = $SolrAdminResp.lucene."solr-spec-version"
    
    if($solrVersion -ne "7.2.1"){
      throw "Invalid solr version '$solrVersion'."
    }
    
    #Check Solr Folder
    if(!(Test-Path $SolrRoot))
    {
      throw "Solr Folder doesn't exist at '$SolrRoot'"
    }

    
    #Check Solr Folder config sets for _default
    $configSetPath = "$SolrRoot\server\solr\configsets\_default"
    if(!(Test-Path $configSetPath))
    {
      throw "Solr Configsets Folder doesn't exist at '$configSetPath'"
    }

    #Check for our license file
    if(!(Test-Path $LicenseFile))
    {
      throw "License File doesn't exist at '$LicenseFile'"
    }

    #Check Login
    Invoke-SQLCmd -ServerInstance $SqlServer -U $SqlAdminUser -P $SqlAdminPassword -Query "SELECT GETDATE()" -ErrorAction Stop | Out-Null

    #Check our SQL version
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
    $sqlServerSmo = New-Object "Microsoft.SqlServer.Management.Smo.Server" $SqlServer
    $sqlVersion = $sqlServerSmo.Version.Major
    $sqlBuild = $sqlServerSmo.Version.Build

    #Check for 2016 or 2017
    if($sqlVersion -ne 13 -and $sqlVersion -ne 14){
      throw "Invalid SQL Server Version"
    }

    #if 2016, we need at least SP2 installed
    if($sqlVersion -eq 13 -and $sqlBuild -lt 5026){
      throw "SQL Server 2016 must have SP2 installed"
      }

      #Finally check if they can actually create DBs or not. It helps.
      $canCreateDBs = (Invoke-SQLCmd -ServerInstance $SqlServer -U $SqlAdminUser -P $SqlAdminPassword -Query "SELECT has_perms_by_name(null, null, 'CREATE ANY DATABASE') AS DBPerm") | Select -expand DBPerm
      
      if($canCreateDBs -ne "1"){
        throw "Specified SQL user does not have DB Creation permissions"
      }
        
		Write-Host "Validation Complete! Yay!" -ForegroundColor Green
	}

	if($ForcePreReqCheck){
		Install-SitecoreConfiguration -Path "$SCInstallRoot\Prerequisites.json"
	}

	if(!$SkipValidation){
		ValidateSystem
	}
	if(!$Validateonly){
		
  
$idCertParams = @{
    Path = "$SCInstallRoot\createcert.json"
    CertificateName = $IdentityServerSiteName
}

Install-SitecoreConfiguration @idCertParams

$idServerParams = @{
    Path = "$SCInstallRoot\identityserver.json"
    Package = $IdentityServerPackage
    SqlDbPrefix = $Prefix
    SitecoreIdentityCert = $IdentityServerSiteName
    LicenseFile = $LicenseFile
    SiteName = $IdentityServerSiteName
    SqlCorePassword = $SitecoresecurePassword
    SqlServer = $SqlServer
    PasswordRecoveryUrl = $PasswordRecoveryUrl
    AllowedCorsOrigins = $AllowedCorsOrigins
    ClientSecret = $ClientSecret
}

Install-SitecoreConfiguration @idServerParams


$xcCertParams = @{
    Path = "$SCInstallRoot\createcert.json"
    CertificateName = $XConnectSiteName
}

Install-SitecoreConfiguration @xcCertParams

$xcSolrParams = @{
    Path = "$SCInstallRoot\xconnect-solr.json"
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    CorePrefix = $Prefix
}

Install-SitecoreConfiguration @xcSolrParams

$xcSiteParams = @{
    Path = "$SCInstallRoot\xconnect-xp0.json"
    Package = $XConnectPackage
    SiteName = $XConnectSiteName
    SqlServer = $SqlServer
    SolrUrl = $SolrUrl
    SqlDbPrefix = $Prefix
    SolrCorePrefix = $Prefix
    XConnectCert = $XConnectSiteName
    LicenseFile = $LicenseFile
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SqlProcessingPoolsPassword = $SitecoreSecurePassword
    SqlReferenceDataPassword = $SitecoreSecurePassword
    SqlMarketingAutomationPassword = $SitecoreSecurePassword
    SqlMessagingPassword = $SitecoreSecurePassword
    SqlProcessingEnginePassword = $SitecoreSecurePassword
    SqlReportingPassword = $SitecoreSecurePassword
}

Install-SitecoreConfiguration @xcSiteParams

$scSolrParams = @{
    Path = "$SCInstallRoot\sitecore-solr.json"
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    CorePrefix = $Prefix
}

Install-SitecoreConfiguration @scSolrParams

$scSiteParams = @{
    Path = "$SCInstallRoot\sitecore-xp0.json"
    Package = $SitecorePackage
    SiteName = $SitecoreSiteName
    SitecoreIdentityAuthority = $SitecoreIdentityAuthority
    XConnectCollectionService = $XConnectCollectionService
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrUrl = $SolrUrl
    SqlDbPrefix = $Prefix
    SolrCorePrefix = $Prefix
    XConnectCert = $XConnectSiteName
    LicenseFile = $LicenseFile
    SitecoreAdminPassword = $SitecoreAdminPassword
    SqlCorePassword = $SitecoreSecurePassword
    SqlSecurityPassword = $SitecoreSecurePassword
    SqlMasterPassword = $SitecoreSecurePassword
    SqlWebPassword = $SitecoreSecurePassword
    SqlReportingPassword = $SitecoreSecurePassword
    SqlProcessingPoolsPassword = $SitecoreSecurePassword
    SqlProcessingTasksPassword = $SitecoreSecurePassword
    SqlReferenceDataPassword = $SitecoreSecurePassword
    SqlMarketingAutomationPassword = $SitecoreSecurePassword
    SqlFormsPassword = $SitecoreSecurePassword
    SqlExmMasterPassword = $SitecoreSecurePassword
    SqlMessagingPassword = $SitecoreSecurePassword
}

 Install-SitecoreConfiguration @scSiteParams

Write-Host "Enabling SSL on Site"
Invoke-AddWebFeatureSSLTask -Hostname $SitecoreSiteName -SiteName $SitecoreSiteName -Port 443 -ClientCertLocation LocalMachine -OutputDirectory "C:\certificates" -RootDnsName "DO_NOT_TRUST_SitecoreRootCert" -RootCertName "root-authority"
  Remove-WebBinding -Port 80 -HostHeader $SitecoreSiteName        
        
	}
}


$timeSpan = New-TimeSpan -Start $start -End (Get-Date)

Write-Host ("SIF-less completed in {0:HH:mm:ss}" -f ([datetime]$timeSpan.Ticks))