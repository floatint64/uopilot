param(
    [string[]]$Files
)

if (-not $Files) {
    $Files = Get-ChildItem -Path $PSScriptRoot -Filter *.obj | ForEach-Object { $_.FullName }
}

function Read-UInt16([byte[]]$b, [int]$o) { return [BitConverter]::ToUInt16($b, $o) }
function Read-UInt32([byte[]]$b, [int]$o) { return [BitConverter]::ToUInt32($b, $o) }
function Read-Int16([byte[]]$b, [int]$o) { return [BitConverter]::ToInt16($b, $o) }

function Get-CanonicalName([string]$name) {
    switch -Regex ($name) {
        '^_TEXT'  { return '.text' }
        '^_DATA'  { return '.data' }
        '^_BSS'   { return '.bss'  }
        default   { return $name }
    }
}

function Write-InlineName([byte[]]$b, [int]$o, [string]$name) {
    for ($i = 0; $i -lt 8; $i++) {
        if ($i -lt $name.Length) { $b[$o + $i] = [byte][char]$name[$i] }
        else { $b[$o + $i] = 0 }
    }
}

foreach ($file in $Files) {
    $path = (Resolve-Path -LiteralPath $file).Path
    $b = [System.IO.File]::ReadAllBytes($path)
    if ($b.Length -lt 20) { Write-Warning "skip $path (too small)"; continue }

    $numSections = Read-UInt16 $b 2
    $ptrSymTab   = Read-UInt32 $b 8
    $numSymbols  = Read-UInt32 $b 12

    # Read section header names and compute canonical names
    $canonical = @()
    for ($s = 0; $s -lt $numSections; $s++) {
        $secOff = 20 + $s * 40
        $raw = [System.Text.Encoding]::ASCII.GetString($b, $secOff, 8)
        $name = ($raw -split "`0")[0]
        $canonical += Get-CanonicalName $name
    }

    # Patch section header names inline
    for ($s = 0; $s -lt $numSections; $s++) {
        $secOff = 20 + $s * 40
        Write-InlineName $b $secOff $canonical[$s]
    }

    # Patch section symbol names inline
    $i = 0
    for ($sym = 0; $sym -lt $numSymbols; $sym++) {
        $off = $ptrSymTab + $i * 18
        if ($off + 18 -gt $b.Length) { break }
        $scl = $b[$off + 16]
        $naux = $b[$off + 17]
        $secNum = Read-Int16 $b ($off + 12)
        if ($scl -eq 3 -and $naux -eq 1 -and $secNum -ge 1 -and $secNum -le $numSections) {
            Write-InlineName $b $off $canonical[$secNum - 1]
        }
        $i += 1 + $naux
    }

    [System.IO.File]::WriteAllBytes($path, $b)
    Write-Host "patched $path"
}
