# Activitat triggers
> Per David Buesa, Marc Jornet i Víctor Comino

## Exercici 3
Com es pot veure, es disposa de l'script **3.sql** on suposem que la informació de *vots_candidatures_prov* està previament ben introduïda i que ningú tindrà accés. Per tant, cada vegada que s'executen els triggers, aquests únicament sumen i resten vots dels totals.

D'altra banda, també s'adjunta l'script **3recalc.sql**, on cada vegada que s'executa un trigger, es recalcula el camp *vots* de la taula *vots_candidatures_prov* per tal d'assegurar-nos que el resultat s'actualitza correctament. Sóm concients que es tracta d'un mètode molt menys eficient, però d'altra banda, més pertinent en aquells casos on la informació de *vots_candidatures_prov* pugui patir inconsistència per una manipulació inadient o una introducció inical de dades incorrecta.

## Exercici 4
En aquest apartat hem decidit que la taula *llei_dhondt* es reinicialitzi amb cada consulta per mostrar exclusivament les dades de la província sol·licitada. A més a més, quan es crida al procediment es mostra la taula *llei_dhondt* al final del procés per no haver de fer la SELECT després.

En acabat, esmenar que si no hi ha dades per la província sol·licitada, la taula *llei_dhondt* quedarà buida per no confondre el resultat amb les dades de la última consulta.