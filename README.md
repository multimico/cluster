# Installation des MultiMICO Clusters

Dieses Repository beschreibt den Aufbau eines Testlabs für die ein kleines Edge-Computing Virtualisierungscluster auf Basis von INTEL NUC Hardware.

Das Cluster besteht aus zwei Hardware-Knoten (Computern) mit identischer Hardware Konfiguration. 

Unser kleines Lab besteht aus 3x Intel NUC 10i7, 64GB Ram, 2TB NVME HD. 

# Installationsprozess 

Der Installationsprozess ist auf eine interaktionsfreie Installation ausgelegt. 

Die Installation erfolgt über ein angepasstes Installationsmedium ([`ubuntu-$RELEASE-live-server-multimico.iso`](//github.com/multimico/imager)), mit $RELEASE entsprechend dem jeweiligen offiziellen Ubuntu Release. Das Installationsmedium ist eine reine "headless" Installation und erfordert *keine* Nutzerinteraktion. 

Die Basiskonfiguration wird in `user-data` initialisiert. Die eigentliche Systemkonfiguration erfolgt in zwei Schritten. 

1. Aus dem Repository [multimico/init](//github.com/multimico/init) werden die registrierten MAC Adressen und Konfigurationsquellen geladen. Auf Basis dieser Konfiguration wird ein zweites Konfigurationsrepository gelanden. 
2. Das zweite Konfigurationsrepository enthält alle relevanten Informationen, um die Installation bis zu dem Punkt abzuschliessen, dass der Rechner über das Netzwerk erreichbar ist.

Alle Konfigurationsrepositories haben als definierten Einstiegspunkt `bin/init.sh`. Dieses Shellskript führt alle notwendigen Schritte für die jeweilige Konfiguration aus. Alle allgemeinen Tools werden dabei über das init Repository den nachgereihten Initialisierungsschritten bereitgestellt.

Dadurch wird die zentrale Installation kompakt und allgemein gehalten. Alle weiteren Anpassungen werden über Ansible vorgenommen sobald der Rechner über das Netzwerk erreichbar ist. 

# Vorbereitungen

Damit wir möglichst wenig manuell konfigurieren müssen, sollten die folgenden Repositories auf jeden Hardware-Knoten gecloned werden: 

- `mutlimico/cluster`
- `multimico/lxd-host`
- `multimico/config` (private information)

# VMs starten

Eine vorkonfigurierte VM kann mit dem folgenden Befehl gestartet werden: 

```
bash tools/install-vm.sh $VMNAME
```

Falls die Konfiguration keine entsprechenden Informationen bietet, fragt das Tool nach default user, github user und passwort. Entsprechend der vorkonfigurierten Profildefinition werden notwendige Packete installiert und Einstellungen der VM vorgenommen. 
