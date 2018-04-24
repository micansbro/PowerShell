<#
.DESCRIPTION
This function returns the HTTP status code from a URL
.EXAMPLE
Get-UrlStatusCode www.server.com
.EXAMPLE
$URLs = @('www.server.com','www.newsite.com')
Get-UrlStatusCode $URLs
#>

function Get-UrlStatusCode([string[]] $Url)
    {
        $allObj = New-Object System.Collections.ArrayList

        foreach ($l in $Url) {

            $obj = New-Object system.object
            $obj | Add-Member -type NoteProperty -Name 'Url' -Value $l

            $code = try
                    {
                        (Invoke-WebRequest -Uri $l -UseBasicParsing -DisableKeepAlive -Method HEAD).StatusCode
                    }
                    catch [Net.WebException]
                    {
                        [int]$_.Exception.Response.StatusCode
                    }
            $obj | Add-Member -Type NoteProperty -Name 'StatusCode' -Value $code
            [void]$allObj.Add($obj)
        }
        $allObj
}