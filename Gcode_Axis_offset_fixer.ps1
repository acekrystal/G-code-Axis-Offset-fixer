# Note: When executing this script the new gcode will be written to host and copied to clip board automatically.

## Parameters

[string] $InputFilePath  = "C:\AcEcloud\20-Projecten-AcE\3D CNC\Output files\1099-PreDrill Wood Bed.txt"    # Example: 'C:\temp\gcode.txt'
[string] $NewFilePath    = ''    # Set value if you want to store the console output to file.
[double] $IncreaseZ      = 4.6   # Example: 4.6

## Init
$Code    = Get-Content $InputFilePath
$Regex   = '(?<Pre>.*Z)(?<Z>(-)?\d{1,3}(\.)?\d{0,3})(?<Post>.*)'
$NewCode = @()
$Culture = New-Object System.Globalization.CultureInfo("en-US")

## Execution

foreach ($Line in $Code){
    if ($Line -match $Regex){
        
        $Match = $Line | Select-String -Pattern $Regex
        
        $NewZ = [double]($Match.Matches.Groups | Where-Object {$_.Name -eq 'Z'}).value
        $NewZ = $NewZ + $IncreaseZ
        $NewZ = $NewZ.ToString($Culture)

        $NewCode += '{0}{1}{2}' -f  ($Match.Matches.Groups | Where-Object {$_.Name -eq 'Pre'}).value, 
                                    $NewZ, 
                                    ($Match.Matches.Groups | Where-Object {$_.Name -eq 'Post'}).value 
        continue
    } 

    $NewCode += $Line
}

$NewCode | Write-Host -ForegroundColor Green

## Set Clipboard
Set-Clipboard -Value ($NewCode | Out-String)

## Save new file
if(![string]::IsNullOrEmpty($NewFilePath)){
   $NewCode | Out-File -FilePath $NewFilePath -Force
}
