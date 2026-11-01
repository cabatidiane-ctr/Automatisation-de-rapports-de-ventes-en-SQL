-- # Projet SQL : analyse des ventes - base Chinook (SQLite)
--
-- Auteur : Caba Tidiane (cabatidiane-ctr)
-- Base   : Chinook_Sqlite.sqlite (factures de 2009 à 2013)
-- Chemin des ventes :
--   Employee -> Customer -> Invoice -> InvoiceLine -> Track -> Album -> Artist
--
-- Exécution d'une requête : sqlite3 Chinook_Sqlite.sqlite
-- Les résultats attendus sont dans results/qN.res


-- ##########################################################
-- NIVEAU A : requêtes de base (SELECT, WHERE, ORDER BY)
-- ##########################################################

-- ==========================================================
--<q1>| La liste des genres musicaux, triés par ordre alphabétique.
-- Explication : SELECT d'une seule colonne et ORDER BY pour le tri alphabétique.
SELECT Name
FROM Genre
ORDER BY Name;
--</q1>

-- ==========================================================
--<q2>| Le prénom, le nom et la ville des clients du Brésil.
-- Explication : WHERE filtre les lignes sur le pays.
SELECT FirstName, LastName, City
FROM Customer
WHERE Country = 'Brazil'
ORDER BY LastName;
--</q2>

-- ==========================================================
--<q3>| Le prénom et le nom des employés ayant le titre 'Sales Support Agent'.
-- Explication : ce sont les agents de vente qui suivent les clients.
SELECT FirstName, LastName
FROM Employee
WHERE Title = 'Sales Support Agent'
ORDER BY EmployeeId;
--</q3>

-- ==========================================================
--<q4>| L'identifiant et le total des factures supérieures à 15 €, de la plus chère à la moins chère.
-- Explication : WHERE sur une valeur numérique, puis tri décroissant (DESC).
SELECT InvoiceId, Total
FROM Invoice
WHERE Total > 15
ORDER BY Total DESC, InvoiceId;
--</q4>

