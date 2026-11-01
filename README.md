# Analyse des ventes Chinook en SQL

Projet SQL (SQLite) réalisé dans le cadre de mon Master 1 Statistiques : analyser les ventes d'un magasin de musique en ligne à partir de la base **Chinook**.

## Objectif

Répondre à 26 questions de difficulté croissante (requêtes de base, jointures, agrégations, analyses métier), puis automatiser un rapport de ventes réutilisable avec des vues SQL.

## La base de données

Chinook modélise un magasin de musique : 11 tables, 412 factures, 2 240 lignes de facture, 3 503 morceaux, 59 clients, de 2009 à 2013.

```
Artist 1──< Album 1──< Track >──1 Genre
                        │  └────1 MediaType
          Playlist >──< PlaylistTrack >──< Track

Employee 1──< Customer 1──< Invoice 1──< InvoiceLine >──1 Track
   ▲___________|
   (ReportsTo : un employé a un supérieur)
```

Chemin des ventes : `Employee → Customer → Invoice → InvoiceLine → Track → Album → Artist`.

## Contenu du dépôt

| Fichier | Rôle |
|---|---|
| `Chinook_Sqlite.sqlite` | la base de données |
| `chinook-queries.sql` | les 26 requêtes commentées (question + explication) |
| `results/q1.res … q26.res` | le résultat de chaque requête |
| `chinook-views.sql` | 3 vues de reporting (trimestre, agent, pays) |

Les requêtes sont balisées `--<qN>| énoncé … --</qN>`. Pour en exécuter une :

```bash
sqlite3 Chinook_Sqlite.sqlite < chinook-views.sql    # crée les vues
sqlite3 Chinook_Sqlite.sqlite "SELECT * FROM v_ventes_par_pays ORDER BY Ventes DESC;"
```

## Compétences utilisées

- **Requêtes de base** : `SELECT`, `WHERE`, `LIKE`, `ORDER BY`, `LIMIT`
- **Jointures** : `INNER JOIN`, `LEFT JOIN` (détection d'absences avec `IS NULL`), auto-jointure
- **Agrégations** : `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`
- **Analyse métier** : dates avec `strftime`, classements (top N), chaînes de jointures sur 4 tables
- **Automatisation** : `CREATE VIEW` pour un rapport réutilisable

## Principaux résultats

Chiffre d'affaires total : **2 328,60 €** pour 412 factures (panier moyen **5,65 €**).

| Question | Résultat |
|---|---|
| Ventes par année | stables, entre 449 € et 481 € (meilleure année : **2010**, 481,45 €) |
| Meilleur pays | **USA**, 523,06 € (22 % du total), devant le Canada (303,96 €) et la France (195,10 €) |
| Meilleur agent | **Jane Peacock**, 833,04 € (21 clients), devant Margaret Park (775,40 €) et Steve Johnson (720,16 €) |
| Top 3 artistes | **Iron Maiden** (138,60 €), **U2** (105,93 €), **Metallica** (90,09 €) |
| Type de média le plus vendu | **MPEG audio file**, 1 976 ventes |
| Genre le plus fourni | **Rock**, 1 297 morceaux sur 3 503 |
| Morceaux jamais vendus | 1 519 sur 3 503 (43 %) |

Remarque : aucun morceau n'est vendu plus de 2 fois. Le « top 5 des morceaux » (q24) repose donc sur 8 morceaux ex aequo à 3,98 €, ce qui est signalé dans la requête.

## Vues SQL

- `v_ventes_par_trimestre` : ventes et nombre de factures par année et trimestre
- `v_ventes_par_agent` : clients, factures et ventes par agent
- `v_ventes_par_pays` : factures, ventes et panier moyen par pays

Les totaux des trois vues sont égaux au chiffre d'affaires global (2 328,60 €), ce qui valide leur cohérence.

## Source

Base Chinook : [lerocha/chinook-database](https://github.com/lerocha/chinook-database)
