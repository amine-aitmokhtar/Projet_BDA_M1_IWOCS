-- Afficher toutes les tables principales
SELECT * FROM Matieres;          -- Affiche toutes les matières
SELECT * FROM groupe;            -- Affiche tous les groupes

SELECT * FROM ETUDIANT;          -- Affiche tous les étudiants*/
SELECT * FROM emploi_du_temps;  -- Affiche tous les emplois du temps */

-- Requête pour obtenir l'emploi du temps sans jointure explicite
SELECT
    -- Conversion de l'horaire en texte
    CASE
        WHEN e.horaire = 1 THEN '8h-10h'
        WHEN e.horaire = 2 THEN '10h-12h'
        WHEN e.horaire = 3 THEN '13h30-15h30'
        WHEN e.horaire = 4 THEN '15h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Horaire",

    -- Agrégation pour chaque jour, utilisant la méthode get_details du type objet groupe
    LISTAGG(CASE WHEN e.jour_semaine = 'Lundi' THEN
        (SELECT g.get_details()
         FROM groupe g
         WHERE g.groupe_id = e.groupe_id)
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY e.groupe_id) AS Lundi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Mardi' THEN
        (SELECT g.get_details()
         FROM groupe g
         WHERE g.groupe_id = e.groupe_id)
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY e.groupe_id) AS Mardi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Mercredi' THEN
        (SELECT g.get_details()
         FROM groupe g
         WHERE g.groupe_id = e.groupe_id)
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY e.groupe_id) AS Mercredi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Jeudi' THEN
        (SELECT g.get_details()
         FROM groupe g
         WHERE g.groupe_id = e.groupe_id)
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY e.groupe_id) AS Jeudi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Vendredi' THEN
        (SELECT g.get_details()
         FROM groupe g
         WHERE g.groupe_id = e.groupe_id)
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY e.groupe_id) AS Vendredi
FROM
    emploi_du_temps e
GROUP BY
    e.horaire                              -- Regroupement par horaire
ORDER BY
    e.horaire;                             -- Tri par horaire

-- Requête pour afficher les étudiants sans jointure explicite
SELECT *
FROM (
    SELECT
        e.matricule,
        m.matiere_nom,
        (SELECT LISTAGG(g.type_group || ' ' || g.num_groupe, ',')
         WITHIN GROUP (ORDER BY g.num_groupe)
         FROM groupe g
         WHERE g.matiere = m.matiere_nom
           AND g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit))
        ) AS groupes
    FROM etudiant e, TABLE(e.matieres_inscrit) m
)
PIVOT (
    MAX(groupes)
    FOR matiere_nom IN ('Algo', 'Algèbre', 'Analyse', 'Concepts Informatique')
)
ORDER BY matricule;


-- Requête pour afficher le planning des enseignants
-- Requête pour afficher le planning détaillé des enseignants
-- Requête avec un affichage plus lisible
SELECT
    e.nom || ' ' || e.prenom AS "Enseignant",           -- Nom complet de l'enseignant
    g.matiere AS "Matière",                             -- Matière enseignée
    g.type_group AS "Type de cours",                    -- Type de cours (CM, TD, TP)
    g.num_groupe AS "Groupe",                           -- Numéro de groupe
    edt.jour_semaine AS "Jour",                         -- Jour de la semaine
    CASE
        WHEN edt.horaire = 1 THEN '8h-10h'
        WHEN edt.horaire = 2 THEN '10h-12h'
        WHEN edt.horaire = 3 THEN '13h30-15h30'
        WHEN edt.horaire = 4 THEN '15h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Heure"                                      -- Créneau horaire
FROM
    enseignant e,                                       -- Liste des tables
    emploi_du_temps edt,
    groupe g
WHERE
    e.enseignant_id = edt.enseignant_id AND             -- Condition pour relier l'enseignant à l'emploi du temps
    edt.groupe_id = g.groupe_id                         -- Condition pour relier l'emploi du temps au groupe
ORDER BY
    e.nom, edt.jour_semaine, edt.horaire;               -- Trie par nom de l'enseignant, jour, et horaire

SELECT
    e.nom || ' ' || e.prenom AS "Enseignant",           -- Nom complet de l'enseignant
    LISTAGG(
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe || ' - ' ||
        edt.jour_semaine || ' ' ||
        CASE
            WHEN edt.horaire = 1 THEN '8h-10h'
            WHEN edt.horaire = 2 THEN '10h-12h'
            WHEN edt.horaire = 3 THEN '13h30-15h30'
            WHEN edt.horaire = 4 THEN '15h30-17h30'
            ELSE 'Horaire inconnu'
        END,
        '; '  -- Séparateur pour les cours
    ) WITHIN GROUP (ORDER BY edt.jour_semaine, edt.horaire) AS "Cours" -- Agrégation des cours
FROM
    enseignant e,
    emploi_du_temps edt,
    groupe g
