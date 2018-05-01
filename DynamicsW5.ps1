param(
  [string]$action,
  [string]$logname="Dynamics CRM Audit"
  )

$dynamics_rules="<FieldInfo>
            <EventRules>
                    <Field Name=""What"" CopyFrom=""Category""></Field>
                    <Field Name=""Where"" CopyFrom=""Computer""></Field>
                    <Field Name=""Who"" CopyFrom=""UserName""></Field>
                    <Field Name=""Whom"" Index = ""3""></Field>
            </EventRules>
        </FieldInfo>"

$Inenv = new-object -ComObject InTrustServiceLookup.InTrustEnvironment
$srv=$Inenv.ConnectToServer('localhost')
$org=$srv.Organization
$ev1 = $org.Eventory
switch($action)
{
    List{$ev1.Logs}
    Dump{$ev1.Eventory}
    Add{
        $ev1.Logs.Add($logname,$dynamics_rules)
    }
    Modify{
        $log_c=$ev1.Logs.Item($logname)
        $log_c.Rules=$dynamics_rules
    }
    default{$ev1.Logs}
}
