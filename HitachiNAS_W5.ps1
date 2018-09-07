param(
  [string]$action,
  [string]$logname="FS"
  )

$rules="<FieldInfo>
            <EventRules>
                <Event EventID = ""560"">
                    <Field Name=""Who"" CopyFrom=""UserName""></Field>
                    <Field Name=""What"" Constant=""File opened""></Field>
                    <Field Name=""Object_Type"" Constant=""File""></Field>
                    <Field Name=""Object_Name"" Index = ""3""></Field>
                    <Field Name=""Where"" CopyFrom=""Computer""></Field>
                </Event>
                <Event EventID = ""562"">
                    <Field Name=""Who"" CopyFrom=""UserName""></Field>
                    <Field Name=""What"" Constant=""File open handle closed""></Field>
                    <Field Name=""Object_Type"" Constant=""File""></Field>
                    <Field Name=""Where"" CopyFrom=""Computer""></Field>
                    <Field Name=""New_Name"" Index = ""4""></Field>
                </Event>
                <Event EventID = ""563"">
                    <Field Name=""Who"" CopyFrom=""UserName""></Field>
                    <Field Name=""What"" Constant=""File delete requested""></Field>
                    <Field Name=""Object_Type"" Constant=""File""></Field>
                    <Field Name=""Object_Name"" Index = ""3""></Field>
                    <Field Name=""Where"" CopyFrom=""Computer""></Field>
                </Event>
                <Event EventID = ""563"">
                    <Field Name=""Who"" CopyFrom=""UserName""></Field>
                    <Field Name=""What"" Constant=""File delete handle closed""></Field>
                    <Field Name=""Object_Type"" Constant=""File""></Field>
                    <Field Name=""Where"" CopyFrom=""Computer""></Field>
                </Event>
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
        $ev1.Logs.Add($logname,$rules)
    }
    Modify{
        $log_c=$ev1.Logs.Item($logname)
        $log_c.Rules=$rules
    }
    Delete{
        $ev1.Logs.Remove($logname)
    }
    default{$ev1.Logs}
}