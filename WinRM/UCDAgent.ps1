#ps1_sysnative
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$VM_NAME=$args[0]
$UCDAGENTRELAY_URL=$args[1]
$UCDUSER=$args[2]
$UCDPASSWORD=$args[3]
$UCDSERVERJMSPORTRELAY=$args[4]
$UCDPORT=$args[5]
$UCDHOST=$args[6]
$platform = "win"
$Arch = "$platform-x86_64"
if(0 -eq (Get-WmiObject -class "Win32_Processor" -namespace "root\cimV2" -compute .)){$Arch = "$platform-x86"}
$AgentArchive = "ibm-ucd-agent-$Arch.zip"

$AgentArgs = ""
$WebClient = New-Object System.Net.WebClient

$PASSWORD="$UCDPASSWORD"
$WebClient.Credentials = New-Object System.Net.NetworkCredential("$UCDUSER","$PASSWORD")
$UcdRemoteHost="$UCDAGENTRELAY_URL"
$WebProxy = New-Object System.Net.WebProxy
$WebProxy.Address = "${UCDAGENTRELAY_URL}:20080"
$WebClient.Proxy = $WebProxy
$AgentArgs = "-r -d"
$JmsPort = "$UCDSERVERJMSPORTRELAY"
$Source="https://$UCDHOST" + ":" + "$UCDPORT/cli/version/downloadArtifacts?component=ucd-agent-$Arch&version=7.1&singleFilePath=$AgentArchive"
$Source
$Destination="$env:TEMP\$AgentArchive"
$Destination
Write-Output "Downloading the agent installation package..."
$WebClient.DownloadFile($Source,$Destination)
$shell = new-object -com shell.application
$zip = $shell.NameSpace($Destination)
foreach($item in $zip.items()){$shell.Namespace("$env:TEMP").copyhere($item)}
Try {
Set-ExecutionPolicy Bypass -ErrorAction Stop
} Catch {
Echo "Setting script execution policy failed, or an override is in place."
}


Write-Output "Agent installation package download complete"
$UcdAgentName = $VM_NAME
$args = @()
$args += ("-t", "`"`"")
$args += ("-s", "$UcdRemoteHost")
$args += ("$AgentArgs")
$args += ("-x", "install-service")
$args += ("-p", "$JmsPort")
$args += ("-f")
$args += ("-n", "`"$UcdAgentName`"")
$cmd = "$env:TEMP\ibm-ucd-agent-install\install-agent-with-options.ps1"

Invoke-Expression "$cmd $args"