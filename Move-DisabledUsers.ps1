Function Move-DisabledUsers {
    [cmdletbing()]
    Param()

    $disabledUsers = Get-ADUser -Filter { Enabled -eq $false } -Properties email,SamAccountName, memberof | Select-Object SamAccountName, Email, memberof

    Foreach ($user in $disabledUsers) {

        Foreach ($m in ($user.memberof)) {
            Remove-ADGroupMember -Identity $($m -replace "(CN=)(.*?),.*", '$2') -Members $user.SamAccountName

        }

        Move-ADObject -Identity $user -TargetPath "OU=FormerEmployees,DC=testlab,DC=ad"

        [pscustomobject]@{
            'User'           = $user.SamAccountName
            'Status'         = $user.Enabled
            'Email Address'  = $user.email
            'Groups Removed' = $true
        } | Export-CSV -Path 'C:\data\DisabledUserCleanup.csv' -NoTypeInformation -Append
    }

}