#!/bin/bash
# Speicherplatz-Report mit Warnung ab 90% Nutzung

EMAIL="kontakt@jensneuhaus.de"  # Deine E-Mail-Adresse
HOSTNAME=$(hostname)

# Ermittelt den Gesamtspeicherverbrauch für "/"
USAGE=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')

# Setzt den Betreff mit oder ohne Warnung
if [ "$USAGE" -ge 90 ]; then
    SUBJECT="[BEELINK] Speicherplatz-Report: $USAGE% (WARNUNG!)"
else
    SUBJECT="[BEELINK] Speicherplatz-Report: $USAGE%"
fi

# Weitere Systeminformationen sammeln
DISK_INFO=$(df -h)  # Speicherplatz
DIR_DETAILS=$(du -sxh /home/jens/backups /home/jens/docker /var/log /var/lib/docker /tmp /usr 2>/dev/null | sort -rh) # Speicherplatz für wichtige Ordner
RAM_INFO=$(free -h | grep "Mem:")  # RAM-Nutzung
UPTIME_INFO=$(uptime)  # Systemlaufzeit & Last
LAST_LOGIN=$(last -n 5 | head -5)
FAILED_LOGINS=$(journalctl -u ssh --since "1 day ago" | grep 'Failed password' | tail -5)  # Letzte fehlgeschlagene SSH-Logins

# Nachricht für die E-Mail erstellen
MESSAGE=$(cat <<EOF
📢 **Speicherstatus für $HOSTNAME**
------------------------------------------------
📂 Speicher belegt: $USAGE%

📌 Festplattenstatus (/):
$DISK_INFO

📁 Wichtige Verzeichnisse:
$DIR_DETAILS

🖥️ RAM-Nutzung:
$RAM_INFO

📈 Systemlast & Laufzeit:
$UPTIME_INFO

👤 Letzte erfolgreiche Logins:
$LAST_LOGIN

🔐 Letzte fehlgeschlagene SSH-Logins:
$FAILED_LOGINS
------------------------------------------------
EOF
)

# E-Mail senden
echo -e "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL"

# Healthcheck
curl -m 10 --retry 5 https://hc-ping.com/44fb309b-6197-48c4-aeb8-2f9b1259288a

