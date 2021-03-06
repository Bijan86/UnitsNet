<#
.SYNOPSIS
    Update AssemblyInfo.cs files.
.DESCRIPTION
    Sets the AssemblyVersion and AssemblyFileVersion of AssemblyInfo.cs files.
.EXAMPLE
  Set new version.
  powershell UpdateAssemblyInfo.ps1 1.2.3.4
  
.NOTES
    Author: Andreas Gullberg Larsen
    Date:   May 2, 2014
    Based on original work by Luis Rocha from: http://www.luisrocha.net/2009/11/setting-assembly-version-with-windows.html
#>
[CmdletBinding()]
Param(
[parameter(mandatory=$true)]
[string]$setVersion
)

$root=Resolve-Path "$PSScriptRoot\.."

#-------------------------------------------------------------------------------
# Displays how to use this script.
#-------------------------------------------------------------------------------
function Help {
  "Sets the AssemblyVersion and AssemblyFileVersion of AssemblyInfo.cs files`n"
  ".\UpdateAssemblyInfo.ps1 [VersionNumber]`n"
  "   [VersionNumber]     The version number to set, for example: 1.1.9301.0"
}

#-------------------------------------------------------------------------------
# Description: Sets the AssemblyVersion and AssemblyFileVersion of 
#              AssemblyInfo.cs files.
#
# Author: Andreas Larsen
# Version: 1.0
#-------------------------------------------------------------------------------
function Update-AssemblyInfoFiles ([string] $version) {
    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $assemblyVersion = 'AssemblyVersion("' + $version + '")';
    $fileVersion = 'AssemblyFileVersion("' + $version + '")';
    
    Get-ChildItem $root -r | Where { $_.PSChildName -match "^AssemblyInfo\.cs$"} | ForEach-Object {
        $filename = $_.Directory.ToString() + '\' + $_.Name
        $filename + ' -> ' + $version
        
        # If you are using a source control that requires to check-out files before 
        # modifying them, make sure to check-out the file here.
        # For example, TFS will require the following command:
        # tf checkout $filename
    
        (Get-Content $filename -Encoding UTF8) | ForEach-Object {
            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
            % {$_ -replace $fileVersionPattern, $fileVersion }
        } | Set-Content $filename -Encoding UTF8
    }    
}

try {
  "Updating assembly info to version: $setVersion"
  ""
  Update-AssemblyInfoFiles $setVersion
}
catch {
  $myError = $_.Exception.ToString()
    Write-Error "Failed to update AssemblyInfo files: `n$myError' ]"
    exit 1
}