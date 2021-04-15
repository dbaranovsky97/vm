param (
    [string]$Use,
    [switch]$List
);

function Save-OriginVersion() {
    if (Test-Path ".\public_origin") {
        Remove-Item ".\public_origin";
    }

    New-Item "public_origin" -ItemType "directory" -ErrorAction Stop | Out-Null;
    Copy-Item ".\public\*" ".\public_origin\" -Recurse -Force  -ErrorAction Stop | Out-Null;
    Write-Output "origin saved";

}

function Get-CurrentVersion() {
    if (Test-Path ".\vmcv.txt") {
        return Get-Content ".\vmcv.txt";
    }
    
    return "origin";
}

function Set-CurrentVersion($version) {
    if (!(Test-Path ".\vmcv.txt")) {
        New-Item  ".\vmcv.txt" -ItemType "file" -ErrorAction Stop | Out-Null;
    }

    Set-Content "vmcv.txt" $version;
}

function Use-Version($newVersion) {
    $currentVersion = Get-CurrentVersion;
    if ($newVersion -eq $currentVersion) {
        Write-Output "Already used";
        return;
    }

    if (($currentVersion -eq "origin") -and ($newVersion -ne "origin")) {
        Save-OriginVersion;
    }

    Remove-Item ".\public" -Recurse -ErrorAction Stop | Out-Null;
    Copy-Item -Path (".\public_" + $newVersion) -Destination ".\public\" -Recurse -ErrorAction Stop | Out-Null;
    
    Set-CurrentVersion -version $newVersion;

    if ($newVersion -eq "origin") {
        Remove-Item ".\public_origin" -Recurse -ErrorAction SilentlyContinue | Out-Null;
        Remove-Item ".\vmcv.txt" -ErrorAction SilentlyContinue | Out-Null;
    }

    Write-Output "Current version: $($newVersion)";
}


if ($Use) {
    Use-Version -newVersion $Use;
} elseif ($List) {
    $versions = Get-ChildItem "public_*" | 
        % { 
            $_.Name.Replace("public_", "") 
        } | 
        ? {
            $_ -ne "origin"
        };

    Write-Output "All versions:";
    Write-Output "origin";
    Write-Output $versions;
    Write-Output "Current version: $(Get-CurrentVersion)";
} else {
    Write-Output "Current version: $(Get-CurrentVersion)";
}