WHERE
    e.enseignant_id = edt.enseignant_id AND
    edt.groupe_id = g.groupe_id
GROUP BY
    e.nom, e.prenom
ORDER BY
    e.nom;

SELECT
    e.nom || ' ' || e.prenom AS "Enseignant", -- Nom complet de l'enseignant
    MAX(CASE WHEN row_num = 1 THEN cours_details END) AS "Cours 1",  -- Premier cours
    MAX(CASE WHEN row_num = 2 THEN cours_details END) AS "Cours 2",  -- Deuxième cours
    MAX(CASE WHEN row_num = 3 THEN cours_details END) AS "Cours 3"   -- Troisième cours
FROM (
    SELECT
        e.nom,                                         -- Utilisation correcte de la colonne NOM
        e.prenom,                                      -- Utilisation correcte de la colonne PRENOM
        ROW_NUMBER() OVER (PARTITION BY e.enseignant_id ORDER BY edt.jour_semaine, edt.horaire) AS row_num, -- Numérote les cours
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe || ' - ' ||
        edt.jour_semaine || ' ' ||
        CASE
            WHEN edt.horaire = 1 THEN '8h-10h'
            WHEN edt.horaire = 2 THEN '10h-12h'
            WHEN edt.horaire = 3 THEN '13h30-15h30'
            WHEN edt.horaire = 4 THEN '15h30-17h30'
            ELSE 'Horaire inconnu'
        END AS cours_details
    FROM
        enseignant e,                                  -- Utilisation correcte de la table ENSEIGNANT
        emploi_du_temps edt,
        groupe g
    WHERE
        e.enseignant_id = edt.enseignant_id AND
        edt.groupe_id = g.groupe_id
)
GROUP BY
    e.nom, e.prenom                                    -- Groupement par NOM et PRENOM
ORDER BY
    e.nom;                                           -- Tri par NOM

SELECT
    -- Conversion de l'horaire en texte
    CASE
        WHEN e.horaire = 1 THEN '8h-10h'
        WHEN e.horaire = 2 THEN '10h-12h'
        WHEN e.horaire = 3 THEN '13h30-15h30'
        WHEN e.horaire = 4 THEN '15h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Horaire",

    -- Agrégation pour chaque jour, incluant les détails de l'enseignant
    LISTAGG(CASE WHEN e.jour_semaine = 'Lundi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, ' | ') WITHIN GROUP (ORDER BY e.groupe_id) AS Lundi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Mardi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, ' | ') WITHIN GROUP (ORDER BY e.groupe_id) AS Mardi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Mercredi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, ' | ') WITHIN GROUP (ORDER BY e.groupe_id) AS Mercredi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Jeudi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, '|') WITHIN GROUP (ORDER BY e.groupe_id) AS Jeudi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Vendredi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, ' | ') WITHIN GROUP (ORDER BY e.groupe_id) AS Vendredi
FROM
    emploi_du_temps e
GROUP BY
    e.horaire                              -- Regroupement par horaire
ORDER BY
    e.horaire;


SELECT
    -- Conversion de l'horaire en texte
    CASE
        WHEN e.horaire = 1 THEN '8h-10h'
        WHEN e.horaire = 2 THEN '10h-12h'
        WHEN e.horaire = 3 THEN '13h30-15h30'
        WHEN e.horaire = 4 THEN '15h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Horaire",

    -- LUNDI avec sauts de ligne pour plus de clarté
    LISTAGG(CASE WHEN e.jour_semaine = 'Lundi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, CHR(10)) WITHIN GROUP (ORDER BY e.groupe_id) AS "Lundi",  -- CHR(10) pour saut de ligne

    -- MARDI avec sauts de ligne
    LISTAGG(CASE WHEN e.jour_semaine = 'Mardi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, CHR(10)) WITHIN GROUP (ORDER BY e.groupe_id) AS "Mardi",

    -- MERCREDI avec sauts de ligne
    LISTAGG(CASE WHEN e.jour_semaine = 'Mercredi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, CHR(10)) WITHIN GROUP (ORDER BY e.groupe_id) AS "Mercredi",

    -- JEUDI avec sauts de ligne
    LISTAGG(CASE WHEN e.jour_semaine = 'Jeudi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, CHR(10)) WITHIN GROUP (ORDER BY e.groupe_id) AS "Jeudi",

    -- VENDREDI avec sauts de ligne
    LISTAGG(CASE WHEN e.jour_semaine = 'Vendredi' THEN
        (SELECT g.get_details() || ' - ' || en.nom || ' ' || en.prenom
         FROM groupe g, enseignant en
         WHERE g.groupe_id = e.groupe_id AND e.enseignant_id = en.enseignant_id)
        ELSE NULL END, CHR(10)) WITHIN GROUP (ORDER BY e.groupe_id) AS "Vendredi"
FROM
    emploi_du_temps e
GROUP BY
    e.horaire                              -- Regroupement par horaire
ORDER BY
    e.horaire;
