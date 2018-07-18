Function New-BulkdADImport {
    [cmdletBinding()]
    Param(
    [Parameter(Mandatory,Position=0)]
    [String]$CSVFile,
    [Parameter(Mandatory=$false,Position=1)]
    [Switch]$ProvisionHomeDrive,
    [Parameter(Mandatory=$false,Position=2)]
    [Switch]$ProvisionExchange
    )

    If(!(Get-Module -ListAvailable -Name NTFSSecurity)){
        Install-Module NTFSSecurity -Force

    }

    Else{

        Import-Module NTFSSecurity

    }

    $users = Import-CSV $csvfile
    
    Foreach($user in $users){

        $props = @{
                'Name' = "$($user.FirstName).$($user.LastName)"
                'GivenName' = $user.FirstName
                'Surname' = $user.LastName
                'SamAccountName' = "$($user.FirstName).$($user.LastName)"
                'Email' = "$($user.Firstname).$($user.Lastname)@testlab.ad"
                'HomeDrive' = "\\client\home\$($user.FirstName).$($user.LastName)"
                'Enabled' = $true
                'AccountPassword' = $("P@ssw0rd!" | ConvertTo-SecureString -AsPlainText -Force)
                'ChangePasswordAtLogon' = $true
                'Path' = "OU=Employees,DC=testlab,DC=ad"

                }
        New-ADUser @props
        
        If($ProvisionHomeDrive){
            If(!(Test-Path "C:\Home\$($user.FirstName).$($user.LastName)")){
                
                New-Item -ItemType Directory -Path C:\Home -Name "$($user.FirstName).$($user.LastName)" >$null
                
            }

            Add-NTFSAccess -Path "C:\Home\$($user.FirstName).$($user.LastName)" -Account "TESTLAB\$($user.FirstName).$($user.LastName)" -AccessRights FullControl >$null
    
    
    
        }
        If($ProvisionExchange){}#add code to enable mailox in exchange
   }
}