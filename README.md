
# edxi's MultiMICO Test- und Entwicklungscluster. 

> ***ACHTUNG*** Der `ci`-Branch wird für die Installation benötigt und darf ***nicht*** in den Main-Branch gemerged werden!

> *Änderungen werden nur über **Pull-Requests** eingebunden*

Die Installation erfolgt über ein angepasstes Installationsmedium (`ubuntu-$RELEASE-server-zhaw.iso`), mit $RELEASE entsprechend dem offiziellen Ubuntu Release. Das Installationsmedium ist eine reine "headless" Installation und erfordert *keine* Nutzerinteraktion. 

Die Basiskonfiguration wird in `user-data` initialisiert. Die eigentliche Systemkonfiguration erfolgt über ein zweites Repository. Dadurch wird die zentrale Installation kompakt und allgemein gehalten. Personalisierungen werden über das zweite Repository vorgenommen. 
