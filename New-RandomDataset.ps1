Function New-RandomDataset {
    <#
        .SYNOPSIS
        Generate random data for use in testing, demonstrations, etc.
        .DESCRIPTION
        Using the NameIT module, generate random data exported to a CSV file
        .PARAMETER Count
        The number of items in your dataset
        .PARAMETER CSVPAth
        The path to store the CSV file
        .PARAMETER Filename
        The filename of the csv file
        .PARAMETER AllowClobber
        If used, will delete the found CSV file before continuing
        .EXAMPLE
        New-RandomDataset -Count 10 -CSVPath C:\temp -Filename names.csv
        .EXAMPLE
        New-RandomDataset -Count 100 -CSVPath C:\data Filename demodata.csv -AllowClobber
        .EXAMPLE
        $props = @{
            'Count' = 100
            'CSVPath' = "C:\temp"
            'Filename' = "randomdata.csv"
        }
        New-RandomDataset @props
        .NOTES
        A great write-up on the NameIT module can be found here: https://kevinmarquette.github.io/2018-07-09-Powershell-NameIt-generate-random-data/
    #>

    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [int]$Count,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$CSVPath,
        [Parameter(Mandatory)]
        [String]$FileName,
        [Parameter(Mandatory = $false)]
        [switch]$AllowClobber
    )

    #region check for module, and install if missing
    If(!(Get-Module -ListAvailable -Name NameIT)){

    Install-Module NameIT -Force

    }

    Else {

        Import-Module NameIT -Force
    }
    #endregion
    
    #If you wish to overwrite a file, use check for AllowClobber
    If($AllowClobber){

        If(Test-Path $CSVPath\$FileName){

            Remove-Item $CSVPath\$FileName -Force

        }
    }

    $data = (1..$Count) | Foreach-Object {person}
    $dept = @('Sales', 'HR', 'Marketing','Engineering', 'IT')

    #region generate random data
    Foreach ($d in $data){

        [PSCustomObject]@{
            'FirstName' = $d.Split(' ')[0]
            'LastName' = $d.Split(' ')[1]
            'Department' = Get-Random $dept
            'Office' = cities
        } | Export-CSV "$CSVPath\$FileName" -notype -Append

    }
    #endregion
}