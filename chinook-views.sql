-- # Vues de reporting des ventes - base Chinook (SQLite)
-- Rapport de ventes réutilisable : SELECT * FROM v_ventes_par_trimestre; etc.

DROP VIEW IF EXISTS v_ventes_par_trimestre;
DROP VIEW IF EXISTS v_ventes_par_agent;
DROP VIEW IF EXISTS v_ventes_par_pays;

-- ==========================================================
-- Ventes par trimestre (année, trimestre 1 à 4)
-- Le trimestre se déduit du mois : (mois + 2) / 3 en division entière.
CREATE VIEW v_ventes_par_trimestre AS
SELECT strftime('%Y', InvoiceDate) AS Annee,
       (CAST(strftime('%m', InvoiceDate) AS INTEGER) + 2) / 3 AS Trimestre,
       COUNT(*) AS NbFactures,
       ROUND(SUM(Total), 2) AS Ventes
FROM Invoice
GROUP BY Annee, Trimestre;

-- ==========================================================
-- Ventes par agent de vente
CREATE VIEW v_ventes_par_agent AS
SELECT e.EmployeeId,
       e.FirstName || ' ' || e.LastName AS Agent,
       COUNT(DISTINCT c.CustomerId) AS NbClients,
       COUNT(i.InvoiceId) AS NbFactures,
       ROUND(SUM(i.Total), 2) AS Ventes
FROM Employee e
INNER JOIN Customer c ON c.SupportRepId = e.EmployeeId
INNER JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY e.EmployeeId;

-- ==========================================================
-- Ventes par pays de facturation
CREATE VIEW v_ventes_par_pays AS
SELECT BillingCountry AS Pays,
       COUNT(*) AS NbFactures,
       ROUND(SUM(Total), 2) AS Ventes,
       ROUND(AVG(Total), 2) AS PanierMoyen
FROM Invoice
GROUP BY BillingCountry;

-- ==========================================================
-- Exemples d'utilisation
-- SELECT * FROM v_ventes_par_trimestre ORDER BY Annee, Trimestre;
-- SELECT * FROM v_ventes_par_agent ORDER BY Ventes DESC;
-- SELECT * FROM v_ventes_par_pays ORDER BY Ventes DESC LIMIT 5;
