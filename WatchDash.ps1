Add-Type -AssemblyName System.Windows.Forms

$original = "C:\OculusKiller\OculusDash.exe"
$target   = "C:\Program Files\Oculus\Support\oculus-dash\dash\bin\OculusDash.exe"

function Show-Notification($msg, $success=$true) {
    $icon = if ($success) { "Information" } else { "Error" }
    [System.Windows.Forms.MessageBox]::Show($msg, "OculusKiller", "OK", $icon)
}

function Restore-Dash {
    try {
        $hashOriginal = (Get-FileHash $original).Hash
        $hashTarget   = (Get-FileHash $target).Hash

        if ($hashOriginal -ne $hashTarget) {

            Stop-Service OVRService -Force

            Copy-Item $original $target -Force

            $hashAfter = (Get-FileHash $target).Hash

            Start-Service OVRService

            if ($hashAfter -eq $hashOriginal) {
                Show-Notification "OculusDash.exe è stato ripristinato correttamente."
            } else {
                Show-Notification "Il ripristino di OculusDash.exe NON è riuscito." $false
            }
        }
    }
    catch {
        Show-Notification "Errore durante il ripristino: $($_.Exception.Message)" $false
    }
}

Restore-Dash

$folder = Split-Path $target
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = "OculusDash.exe"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite'

Register-ObjectEvent $watcher Changed -Action { Restore-Dash }

$watcher.EnableRaisingEvents = $true

while ($true) {
    Start-Sleep -Seconds 60
}

