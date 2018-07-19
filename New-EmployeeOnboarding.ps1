Function New-EmployeeOnboarding {
    <#
        .SYNOPSIS
        Onboard new users from CSV File. Use Switches to control extra behavior

        .PARAMETER CSVFile
        The CSV containing new user data

        .PARAMETER ProvisionHomeDrive
        Switch to control whether a file share is created for the user

        .PARAMETER ProvisionExchange
        Switch to control whether an exchange mailbox is created for the user

        .EXAMPLE
        New-EmployeeOnboarding -CSVFile C:\data\employees.csv -ProvisionHomeDrive

        .EXAMPLE
        New-ExmployeeOnboarding -CSVFile C:\data\employees.csv -ProvisionHomeDrive -ProvisionExchange

    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [String]$CSVFile,
        [Parameter(Mandatory = $false, Position = 1)]
        [Switch]$ProvisionHomeDrive,
        [Parameter(Mandatory = $false, Position = 2)]
        [Switch]$ProvisionExchange
    )

    If (!(Get-Module -ListAvailable -Name NTFSSecurity)) {
        Install-Module NTFSSecurity -Force

    }

    Else {

        Import-Module NTFSSecurity

    }

    $users = Import-CSV $csvfile

    Foreach ($user in $users) {

        $props = @{
            'Name'            = "$($user.FirstName).$($user.LastName)"
            'GivenName'       = $user.FirstName
            'Surname'         = $user.LastName
            'SamAccountName'  = "$($user.FirstName).$($user.LastName)"
            'Email'           = "$($user.Firstname).$($user.Lastname)@testlab.ad"
            'HomeDrive'       = "\\client\home\$($user.FirstName).$($user.LastName)"
            'Enabled'         = $true
            'AccountPassword' = $("P@ssw0rd!" | ConvertTo-SecureString -AsPlainText -Force)
            'Path'            = "OU=Employees,DC=testlab,DC=ad"

        }
        New-ADUser @props

        If ($ProvisionHomeDrive) {
            If (!(Test-Path "C:\Home\$($user.FirstName).$($user.LastName)")) {

                New-Item -ItemType Directory -Path C:\Home -Name "$($user.FirstName).$($user.LastName)" >$null

            }

            $ntfsParams = @{
                'Path'         = "C:\Home\$($user.FirstName).$($user.LastName)"
                'Account'      = "DOMAIN\$($user.FirstName).$($user.LastName)"
                'AccessRights' = 'FullControl'
            }

            Add-NTFSAccess @ntfsParams >$null # >$null is the same as | Out-Null, only slightly faster

        }


        If ($ProvisionExchange) {

            #add code to enable mailox in exchange

        }
    }

}