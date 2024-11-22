SELECT
    e.matricule,  -- Etudiant
    m.matiere_nom,  -- Matière
    LISTAGG(CASE
                WHEN g.matiere = m.matiere_nom AND e.matricule IN (SELECT matricule FROM TABLE(e.groupes_inscrit) WHERE groupe_id = g.groupe_id)
                THEN g.type_group || ' ' || g.num_groupe
                ELSE NULL
            END, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS groupes
FROM
    etudiant e
JOIN
    groupe g ON g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit))
JOIN
    matieres m ON m.matiere_nom = g.matiere
GROUP BY
    e.matricule, m.matiere_nom
ORDER BY
    e.matricule, m.matiere_nom;
/


SELECT
    edt.edt_id,
    edt.jour_semaine,
    edt.horaire,
    g.matiere,
    g.type_group,
    g.num_groupe
FROM
    emploi_du_temps edt
JOIN
    groupe g ON edt.groupe_id = g.groupe_id
ORDER BY
    edt.jour_semaine, edt.horaire;
/



SELECT *
FROM (
    SELECT
        e.matricule, -- Étudiant
        m.matiere_nom, -- Matière
        LISTAGG(g.type_group || ' ' || g.num_groupe, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS groupes -- Groupes associés
    FROM
        etudiant e
    JOIN
        TABLE(e.matieres_inscrit) m -- Matieres de l'étudiant
    ON
        1 = 1
    LEFT JOIN
        groupe g
    ON
        g.matiere = m.matiere_nom
    AND
        g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit)) -- Groupes auxquels l'étudiant est inscrit
    GROUP BY
        e.matricule, m.matiere_nom
)
PIVOT (
    MAX(groupes) -- Pour afficher les groupes dans chaque cellule
    FOR matiere_nom IN (
        'Algèbre' AS "Algèbre",
        'Analyse' AS "Analyse",
        'Algo' AS "Algo",
        'Concepts Informatique' AS "Concepts Informatique" -- Ajoute ici toutes les matières possibles
    )
)
ORDER BY matricule;
/


/*
-- Génération de la requête dynamique pour afficher les matières en colonnes
DECLARE
    v_sql VARCHAR2(4000);
    v_columns VARCHAR2(4000);
BEGIN
    -- Étape 1 : Récupérer toutes les matières et les formater pour le PIVOT
    SELECT LISTAGG('''' || matiere_nom || '''', ', ') WITHIN GROUP (ORDER BY matiere_nom)
    INTO v_columns
    FROM Matieres;

    -- Étape 2 : Créer la requête dynamique sans le PIVOT
    v_sql := 'SELECT matricule, matiere_nom,
                      LISTAGG(g.type_group || '' '' || g.num_groupe, '','') WITHIN GROUP (ORDER BY g.num_groupe) AS groupes
               FROM etudiant e
               JOIN TABLE(e.matieres_inscrit) m ON 1 = 1
               LEFT JOIN groupe g ON g.matiere = m.matiere_nom
               AND g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit))
               GROUP BY matricule, matiere_nom';

    -- Étape 3 : Ajouter la partie PIVOT
    v_sql := 'SELECT * FROM (' || v_sql || ') PIVOT (
                 MAX(groupes)
                 FOR matiere_nom IN (' || v_columns || ')
             ) ORDER BY matricule';

    -- Afficher la requête dynamique pour vérification
    DBMS_OUTPUT.PUT_LINE(v_sql);

    -- Étape 4 : Exécuter la requête
    EXECUTE IMMEDIATE v_sql;
END;
/
*/

-- Requête pour afficher les étudiants avec une jointure
/*
SELECT * FROM (
    SELECT matricule, matiere_nom,
           LISTAGG(g.type_group || ' ' || g.num_groupe, ',') WITHIN GROUP (ORDER BY g.num_groupe) AS groupes
    FROM etudiant e
    JOIN TABLE(e.matieres_inscrit) m ON 1 = 1
    LEFT JOIN groupe g ON g.matiere = m.matiere_nom
    AND g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit))
    GROUP BY matricule, matiere_nom
) PIVOT (
    MAX(groupes)
    FOR matiere_nom IN ('Algo', 'Algèbre', 'Analyse', 'Concepts Informatique')
) ORDER BY matricule;
*/

-- Requête pour obtenir l'emploi du temps avec une jointure explicite
/*
SELECT
    -- Conversion de l'horaire en texte
    CASE
        WHEN e.horaire = 1 THEN '8h-10h'
        WHEN e.horaire = 2 THEN '10h-12h'
        WHEN e.horaire = 3 THEN '13h30-14h30'
        WHEN e.horaire = 4 THEN '14h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Horaire",

    -- Agrégation pour chaque jour de la semaine
    LISTAGG(CASE WHEN e.jour_semaine = 'Lundi' THEN
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS Lundi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Mardi' THEN
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS Mardi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Mercredi' THEN
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS Mercredi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Jeudi' THEN
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS Jeudi,
    LISTAGG(CASE WHEN e.jour_semaine = 'Vendredi' THEN
        g.matiere || ' ' || g.type_group || ' ' || g.num_groupe
        ELSE NULL END, ', ') WITHIN GROUP (ORDER BY g.num_groupe) AS Vendredi
FROM
    emploi_du_temps e
JOIN
    groupe g ON e.groupe_id = g.groupe_id  -- Jointure avec la table groupe
GROUP BY
    e.horaire                              -- Regroupement par horaire
ORDER BY
    e.horaire;                             -- Tri par horaire
*/
