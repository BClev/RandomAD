Function Invoke-EmployeeSeparation {
    <#
        .SYNOPSIS
        Removes a User's groups and if selected, removes their Home Directory

        .PARAMETER CSVPath
        A CSV of Users to process

        .PARAMETER RemoveHomeDir
        Switch to toggle deleting home directories

        .EXAMPLE
        Invoke-EmployeeSeparation -CSVPath D:\Data\UsersToSeparate.csv

        .EXAMPLE
        Invoke-EmployeeSeparation -CSVPath D:\Data\UsersToSeparate.csv -RemoveHomeDir

        .EXAMPLE
        $SeparationParams = @{
            'CSVPath' = "D:\Data\UsersToSeparate.csv"
            'RemoveHomeDir' = $true
        }

        Invoke-EmployeeSeparation @SeparationParams
    #>
    [cmdletBinding()]
    Param(
        [parameter(Mandatory, Position = 0)]
        [string]$CSVPath,
        [parameter(Position = 1)]
        [switch]$RemoveHomeDir
    )

    $Units = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -notmatch "FormerEmployees"} |
             Select-Object -ExpandProperty DistinguishedName

    Foreach ($ou in $Units) {

        Write-Verbose "Working in $ou"

        $adProps = @{
            'Properties' = @('mail', 'memberOf', 'HomeDrive')
            'SearchBase' = $ou
        }

        $users = Get-ADUser -Filter {Enabled -eq $false} @adProps

        Write-Verbose "Found $($users.Count) disabled users in $ou, processing"

        $users |

        ForEach-Object {

            Foreach ($group in $_.memberOf) {
                If ($group -notmatch 'Domain Users') {

                    Remove-ADGroupMember -Identity $group -Members $_.SamAccountName -Confirm:$false -Verbose

                }
            }

            Add-ADGroupMember -Identity Disabled -Members $_.SamAccountName -Verbose
            Move-ADObject -Identity $_.DistinguishedName -TargetPath 'OU=FormerEmployees,DC=testlab,DC=ad' -Verbose

            If ($RemoveHomeDir) {

                #It might be best to zip the directory and copy it to long term storage first. CYA.
                If ($PSVersionTable.PSVersion.Major -gt 4) {

                    Compress-Archive -Path $_.HomeDrive -DestinationPath D:\ArchivedUsers\
                }

                Else {
                    $Source = $_.HomeDrive
                    $Destination = D:\ArchivedUsers
                    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
                    [io.Compression.FileSystem]::CreateFromDirectory($Source,$Destination)
                }
                Remove-Item -Path "$($_.HomeDrive)" -Force -Confirm:$false -Verbose

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