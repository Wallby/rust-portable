$script:silenced=$false

function Remove-Folders()
{
    param(
        [string[]]$paths
    )
    foreach($path in $paths)
    {
        if(Test-Path $path)
        {
            Remove-Item -Recurse $path | Out-Null
        }        
    }
}
function Filter-Line()
{
    param(
        [string[]]$lines
    )
    if($silenced)
    {
        #Write-Host "Silenced..."
        return;
    }
    # For some reason rustup-init.exe produces a $null output at the end
    if(!$lines)
    {
        return
    }
    $lines | % {
        switch -Wildcard ($_.Trim())
        {
            "Rust is installed now. Great!" { $script:silenced=$true }
            default { Write-Host $_ }
        }
    }
}

try
{
    ./rustup-init.exe -y --profile minimal --no-modify-path | Filter-Line
}
catch
{
    # Keep rustup-init.exe if it failed
    Remove-Folders .cargo,.rustup
    return;
}

Remove-Item rustup-init.exe | Out-Null

New-Item -Type Directory bin | Out-Null

$programs = Get-ChildItem .cargo/bin
foreach($exe in $programs)
{
    # Double quotes "" would resolve $1 before passing to -replace
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.5#regular-expressions-substitutions
    $program = $exe -replace "(.+)\.exe", "`$1"
    
    $file = @"
@echo off
call "%~dp0\..\scripts\all"
"%~dp0\..\.cargo\bin\$program" %*
"@

    # .bat files must not be in UTF-8 BOM encoding, which is default for Out-File
    $file | Out-File "bin/$program.bat" -Encoding OEM | Out-Null
}