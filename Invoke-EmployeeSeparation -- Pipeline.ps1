Function Invoke-EmployeeSeparation {
    [cmdletBinding()]
    Param(
    [parameter(Mandatory,Position=0)]
    [string]$CSVPath,
    [parameter(Position=1)]
    [switch]$RemoveHomeDir
    )

    $Units = Get-ADOrganizationalUnit -Filter * | Where {$_.DistinguishedName -notmatch "FormerEmployees"} | Select -ExpandProperty DistinguishedName

    Foreach($ou in $Units){

        Write-Verbose "Working in $ou"
        
        $users = Get-ADUser -Filter {Enabled -eq $false} -Properties DistinguishedName, mail, SamAccountName, memberof -SearchBase $ou

        Write-Verbose "Found $($users.Count) disabled users in $ou, processing"
        
        $users |
    
        ForEach-Object {

            Foreach ($group in $_.memberOf) {
                If($group -notmatch 'Domain Users'){
        
                Remove-ADGroupMember -Identity $group -Members $_.SamAccountName -Confirm:$false -Verbose
        
                }
        
            }

                Add-ADGroupMember -Identity Disabled -Members $_.SamAccountName -Verbose
            

                Move-ADObject -Identity $_.DistinguishedName -TargetPath 'OU=FormerEmployees,DC=testlab,DC=ad' -Verbose
            
                If($RemoveHomeDir){
                
                    Remove-Item -Path "C:\Home\$($_.SamAccountName)" -Force -Confirm:$false -Verbose
                
                }

                [pscustomobject]@{
                    'User'           = $_.SamAccountName
                    'Status'         = 'Disabled'
                    'Email Address'  = $_.mail
                    'Groups Removed' = $true
                } | Export-CSV -Path $CSVPath -NoTypeInformation -Append -Verbose #User loop 
            
        }#pipeline
    
        Write-Verbose "Finished processing on $ou"

    }#ou

}#function