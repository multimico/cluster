
# edxi's MultiMICO Test- und Entwicklungscluster. 

> ***ACHTUNG*** Der `ci`-Branch wird für die Installation benötigt und darf ***nicht*** in den Main-Branch gemerged werden!

> *Änderungen werden nur über **Pull-Requests** eingebunden*

Die Installation erfolgt über ein angepasstes Installationsmedium ([`ubuntu-$RELEASE-live-server-ZHAW.iso`](https://github.com/multimico/ubuntu)), mit $RELEASE entsprechend dem offiziellen Ubuntu Release. Das Installationsmedium ist eine reine "headless" Installation und erfordert *keine* Nutzerinteraktion. 

Die Basiskonfiguration wird in `user-data` initialisiert. Die eigentliche Systemkonfiguration erfolgt in zwei Schritten. 

1. Aus dem Repository [multimico/init] werden die registrierten MAC Adressen und Konfigurationsquellen geladen. Auf Basis dieser Konfiguration wird ein zweites Konfigurationsrepository gelanden. 
2. Das zweite Konfigurationsrepository enthält alle relevanten Informationen, um die Installation bis zu dem Punkt abzuschliessen, dass der Rechner über das Netzwerk erreichbar ist.

Alle Konfigurationsrepositories haben als definierten Einstiegspunkt `bin/init.sh`. Dieses Shellskript führt alle notwendigen Schritte für die jeweilige Konfiguration aus. Alle allgemeinen Tools werden dabei über das init Repository den nachgereihten Initialisierungsschritten bereitgestellt.

Dadurch wird die zentrale Installation kompakt und allgemein gehalten. Alle weiteren Anpassungen werden über Ansible vorgenommen sobald der Rechner über das Netzwerk erreichbar ist. 

