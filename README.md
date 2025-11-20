**Watcher per ripristinare [OculusKiller](https://github.com/BnuuySolutions/OculusKiller) dopo un aggiornamento di Meta**
## Installazione:
1. [Scarica](https://github.com/OrangeBaron/OculusKiller/archive/refs/heads/main.zip) e decomprimi la cartella, rinominala come `OculusKiller` e mettila in C:\
2. Aggiungi [OculusDash.exe](https://github.com/BnuuySolutions/OculusKiller/releases/download/v1.3.0/OculusDash.exe) alla cartella
3. Apri l'utilità di pianificazione di Windows > importa attività > seleziona OculusDashWatcher.xml > salva
4. Riavvia
## Disinstallazione:
* Rimuovi il task "OculusDashWatcher" dalla libreria della pianificazione attività di Windows
* Oppure esegui `Unregister-ScheduledTask -TaskName "OculusDashWatcher" -Confirm:$false` da PowerShell come amministratore
* Oppure esegui `schtasks /delete /tn "OculusDashWatcher" /f` da CMD come amministratore
