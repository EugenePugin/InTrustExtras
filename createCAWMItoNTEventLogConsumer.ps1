$EventFilterArgs = @{
    EventNamespace = 'root/quest/changeauditor'
    Name = 'CA Alert Event'
    Query = 'SELECT * FROM CAAD_AlertEvent'
    QueryLanguage = 'WQL'
}

$InstanceArgs = @{
    Namespace = 'root/subscription'
    Class = '__EventFilter'
    Arguments = $EventFilterArgs
}

$Filter = gwmi -class $InstanceArgs.Class -namespace $InstanceArgs.namespace | ?{$_.Name -eq $EventFilterArgs.Name}

if($Filter)
{
    $Filter.Query=$EventFilterArgs.Query
    $Filter.Put()   
}
else{$Filter = Set-WmiInstance @InstanceArgs
}

# Define the event log template and parameters
$Template = @(
    'CA Alert detected',
    '%AlertName%',
    '%TimeReceived%',
    '%Description%',
    '%DirectoryObjectName%',
    '%Message%',
    '%UserAddress%',
    '%UserDisplay%',
    '%UserName%',

    '%EventID%',
'%QueryID%',
'%AgentID%',
'%EventClassID%',
'%FromValue%',
'%ToValue%',
'%TimeDetected%',
'%TimeZoneTimeDetected%',
'%TimeZoneTimeReceived%',
'%TimeOfDay%',
'%UserSID%',
'%UserAddressIPv4%',
'%UserAddressIPv6%',
'%MissingOld%',
'%MissingNew%',
'%ResultID%',
'%ResultName%',
'%TimeZoneOffset%',
'%EventClassLink%',
'%Action%',
'%SubSystem%',
'%SeverityName%',
'%Facility%',
'%Agent%',
'%AgentType%',
'%OSVersion%',
'%DomainName%',
'%SiteName%',
'%Comment%',
'%ObjectName%',
'%Attribute%',
'%ObjectClass%',
'%OrganizationalUnit%',
'%ParentDirectoryObjectID%',
'%DirectoryObjectID%',
'%DirectoryObjectCanonical%',
'%DirectorySslTls%',
'%DirectorySignSeal%',
'%RegistryKey%',
'%RegistryValue%',
'%FolderPath%',
'%FileName%',
'%ShareName%',
'%FileSystemTypeID%',
'%LogonID%',
'%PrimarySID%',
'%ProcessName%',
'%FileServer%',
'%TransactionStatus%',
'%TransactionID%',
'%PolicyName%',
'%PolicySection%',
'%PolicyItem%',
'%PrincipalType%',
'%PrincipalName%',
'%ServiceName%',
'%ServiceDisplayName%',
'%ADAMInstanceName%',
'%ADAMPartitionName%',
'%ADAMConfigurationSet%',
'%SQLApplicationName%',
'%SQLClientProcessID%',
'%SQLDatabaseID%',
'%SQLDatabaseName%',
'%SQLEventClass%',
'%SQLEventSubClass%',
'%SQLHostName%',
'%SQLInstanceName%',
'%SQLIsSystem%',
'%SQLLinkedServerName%',
'%SQLObjectID%',
'%SQLObjectID2%',
'%SQLObjectType%',
'%SQLOwnerID%',
'%SQLOwnerName%',
'%SQLParentName%',
'%SQLProviderName%',
'%SQLRowCounts%',
'%SQLSessionLoginName%',
'%SQLSPID%',
'%SQLSuccess%',
'%SQLTextData%',
'%LDAPQueryFilter%',
'%LDAPQueryScope%',
'%LDAPQueryType%',
'%LDAPQueryResults%',
'%LDAPQueryAttributes%',
'%LDAPQueryElapsed%',
'%LDAPQuerySince%',
'%LDAPQueryOccurrences%',
'%LDAPQueryObjectCanonical%',
'%InitiatorSID%',
'%InitiatorUserName%',
'%EventSource%',
'%TimeZone%',
'%ForestName%',
'%VMWareComputeResource%',
'%VMWareVM%',
'%VMWareVMWareHostName%',
'%VMWareDataCenter%',
'%VMWareHost%',
'%VMWareNet%',
'%VMWareDVS%',
'%VMWareDS%',
'%SamAccountName%',
'%UserPrincipalName%',
'%SharePointItemName%',
'%SharePointItemURL%',
'%SharePointListName%',
'%SharePointListPath%',
'%SharePointWebName%',
'%SharePointWebURL%',
'%SharePointFarmName%',
'%SCOMSeverity%'
)

$NtEventLogArgs = @{
    Name = 'CAADAlertEvent'
    Category = [UInt16] 0
    EventType = [UInt32] 2 # Warning
    EventID = [UInt32] 8
    SourceName = 'CA WMI Alert'
    NumberOfInsertionStrings = [UInt32] $Template.Length
    InsertionStringTemplates = $Template
}

$InstanceArgs = @{
    Namespace = 'root/subscription'
    Class = 'NTEventLogEventConsumer'
    Arguments = $NtEventLogArgs
}

$Consumer = gwmi -class $InstanceArgs.Class -namespace $InstanceArgs.namespace | ?{$_.Name -eq $NtEventLogArgs.Name}

if($Consumer)
{
    $Consumer.SourceName=$NtEventLogArgs.SourceName
    $Consumer.NumberOfInsertionStrings=$NtEventLogArgs.NumberOfInsertionStrings
    $Consumer.InsertionStringTemplates=$NtEventLogArgs.InsertionStringTemplates
    $Consumer.Put()   
}
else{$Consumer = Set-WmiInstance @InstanceArgs
}

#$Consumer = Set-WmiInstance @InstanceArgs

$FilterConsumerBingingArgs = @{
    Filter = $Filter
    Consumer = $Consumer
}

$InstanceArgs = @{
    Namespace = 'root/subscription'
    Class = '__FilterToConsumerBinding'
    Arguments = $FilterConsumerBingingArgs
}

#gwmi -class $InstanceArgs.Class -namespace $InstanceArgs.namespace | ?{$_.Filter -eq $FilterConsumerBingingArgs.Filter.__Path -and $_.Consumer -eq $FilterConsumerBingingArgs.Consumer.__Path}

# Run the following code from an elevated PowerShell console.

# Register the alert
$Binding = Set-WmiInstance @InstanceArgs

# Now, this will automatically generate an event log entry in the Application event log.
#Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList notepad.exe