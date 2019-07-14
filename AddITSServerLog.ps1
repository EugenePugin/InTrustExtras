[CmdletBinding()]
param(
	[Parameter(Mandatory=$false)]
    [switch]
    $Remove
)


[xml]$ITSSSMAP=`
'<FieldInfo>
    <EventRules>
            <Source Name="Quest.ITSecuritySearch.Server.Executor">
                    <Event EventID="1">
                         <Field Name="Who" Index="7"></Field>
                         <Field Name="What" Index="12"></Field>
                         <Field Name="Where" CopyFrom="SourceComputer"></Field>
                    </Event>
            </Source>
    </EventRules>
</FieldInfo>'

$regasm = gci 'C:\Windows\Microsoft.NET\Framework' -Filter 'regasm.exe' -Recurse | Sort-Object Directory -Descending | select -First 1
gci ${env:CommonProgramFiles(x86)} -Filter 'Interop.InTrustEnvironment.dll' -Recurse |%{[Reflection.Assembly]::LoadFrom($_.FullName)}


function Connect-ToServer([string]$serverName=$Env:ComputerName){
    $inTrustEnvironment = New-Object Interop.InTrustEnvironment.InTrustEnvironmentClass
    $inTrustServer = $inTrustEnvironment.ConnectToServer($serverName)
    return $inTrustServer
}

function Add-LogToEventory
{
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
        $LogName,
        [xml]
        $XmlLogContent,
		[string]
		$ServerName=$Env:ComputerName
	)

   $intrustServer = Connect-ToServer -serverName $ServerName

   $Error.Clear()
   try{
       $Log = $inTrustServer.Organization.Eventory.Logs.Add($LogName, $XmlLogContent.OuterXml)
   }
   catch {
       return $Error
   }

   return $Log
}

function Remove-EventoryLog
{
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$LogName,
		[string]
		$ServerName=$Env:ComputerName
	)
	$inTrustServer = Connect-ToServer -serverName $ServerName
	$RemoveLogs = $inTrustServer.Organization.Eventory.Logs | Where-Object {$_.Name -like "$LogName"}
	$RemoveLogs | % {$inTrustServer.Organization.Eventory.Logs.Remove($_.Name)}
}


if($Remove)
{
    Write-Host "Remove ITSS Log from eventory"
    Remove-EventoryLog -LogName 'ITSS Server Log'
}
else
{
    Write-Host "Add ITSS Log to eventory"
    Add-LogToEventory -LogName 'ITSS Server Log' -XmlLogContent $ITSSSMAP -ServerName localhost
}



