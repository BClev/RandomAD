Function Move-DisabledUsersWithPipeline.ps1 {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [String]$CSVPath
    )

    Get-ADUser -Filter "Enabled -eq $false" -Properties email, SamAccountName, memberof | Foreach-object {

        Foreach ($group in ($_.memberOf)) {
            Remove-ADGroupMember -Identity $group -Members $_.SamAccountName -Confirm:$false
        }

        Move-ADObject -Identity $_ -TargetPath 'OU=FormerEmployees,DC=testlab,DC=ad'

        [pscustomobject]@{
            'User'           = $_.SamAccountName
            'Status'         = $_.Enabled
            'Email Address'  = $_.email
            'Groups Removed' = $true
        }
    } | Export-CSV -Path $CSVPath -NoTypeInformation -Append
}