$GAME = "C:\Program Files\Assetto-Corsa-SteamRIP.com\Assetto Corsa"

$LOG = Join-Path $GAME "sensor_par_subprocess_log.txt"

if (Test-Path $LOG) {
    Get-Content $LOG -Tail 80
} else {
    Write-Host "Journal de capture introuvable à cet emplacement"
}