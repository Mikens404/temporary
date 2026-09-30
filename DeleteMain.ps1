$root = $PSScriptRoot
$cutoff = (Get-Date).AddMonths(-6).ToString("yyyyMMdd")
$stamp12 = Get-Date -Format "yyyyMMddHHmm"

$sh = New-Object -ComObject Shell.Application

$depth = 3
$level = @(Get-Item -LiteralPath $root)
for ($i = 0; $i -lt $depth; $i++) {
    $level = @($level | ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Directory })
}
$targetFolders = $level

$total = $targetFolders.Count
Write-Host "Found $total target folder(s)." -ForegroundColor Yellow
Write-Host ""

$index = 0
foreach ($folder in $targetFolders) {
    $index++
    $folderPath = $folder.FullName
    $hasDeleted = $false

    Write-Host "[$index/$total] Processing: $($folder.FullName.Substring($root.Length + 1))" -NoNewline

    Get-ChildItem -LiteralPath $folderPath | Where-Object { $_.Name -match '_(\d{8})(\.[^.]*)?$' } | ForEach-Object {
        $fileStamp = $Matches[1]
        if ($fileStamp -le $cutoff) {
            Remove-Item -LiteralPath $_.FullName -Recurse -Force
            if (-not (Test-Path -LiteralPath $_.FullName)) {
                $hasDeleted = $true
            }
        }
    }

    if ($hasDeleted) {
        Start-Sleep -Milliseconds 200
    }

    $sep = if ($hasDeleted) { "-" } else { "_" }
    $parent = $folder.Parent.FullName
    $name = $folder.Name

    $base = ($name -replace '[-_]\d{12}$', '') -replace '-$', ''
    $newName = $base + $sep + $stamp12

    if ($newName -ne $name) {
        $ws = @()
        foreach ($w in @($sh.Windows())) {
            try {
                $p = $w.Document.Folder.Self.Path
                if (($p -eq $folderPath) -or $p.StartsWith($folderPath + '\')) {
                    $w.Navigate($parent)
                    $ws += $w
                }
            } catch {}
        }

        $ok = $false
        for ($i = 0; $i -lt 10; $i++) {
            try {
                Rename-Item -LiteralPath $folderPath -NewName $newName -ErrorAction Stop
                $ok = $true
                break
            } catch {
                $err = $_
                Start-Sleep -Seconds 1
            }
        }


        if ($ok) {
            $newFolderPath = Join-Path -Path $parent -ChildPath $newName
            foreach ($w in $ws) {
                try { $w.Navigate($newFolderPath) } catch {}
            }
            Write-Host " -> Renamed to: $newName" -ForegroundColor Green
        } else {
            Write-Host " -> FAILED" -ForegroundColor Red
            $err | Out-File -Append (Join-Path -Path $env:TEMP -ChildPath "rename_err.log")
        }
    } else {
        Write-Host " -> No rename needed" -ForegroundColor Gray
    }
}

