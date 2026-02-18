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
        Write-Host "Silenced...";
        return;
    }
    # For some reason rustup-init.exe produces a $null output at the end
    if(!$lines)
    {
        return;
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
    .\rustup-init.exe -y --profile minimal --no-modify-path | Filter-Line
}
catch
{
    # Keep rustup-init.exe if it failed
    Remove-Folders .cargo,.rustup
    return;
}

Remove-Item rustup-init.exe | Out-Null