-- ==========================================================
--<q5>| Le nom et l'e-mail des clients dont l'adresse e-mail se termine par '@gmail.com'.
-- Explication : LIKE avec le joker % (n'importe quelle suite de caractères).
SELECT FirstName, LastName, Email
FROM Customer
WHERE Email LIKE '%@gmail.com'
ORDER BY LastName;
--</q5>

-- ==========================================================
--<q6>| Le nom et la durée en minutes des 10 morceaux les plus longs.
-- Explication : conversion des millisecondes en minutes, tri décroissant et LIMIT 10.
SELECT Name, ROUND(Milliseconds / 60000.0, 2) AS Minutes
FROM Track
ORDER BY Milliseconds DESC, TrackId
LIMIT 10;
--</q6>


-- ##########################################################
-- NIVEAU B : jointures (INNER JOIN, LEFT JOIN)
-- ##########################################################

-- ==========================================================
--<q7>| Le titre des albums de l'artiste 'AC/DC'.
-- Explication : INNER JOIN Album-Artist sur ArtistId, puis filtre sur le nom de l'artiste.
SELECT al.Title
FROM Album al
INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
WHERE ar.Name = 'AC/DC'
ORDER BY al.Title;
--</q7>

-- ==========================================================
--<q8>| Le nom et le genre des morceaux de l'album 'Let There Be Rock'.
-- Explication : jointure en chaîne Track -> Album et Track -> Genre.
SELECT t.Name, g.Name AS Genre
FROM Track t
INNER JOIN Album al ON al.AlbumId = t.AlbumId
INNER JOIN Genre g ON g.GenreId = t.GenreId
WHERE al.Title = 'Let There Be Rock'
ORDER BY t.TrackId;
--</q8>

-- ==========================================================
--<q9>| Pour chaque client, son nom et le nom de son agent de vente (les 10 premiers clients).
-- Explication : Customer.SupportRepId pointe vers Employee.EmployeeId.
SELECT c.FirstName || ' ' || c.LastName AS Client,
       e.FirstName || ' ' || e.LastName AS Agent
FROM Customer c
INNER JOIN Employee e ON e.EmployeeId = c.SupportRepId
ORDER BY c.CustomerId
LIMIT 10;
--</q9>

-- ==========================================================
--<q10>| Les artistes qui n'ont aucun album.
-- Explication : LEFT JOIN garde tous les artistes ; ceux sans album ont NULL côté Album.
SELECT ar.Name
FROM Artist ar
LEFT JOIN Album al ON al.ArtistId = ar.ArtistId
WHERE al.AlbumId IS NULL
ORDER BY ar.Name;
--</q10>

-- ==========================================================
--<q11>| Le nombre de morceaux qui n'ont jamais été vendus.
-- Explication : LEFT JOIN Track-InvoiceLine ; absence de vente = NULL côté InvoiceLine.
SELECT COUNT(*) AS MorceauxJamaisVendus
FROM Track t
LEFT JOIN InvoiceLine il ON il.TrackId = t.TrackId
WHERE il.InvoiceLineId IS NULL;
--</q11>

-- ==========================================================
--<q12>| Pour chaque employé, le nom de son supérieur hiérarchique (NULL pour la direction).
-- Explication : auto-jointure de Employee avec elle-même ; LEFT JOIN pour garder le patron.
SELECT e.FirstName || ' ' || e.LastName AS Employe,
       m.FirstName || ' ' || m.LastName AS Superieur
FROM Employee e
LEFT JOIN Employee m ON m.EmployeeId = e.ReportsTo
ORDER BY e.EmployeeId;
--</q12>


-- ##########################################################
-- NIVEAU C : agrégations (COUNT, SUM, AVG, GROUP BY, HAVING)
-- ##########################################################

-- ==========================================================
--<q13>| Le nombre de clients par pays, du plus grand au plus petit.
-- Explication : GROUP BY regroupe par pays, COUNT(*) compte les clients de chaque groupe.
SELECT Country, COUNT(*) AS NbClients
FROM Customer
GROUP BY Country
ORDER BY NbClients DESC, Country;
--</q13>

-- ==========================================================
--<q14>| Le chiffre d'affaires total de l'entreprise.
-- Explication : SUM sur le total des factures.
SELECT ROUND(SUM(Total), 2) AS ChiffreAffaires
FROM Invoice;
--</q14>

-- ==========================================================
--<q15>| Le montant moyen d'une facture (panier moyen).
-- Explication : AVG sur Invoice.Total, arrondi à 2 décimales.
SELECT ROUND(AVG(Total), 2) AS PanierMoyen
FROM Invoice;
--</q15>

-- ==========================================================
--<q16>| Le nombre de morceaux par genre, du plus grand au plus petit.
-- Explication : jointure Track-Genre puis GROUP BY sur le genre.
SELECT g.Name AS Genre, COUNT(*) AS NbMorceaux
FROM Track t
INNER JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.GenreId
ORDER BY NbMorceaux DESC, Genre;
--</q16>

-- ==========================================================
--<q17>| Les pays ayant plus de 5 clients.
-- Explication : HAVING filtre après l'agrégation (WHERE filtre avant, ligne par ligne).
SELECT Country, COUNT(*) AS NbClients
FROM Customer
GROUP BY Country
HAVING COUNT(*) > 5
ORDER BY NbClients DESC, Country;
--</q17>

-- ==========================================================
--<q18>| Les albums de plus de 20 morceaux, avec leur nombre de morceaux.
-- Explication : GROUP BY album puis HAVING sur le COUNT.
SELECT al.Title, COUNT(*) AS NbMorceaux
FROM Album al
INNER JOIN Track t ON t.AlbumId = al.AlbumId
GROUP BY al.AlbumId
HAVING COUNT(*) > 20
ORDER BY NbMorceaux DESC, al.Title;
--</q18>


-- ##########################################################
-- NIVEAU D : analyses métier
-- ##########################################################

-- ==========================================================
--<q19>| Les ventes (chiffre d'affaires et nombre de factures) par année.
-- Explication : strftime('%Y', ...) extrait l'année de la date de facture.
SELECT strftime('%Y', InvoiceDate) AS Annee,
       COUNT(*) AS NbFactures,
       ROUND(SUM(Total), 2) AS Ventes
FROM Invoice
GROUP BY Annee
ORDER BY Annee;
--</q19>

-- ==========================================================
--<q20>| Les ventes par pays de facturation, du plus grand au plus petit.
-- Explication : GROUP BY sur BillingCountry avec SUM du total des factures.
SELECT BillingCountry AS Pays, ROUND(SUM(Total), 2) AS Ventes
FROM Invoice
GROUP BY BillingCountry
ORDER BY Ventes DESC, Pays;
--</q20>

-- ==========================================================
--<q21>| Le meilleur pays en chiffre d'affaires.
-- Explication : même requête que q20 avec LIMIT 1.
SELECT BillingCountry AS Pays, ROUND(SUM(Total), 2) AS Ventes
FROM Invoice
GROUP BY BillingCountry
ORDER BY Ventes DESC, Pays
LIMIT 1;
--</q21>

-- ==========================================================
--<q22>| Les ventes par agent de vente.
-- Explication : chemin Employee -> Customer -> Invoice ; on agrège le total des factures de ses clients.
SELECT e.FirstName || ' ' || e.LastName AS Agent,
       COUNT(DISTINCT c.CustomerId) AS NbClients,
       ROUND(SUM(i.Total), 2) AS Ventes
FROM Employee e
INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY e.EmployeeId
ORDER BY Ventes DESC;
--</q22>

-- ==========================================================
--<q23>| Le meilleur agent de vente.
-- Explication : même requête que q22 avec LIMIT 1.
SELECT e.FirstName || ' ' || e.LastName AS Agent,
       ROUND(SUM(i.Total), 2) AS Ventes
FROM Employee e
INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY e.EmployeeId
ORDER BY Ventes DESC
LIMIT 1;
--</q23>

-- ==========================================================
--<q24>| Les 5 morceaux qui rapportent le plus (quantité vendue et chiffre d'affaires).
-- Explication : SUM sur InvoiceLine par morceau, classés par chiffre d'affaires.
-- Remarque : 8 morceaux sont ex aequo à 3,98 € (2 ventes à 1,99 €) ; le départage
-- alphabétique est donc arbitraire. Retirer le LIMIT pour voir les 8 ex aequo.
SELECT t.Name,
       SUM(il.Quantity) AS QuantiteVendue,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS ChiffreAffaires
FROM InvoiceLine il
INNER JOIN Track t ON t.TrackId = il.TrackId
GROUP BY t.TrackId
ORDER BY ChiffreAffaires DESC, t.Name
LIMIT 5;
--</q24>

-- ==========================================================
--<q25>| Les 3 artistes qui rapportent le plus (chiffre d'affaires).
-- Explication : chaîne InvoiceLine -> Track -> Album -> Artist ; CA = UnitPrice * Quantity.
SELECT ar.Name AS Artiste,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS ChiffreAffaires
FROM InvoiceLine il
INNER JOIN Track t ON t.TrackId = il.TrackId
INNER JOIN Album al ON al.AlbumId = t.AlbumId
INNER JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId
ORDER BY ChiffreAffaires DESC, Artiste
LIMIT 3;
--</q25>

-- ==========================================================
--<q26>| Le type de média le plus vendu (en quantité).
-- Explication : InvoiceLine -> Track -> MediaType, SUM(Quantity), tri décroissant, LIMIT 1.
SELECT m.Name AS TypeMedia, SUM(il.Quantity) AS QuantiteVendue
FROM InvoiceLine il
INNER JOIN Track t ON t.TrackId = il.TrackId
INNER JOIN MediaType m ON m.MediaTypeId = t.MediaTypeId
GROUP BY m.MediaTypeId
ORDER BY QuantiteVendue DESC
LIMIT 1;
--</q26>
