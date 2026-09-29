@echo off
setlocal

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "RN_ROOT=%ROOT%"

powershell -NoProfile -Command "$r=$env:RN_ROOT; $out=Join-Path $r 'deleted_list.txt'; $rows=@(Get-ChildItem -LiteralPath $r -Directory -Recurse -Force | Where-Object { $_.Name -match '-\d{12}$' } | ForEach-Object { [pscustomobject]@{ Group=$_.Parent.FullName.Substring($r.Length).TrimStart('\'); Name=($_.Name -replace '-\d{12}$','') } }); if($rows.Count -gt 0){ $lines=@(); foreach($g in ($rows | Group-Object Group)){ $lines += ('[' + $g.Name + ']'); foreach($item in $g.Group){ $lines += ('  ' + $item.Name) }; $lines += '' }; Set-Content -LiteralPath $out -Value $lines -Encoding UTF8; Write-Host ('Done: ' + $rows.Count + ' folders -> ' + $out) } else { Write-Host 'No matching folders.' }"

pause