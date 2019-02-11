param (
    [switch]$uninstall
);


$start = Get-Date

#Requires -Version 5.1
#Requires -RunAsAdministrator
#Requires -Modules SitecoreFundamentals

Remove-Module SitecoreInstallFramework
Import-Module SitecoreInstallFramework -RequiredVersion 1.2.1


$Prefix = 'sc9'
$PSScriptRoot = 'C:\provision\Sitecore 9.0.2 rev. 180604 (WDP XP0 packages)'
$SolrUrl = 'https://solr:8983/solr'
$SolrRoot = 'C:\solr\solr-6.6.2'
$SolrService = 'solr-6.6.2'
$SqlServer = '.'
$SqlAdminUser = 'sa'
$SqlAdminPassword = 'SitecoreRocks!'
$LicenseFilePath = 'C:\provision\license\license.xml'
$xConnectCertName = "$Prefix.xconnect_client"
$xConnectSiteName = 'sc9.xconnect'
$SiteName = 'sc9.sc'
$SiteFolder = "C:\inetpub\wwwroot\$SiteName"      
$xConnectSiteFolder = "C:\inetpub\wwwroot\$xConnectSiteName"
$SecurePassword = 'Sitecor3SecureP4ssword!'
      

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
    [xml]$coresXML = $client.DownloadString("$SolrUrl/admin/cores")
    $cores = $coresXML.response.lst[2].lst | % {$_.name}
    $success = 0
    $error = 0
    
    foreach ($core in $cores) {
      if ($core.StartsWith($prefix)) {
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
  RemoveDatabase("ReferenceData")
  RemoveDatabase("Reporting")
  RemoveDatabase("Web")
  RemoveDatabase("Xdb.Collection.Shard0")
  RemoveDatabase("Xdb.Collection.Shard1")
  RemoveDatabase("Xdb.Collection.ShardMapManager")
  
  RemoveWebsite($xConnectSiteName)
  RemoveWebsite($SiteName)   
  
  RemoveFolder($SiteFolder)
  RemoveFolder($xConnectSiteFolder)   
        
}
else
{
	
          
        if(-not (Get-command npm)){
          Write-Host "NPM not detected"
          Return
        }
        
  $certParams = @{
    Path = "$PSScriptRoot\xconnect-createcert.json"
    CertificateName = $xConnectCertName 
  }
  Install-SitecoreConfiguration @certParams -Verbose
    
  $solrParams = @{
    Path = "$PSScriptRoot\xconnect-solr.json"
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    CorePrefix = $Prefix
  }
  Install-SitecoreConfiguration @solrParams
  
  $xconnectParams = @{
    Path = "$PSScriptRoot\xconnect-xp0.json"
    Package = "$PSScriptRoot\Sitecore 9.0.2 rev. 180604 (OnPrem)_xp0xconnect.scwdp.zip"
    LicenseFile = $LicenseFilePath
    Sitename = $xConnectSiteName
    XConnectCert = $xConnectCertName 
    SqlDbPrefix = $Prefix
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrCorePrefix = $Prefix
    SolrURL = $SolrUrl
    SqlCollectionPassword = $SecurePassword
    SqlProcessingPoolsPassword = $SecurePassword
    SqlReferenceDataPassword = $SecurePassword
    SqlMarketingAutomationPassword = $SecurePassword
    SqlMessagingPassword = $SecurePassword
  }
  Install-SitecoreConfiguration @xconnectParams
  
  $solrParams = @{
    Path = "$PSScriptRoot\sitecore-solr.json"
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    CorePrefix = $Prefix
  }
  Install-SitecoreConfiguration @solrParams
    
  $sitecoreParams = @{
    Path = "$PSScriptRoot\sitecore-XP0.json"
    Package = "$PSScriptRoot\Sitecore 9.0.2 rev. 180604 (OnPrem)_single.scwdp.zip"
    LicenseFile = $LicenseFilePath
    Sitename = $SiteName
    XConnectCert = $xConnectCertName 
    SqlDbPrefix = $Prefix
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrCorePrefix = $Prefix
    SolrURL = $SolrUrl
    SqlCorePassword = $SecurePassword
    SqlMasterPassword = $SecurePassword
    SqlWebPassword = $SecurePassword
    SqlReportingPassword = $SecurePassword
    SqlProcessingPoolsPassword = $SecurePassword
    SqlProcessingTasksPassword = $SecurePassword
    SqlReferenceDataPassword = $SecurePassword
    SqlMarketingAutomationPassword = $SecurePassword
    SqlFormsPassword = $SecurePassword
    SqlExmMasterPassword = $SecurePassword
    SqlMessagingPassword = $SecurePassword
    XConnectCollectionService = "https://$xConnectSiteName"
  }
  Install-SitecoreConfiguration @sitecoreParams
        
}


$timeSpan = New-TimeSpan -Start $start -End (Get-Date)

Write-Host ("SIF-less completed in {0:HH:mm:ss}" -f ([datetime]$timeSpan.Ticks))