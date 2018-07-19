Function Get-ExpiredADAccounts {
    <#
    .SYNOPSIS
    Retrieves a list of accounts whose passwords will expire in the next x Days.

    .PARAMETER Server
    The DC you wish to query against

    .PARAMETER Days
    The amount of time you wish to look ahead too.

    .PARAMETER ToHTML
    Specifies the output be in HTML format

    .PARAMETER HTMLPath
    The filepath where the report will be saved in HTML format

    .PARAMETER ToCSV
    Specifies the output be in CSV format

    .PARAMETER CSVPath
    The filepath where the report will be saved in CSV format

    .EXAMPLE
    Get-ExpiredADAccounts -Server dc.contoso.com -Days 30 -ToHTML -HTMLPath D:\reports\expired_accounts.htm

    .EXAMPLE
    Get-ExpiredADAccounts -Server dc.contoso.com -Days 30 -ToCSV -CSVPath D:\reports\expired_accounts.csv

#>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Server,
        [Parameter(Mandatory, Position = 1)]
        [string]$Days,
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'HTML')]
        [switch]$ToHTML,
        [Parameter(Mandatory, Position = 2, ParameterSetName = 'HTML', ValueFromPipeline)]
        [string]$HTMLPath,
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'CSV')]
        [switch]$ToCSV,
        [Parameter(Mandatory, Position = 2, ParameterSetName = 'CSV', ValueFromPipeline)]
        [string]$CSVPath
    )

    #Parameter sets hide other cmdlets from each other, which makes things super flexible.
    Switch ($PSCmdlet.ParameterSetName) {
        #Depending on the parameter set called, perform an action

        'Html' {

            $neverExpiresTime = 9223372036854775807 #do not modify this value

            Get-ADUser -Filter * -Properties accountExpires, msDS-UserPasswordExpiryTimeComputed |
                Where-Object { $_.accountExpires -ne $neverExpiresTime -and [datetime]::FromFileTime([int64]::Parse($_.accountExpires)) -lt (Get-Date).AddDays($Days) } |
                ForEach-Object {
                [pscustomobject]@{
                    'Name'            = $_.SamAccountName
                    'Expiration Date' = [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
                } | ConvertTo-Html -Fragment |  Add-Content -Path $HTMLPath

            }#custom object

        }#html item


        'CSV' {
            $neverExpiresTime = 9223372036854775807 #do not modify this value

            Get-ADUser -Filter * -Properties accountExpires, msDS-UserPasswordExpiryTimeComputed |
                Where-Object { $_.accountExpires -ne $neverExpiresTime -and [datetime]::FromFileTime([int64]::Parse($_.accountExpires)) -lt (Get-Date).AddDays(10) } |
                ForEach-Object {
                [pscustomobject]@{
                    'Name'            = $_.SamAccountName
                    'Expiration Date' = [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
                } | Export-CSV -Path $CSVPath -Append -NoTypeInformation

            }
        } #csv switch item
    }#switch

}#function