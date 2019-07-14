 # InTrust webhook for Service Now integration
# Version: 1.0
# Author: Quest.
 
#Parameters to be included in script call
param (
    [string]$InTrust_message = "Test Incident",
    [string]$sn_uri = "https://YOURNODE.service-now.com/api/now/table/incident",
    [string]$sn_user_id = "",
    [string]$sn_passwd = ""
)
  
Try
{
 
 
# Getting first line of InTrust Alert description to be reported as SN message
if ($InTrust_message.Length -gt 0)
{
    # if InTrust Alert message has multiple lines we take first line for ticket title
    if ($InTrust_message.IndexOf("|") -gt 0)
    {           
        $sn_message = $InTrust_message.Substring(0,$InTrust_message.IndexOf("|"))
    }
    # else we take whole message
    else
    {       
        $sn_message = $InTrust_message;
    }
}
     
 
# Preparing ServiceNow JSON structure for events
$SN_json_text = @"
{
    'category': 'AccountUse',
    'impact': '3',
    'urgency': '3',
    'priority': '5',
    'short_description': '',
    'comments': '',
    'correlation_id' : ''
}
"@
 
#Populating JSON object with data from DCRUM
$SN_json_object = $SN_json_text | ConvertFrom-Json
$SN_json_object.comments = $InTrust_message;
$SN_json_object.short_description = $sn_message;
$sn_timestamp = Get-Date -format s
$SN_json_object.correlation_id =[guid]::NewGuid().ToString()
 
#Converting back JSON object to text format
$SN_json_text = $SN_json_object | ConvertTo-Json
 
# Preparing HTTP request header
$RestApi_WebRequest = [System.Net.WebRequest]::Create($sn_uri)   
[string]$authInfo = $sn_user_id + ":" + $sn_passwd
[string]$authInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($sn_user_id + ':' + $sn_passwd))
$RestApi_webRequest.Headers.Add("AUTHORIZATION","Basic $authinfo")
$RestApi_WebRequest.ContentType = "application/json"
$RestApi_WebRequest.Accept      = "application/json"
$RestApi_WebRequest.Method      = "POST"
$buffer = [System.Text.Encoding]::UTF8.GetBytes($SN_json_text)
 
# Preparing HTTP request body
$RequestStream = $RestApi_WebRequest.GetRequestStream()
$RequestStream.Write($buffer, 0, $buffer.Length)
$RequestStream.Flush()
$RequestStream.Close()
 
# Sending HTTP request
$RestApi_Response = $RestApi_WebRequest.GetResponse()
 
# Parsing HTTP Response
$responseStream = $RestApi_Response.GetResponseStream()
$ResponseReader = [System.IO.StreamReader]($responseStream)
$RestApi_ResponseBody =  $ResponseReader.ReadToEnd()
$responseStream.Close()    
 
#$RestApi_ResponseBody
     
}
# In case of error writing exception details to log file
Catch
{

           $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
           $time=Get-Date
           "$time error
           $ErrorMessage
           $FailedItem" | Add-Content service-now.log
} 
