Add-Type -AssemblyName System.Windows.Forms

$original = "C:\OculusKiller\OculusDash.exe"
$target   = "C:\Program Files\Oculus\Support\oculus-core\OculusDash.exe"

function Show-Notification($msg, $success=$true) {
    $icon = if ($success) { "Information" } else { "Error" }
    [System.Windows.Forms.MessageBox]::Show($msg, "OculusKiller", "OK", $icon)
}

function Restore-Dash {
    try {
        $hashOriginal = (Get-FileHash $original).Hash
        $hashTarget   = (Get-FileHash $target).Hash

        # Se i due file sono diversi → Meta lo ha sovrascritto
        if ($hashOriginal -ne $hashTarget) {

            # Prova a ripristinare
            Copy-Item $original $target -Force

            # Verifica di nuovo l'hash
            $hashAfterCopy = (Get-FileHash $target).Hash

            if ($hashAfterCopy -eq $hashOriginal) {
                Show-Notification "OculusDash.exe è stato ripristinato correttamente."
            } else {
                Show-Notification "ATTENZIONE: il ripristino NON è riuscito. Potrebbe essere in uso o bloccato." $false
            }
        }
    }
    catch {
        Show-Notification "Errore durante il tentativo di ripristino: $($_.Exception.Message)" $false
    }
}

# Imposta watcher
$folder = Split-Path $target
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = "OculusDash.exe"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite'

Register-ObjectEvent $watcher Changed -Action { Restore-Dash }

$watcher.EnableRaisingEvents = $true

# Mantiene vivo lo script
while ($true) {
    Start-Sleep -Seconds 60
}
