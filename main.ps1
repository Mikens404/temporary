$root = $PSScriptRoot
$cutoff = (Get-Date).AddMonths(-6).ToString("yyyyMMdd")
$stamp12 = Get-Date -Format "yyyyMMddHHmm"

$sh = New-Object -ComObject Shell.Application

$targetFolders = Get-ChildItem -Path $root -Directory | ForEach-Object {
    Get-ChildItem -Path $_.FullName -Directory
}

$total = $targetFolders.Count
Write-Host "Found $total target folder(s)." -ForegroundColor Yellow
Write-Host ""

$index = 0
foreach ($folder in $targetFolders) {
    $index++
    $folderPath = $folder.FullName
    $hasDeleted = $false

    Write-Host "[$index/$total] Processing: $($folder.Parent.Name)\$($folder.Name)" -NoNewline

    Get-ChildItem -Path $folderPath | Where-Object { $_.Name -match '_(\d{8})(\.[^.]*)?$' } | ForEach-Object {
        $fileStamp = $Matches[1]
        if ($fileStamp -le $cutoff) {
            Remove-Item -Path $_.FullName -Recurse -Force
            if (-not (Test-Path -Path $_.FullName)) {
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

