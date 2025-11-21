# ============================
# Configurazione
# ============================

$original = "C:\OculusKiller\OculusDash.exe"
$target   = "C:\Program Files\Oculus\Support\oculus-dash\dash\bin\OculusDash.exe"
$logFile  = "C:\OculusKiller\log.txt"

# ============================
# Funzioni
# ============================

function Write-Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp - $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Restore-Dash {
    # Debounce: evita chiamate multiple contemporanee
    if ($script:Running) { return }
    $script:Running = $true

    try {
        if (!(Test-Path $original)) {
            Write-Log "ERRORE: File originale non trovato: $original"
            return
        }

        if (!(Test-Path $target)) {
            Write-Log "ERRORE: File target non trovato: $target"
            return
        }

        $hashOriginal = (Get-FileHash $original).Hash
        $hashTarget   = (Get-FileHash $target).Hash

        if ($hashOriginal -ne $hashTarget) {

            Write-Log "Differenza rilevata. Ripristino in corso…"
            
            Stop-Service OVRService -Force -ErrorAction SilentlyContinue
            Copy-Item $original $target -Force
            Start-Service OVRService -ErrorAction SilentlyContinue

            $hashAfter = (Get-FileHash $target).Hash

            if ($hashAfter -eq $hashOriginal) {
                Write-Log "Ripristino completato con successo."
            } else
                Write-Log "ERRORE: Hash post-ripristino non coincide."
            }
        } else {
            Write-Log "Nessuna modifica rilevata."
        }

    } catch {
        Write-Log "ERRORE durante il ripristino: $($_.Exception.Message)"
    }
    finally {
        $script:Running = $false
    }
}

# ============================
# Avvio iniziale
# ============================

Write-Log "===== Avvio script OculusKiller ====="
Restore-Dash

# ============================
# FileSystemWatcher
# ============================

$folder = Split-Path $target
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = "OculusDash.exe"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite, Size'

Register-ObjectEvent $watcher Changed -Action {
    Write-Log "Evento file modificato rilevato."
    Restore-Dash
}

$watcher.EnableRaisingEvents = $true
Write-Log "Monitoraggio attivo sulla cartella: $folder"

# ============================
# Loop (mantiene attivo il watcher)
# ============================

while ($true) {
    Start-Sleep -Seconds 30
}
