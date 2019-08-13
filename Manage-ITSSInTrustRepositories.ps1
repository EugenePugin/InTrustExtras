Param([string]$action="List",[string]$servername="localhost",[parameter(
        Mandatory         = $false,
        ValueFromPipeline = $true)]$repository,$creds)
begin{        
    try{$res=add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    }
    catch{}
    $newselectedreps=""
    $newrepositorylist=""
}
process{
    ForEach ($input in $repository) {
        $newrepositorylist+=";"+$input.Id
        $newselectedreps+=",{Name:"""+$input.Name+""",Id:"""+$input.Id+"""}"
    }
}
end{
    #if($creds){}
    #else{$creds=Get-Credential}
    switch($action)
    {
        List{
                Invoke-RestMethod -method GET -Uri https://$servername/api/1.0/settings -UseDefaultCredentials | select -expand connectors| select -expand InTrust | select -expand parameters | select -expand selectedReps
            }
        Search{
                Invoke-RestMethod -method PUT -Uri https://$servername/api/1.0/connectors/InTrust/repositories -UseDefaultCredentials  | select -expand repositories
            }
        Add{

            if($repository)
            {
                $repositorylist=Invoke-RestMethod -method GET -Uri https://$servername/api/1.0/settings -UseDefaultCredentials | select -expand connectors| select -expand InTrust | select -expand parameters | select -expand repository
                $selectedreps= Invoke-RestMethod -method GET -Uri https://$servername/api/1.0/settings -UseDefaultCredentials | select -expand connectors| select -expand InTrust | select -expand parameters | select -expand selectedReps
                $repositorylist=$repositorylist+$newrepositorylist
                $selectedreps=$selectedreps.Replace("]",$newselectedreps+"]")
                $InTrustConnectorSettings=@{repository=$repositorylist;selectedReps=$selectedreps} | ConvertTo-Json
                $body="{connectors:{InTrust:{parameters:{repository:"""+$repositorylist+""",selectedReps:"+$selectedreps+"}}}}"
                #$body
                Invoke-RestMethod -method PUT -Body $body -Uri https://$servername/api/1.0/settings -UseDefaultCredentials
            }
        }
        Remove{
            echo "Not Implemented"
        }
        default{Invoke-RestMethod -method GET -Uri https://$servername/api/1.0/settings -UseDefaultCredentials | select -expand connectors| select -expand InTrust | select -expand parameters | select -expand selectedReps}
    }
}