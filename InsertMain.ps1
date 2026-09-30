$root  = $PSScriptRoot
$depth = 3
$today = Get-Date -Format "yyyyMMdd"

$level = @(Get-Item -LiteralPath $root)
for ($i = 0; $i -lt $depth; $i++) {
    $level = @($level | ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Directory })
}

$count = 0
foreach ($target in $level) {
    $items = @(Get-ChildItem -LiteralPath $target.FullName -Directory |
               Where-Object { $_.Name -notmatch '_\d{8}$' })
    foreach ($item in $items) {
        try {
            Rename-Item -LiteralPath $item.FullName -NewName ($item.Name + '_' + $today) -ErrorAction Stop
            $count++
        } catch {
            Write-Host "FAILED: $($item.FullName)" -ForegroundColor Red
        }
    }
}
Write-Host "Renamed $count folder(s)."