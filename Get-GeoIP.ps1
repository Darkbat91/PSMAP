Function Get-GeoIP {
[cmdletbinding()]
param (
    [parameter(ValueFromPipeline)]
    [string[]]$IP 
)
Begin
{
   $return = @()
}
PROCESS
{
 
    foreach($item in $IP)
        {
        try
           { # Try sending whatever we have
                $result = Invoke-WebRequest "http://freegeoip.net/xml/$($item)" -ErrorAction STOP
            }
        catch  
            {
            Write-Verbose "Well $Item didnt work lets try resolving it local"
                #REsolve the IP local add it to an array and take the first element incase we have multiple return
            [array]$item = (([System.Net.DNS]::GetHostAddresses("$item")).ipaddresstostring)
            try
                {
                $result = Invoke-WebRequest "http://freegeoip.net/xml/$($item[0])" -ErrorAction STOP
                }
            catch
                {
                Write-Warning "Cant resolve $($item[0])"
                }
            }
        $result = [xml]$result.Content
        $val = @{
            Name = $item
            Latitude = $result.Response.latitude
            Longitude = $result.Response.longitude
        }
        $return = new-object -TypeName PSOBJECT -Property $val
        Write-Output -InputObject $return
        }
}
END
{

}
}