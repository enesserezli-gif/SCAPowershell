param(
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [int]$WarningThreshold = 20,
    [int]$CriticalThreshold = 10,
    [string]$ReportPath = (Join-Path $env:USERPROFILE "Desktop\DiskHealthReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv")
)

$results = foreach ($computer in $ComputerName) {

    write-Host ""
    write-Host "Checking disk health on $computer..." -ForegroundColor Cyan

    try {
        if ($computer -eq $env:COMPUTERNAME -or $computer -eq 'Localhost' -or $computer -eq '.') {
            $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
        }
        else {
            $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $computer -ErrorAction Stop
        }
    }
    catch {
        Write-Host "Could not reach $computer`: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    if (-not $drives) {
        Write-Host "No fixed drives found on $computer" -ForegroundColor Yellow
        continue
    }

    foreach ($drive in $drives) {
        $sizeGB = [math]::Round($drive.Size / 1GB, 2)
        $freeGB = [math]::Round($drive.FreeSpace / 1GB, 2)
        $percentFree = [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 1)

        if ($percentFree -lt $CriticalThreshold) {
            $status = "Critical"
            $color = "red"
        }
        elseif ($percentFree -lt $WarningThreshold) {
            $status = "Warning"
            $color = "yellow"
        }
        else {
            $status = "Healthy"
            $color = "green"
        }

        write-Host (" Drive {0} - {1} GB free of {2} GB ({3}% free) - {4}" -f `
        $drive.DeviceID, $freeGB, $sizeGB, $percentFree, $status) -ForegroundColor $color

        [PSCustomObject]@{
            ComputerName = $computer
            Drive = $drive.DeviceID
            SizeGB = $sizeGB
            FreeGB = $freeGB
            PercentFree = $percentFree
            Status = $status
        }
    }
}

if ($results) {
    $results | Export-Csv -Path $ReportPath -NoTypeInformation
    Write-Host ""
    Write-Host "Report saved to $ReportPath" -ForegroundColor Cyan
}
else {
    Write-Host ""
    Write-Host "No results to report" -ForegroundColor Yellow
}