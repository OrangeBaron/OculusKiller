# ===========================
# OculusKiller Auto-Restore Watcher
# ===========================

$LogFile = "C:\OculusKiller\log.txt"
$SourceFile = "C:\OculusKiller\OculusDash.exe"
$TargetFile = "C:\Program Files\Oculus\Support\oculus-dash\dash\bin\OculusDash.exe"

function Write-Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$timestamp - $msg"
}

function Restore-OculusKiller {
    Write-Log "Modifica rilevata — avvio procedura di ripristino"

    Write-Log "Arresto OVRService..."
    Stop-Service -Name "OVRService" -Force -ErrorAction SilentlyContinue

    Write-Log "Copia del file OculusKiller..."
    Copy-Item -Path $SourceFile -Destination $TargetFile -Force

    Write-Log "Riavvio OVRService..."
    Start-Service -Name "OVRService"

    Write-Log "Ripristino completato!"
}

# ===========================
# Controllo iniziale
# ===========================

if (-Not (Test-Path $LogFile)) { New-Item -ItemType File -Path $LogFile | Out-Null }

if (Test-Path $TargetFile) {
    if ((Get-FileHash $SourceFile).Hash -ne (Get-FileHash $TargetFile).Hash) {
        Restore-OculusKiller
    } else {
        Write-Log "Allineamento corretto all'avvio — nessuna azione necessaria"
    }
} else {
    Write-Log "File target mancante — ripristino immediato"
    Restore-OculusKiller
}

# ===========================
# Watcher su modifiche future
# ===========================

$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = Split-Path $TargetFile
$Watcher.Filter = "OculusDash.exe"
$Watcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite, Size'

Register-ObjectEvent $Watcher Changed -Action {
    Start-Sleep -Milliseconds 500  # attende fine scrittura del file
    Restore-OculusKiller
}

Write-Log "Watcher avviato e in ascolto..."
while ($true) {
    Start-Sleep -Seconds 2
}
