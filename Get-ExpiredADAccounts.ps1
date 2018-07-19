Function Get-ExpiredADAccounts {

[cmdletBinding()]
Param(
[Parameter(Mandatory,Position=0)]
[string]$Server,
[Parameter(Mandatory,Position=1,ParameterSetName='HTML')]
[switch]$ToHTML,
[Parameter(Mandatory,Position =2,ParameterSetName='HTML',ValueFromPipeline)]
[string]$HTMLPath,
[Parameter(Mandatory,Position=3,ParameterSetName='CSV')]
[switch]$ToCSV,
[Parameter(Mandatory,Position=4,ParameterSetName='CSV',ValueFromPipeline)]
[string]$CSVPath
)


    
    
    Switch($PSCmdlet.ParameterSetName){

    'Html' 
        {
         
            $neverExpiresTime = 9223372036854775807

            Get-ADUser -Filter * -Properties accountExpires,msDS-UserPasswordExpiryTimeComputed |
            Where-Object { $_.accountExpires -ne $neverExpiresTime -and [datetime]::FromFileTime([int64]::Parse($_.accountExpires)) -lt (Get-Date).AddDays(10) } |
            ForEach-Object {
                [pscustomobject]@{
                'Name' = $_.SamAccountName
                'Expiration Date' = [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
                } | ConvertTo-Html -Fragment |  Add-Content -Path $HTMLPath
            
            }    
        }


    'CSV' { $neverExpiresTime = 9223372036854775807

            Get-ADUser -Filter * -Properties accountExpires,msDS-UserPasswordExpiryTimeComputed |
            Where-Object { $_.accountExpires -ne $neverExpiresTime -and [datetime]::FromFileTime([int64]::Parse($_.accountExpires)) -lt (Get-Date).AddDays(10) } |
            ForEach-Object {
                [pscustomobject]@{
                'Name' = $_.SamAccountName
                'Expiration Date' = [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
                } | Export-CSV -Path $CSVPath -Append -NoTypeInformation
            
            } 
        }
    
    }

    

 }