-- DROP TRIGGER trg_after_insert_etudiant;
-- DROP TRIGGER trg_after_insert_matieres;
-- DROP TRIGGER trg_check_emploi_du_temps;
-- DROP TRIGGER trg_before_insert_etudiant;
-- DROP TRIGGER trg_before_insert_groupe;
--
-- DROP TYPE edt_type;
-- DROP TYPE groupe_list;
-- DROP TYPE matiere_list;
-- DROP TYPE Groupe_type;
-- DROP TYPE Matiere_Inscrit;
-- DROP TYPE Matiere_Inscrit;
--


-- DROP TABLE emploi_du_temps;
-- DROP TABLE etudiant;
-- DROP TABLE groupe;
-- DROP TABLE Matieres;

DROP SEQUENCE groupe_id_seq;
DROP SEQUENCE matricule_seq;
DROP SEQUENCE seq_emploi_du_temps;


-- Étape 1 : Créer la table des matières
CREATE TABLE Matieres
(
    matiere_nom VARCHAR2(50) PRIMARY KEY
);

CREATE SEQUENCE matricule_seq
    START WITH 1        -- Valeur initiale de la séquence (le premier matricule sera 1)
    INCREMENT BY 1      -- Valeur à ajouter à chaque appel pour générer le suivant
    NOCACHE;            -- Cela signifie que la séquence n'utilisera pas de "mémoire" pour stocker des valeurs dans le cache

-- Étape 2 : Créer les types pour les groupes et étudiants
CREATE OR REPLACE TYPE Groupe_type AS OBJECT
(
    groupe_id  NUMBER,
    matiere    VARCHAR2(50),
    type_group VARCHAR2(2), -- CM, TD, ou TP
    num_groupe NUMBER(1),    -- 1, 2, 3, 4 (0 pour CM ?)
    capacite   NUMBER,
    place_libre NUMBER,

    -- Méthode pour obtenir les détails du groupe
    MEMBER FUNCTION get_details RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY Groupe_type AS
    MEMBER FUNCTION get_details RETURN VARCHAR2 IS
    BEGIN
        RETURN matiere || ' ' || type_group || ' ' || num_groupe;
    END get_details;
END;
/


CREATE OR REPLACE TYPE Matiere_Inscrit AS OBJECT
(
    matiere_nom VARCHAR2(50)
);

CREATE OR REPLACE TYPE matiere_list AS TABLE OF Matiere_Inscrit;

CREATE OR REPLACE TYPE groupe_list AS TABLE OF NUMBER;

CREATE OR REPLACE TYPE Etudiant_type AS OBJECT
(
    matricule        VARCHAR2(10),
    nom              VARCHAR2(50),
    prenom           VARCHAR2(50),
    date_naissance   DATE,
    email            VARCHAR2(100),
    telephone        VARCHAR2(15),
    type_inscription VARCHAR2(50),
    matieres_inscrit matiere_list,
    groupes_inscrit  groupe_list
);


-- Étape 3 : Créer la table 'groupe' avec contraintes et séquence pour groupe_id
CREATE TABLE groupe OF Groupe_type(
    CONSTRAINT group_id_pk PRIMARY KEY(groupe_id),
    CONSTRAINT capacite_not_null CHECK (capacite IS NOT NULL),
    CONSTRAINT capacite_positive CHECK (capacite > 0),
    CONSTRAINT type_group_valid CHECK (type_group IN ('CM', 'TD', 'TP')),
    CONSTRAINT matiere_valid_fk FOREIGN KEY (matiere) REFERENCES Matieres(matiere_nom));

CREATE SEQUENCE groupe_id_seq
    START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_before_insert_groupe
    BEFORE INSERT
    ON groupe
    FOR EACH ROW
BEGIN
    :NEW.groupe_id := groupe_id_seq.NEXTVAL;
END;
/

-- Étape 4 : Créer la table 'etudiant' avec types de table imbriqués
CREATE TABLE etudiant OF Etudiant_type(
    CONSTRAINT pk_matricule  PRIMARY KEY (matricule),
    CONSTRAINT email_not_null CHECK (email IS NOT NULL),
    CONSTRAINT unique_email_telephone UNIQUE (email, telephone),
    CONSTRAINT telephone_not_null CHECK (telephone IS NOT NULL),
    CONSTRAINT chk_type_inscription CHECK (type_inscription IN ('Autres Entrées', 'Première Inscription', 'Réinscription')))
NESTED TABLE matieres_inscrit STORE AS matieres_tab_nested
NESTED TABLE groupes_inscrit STORE AS groupes_tab_nested;

CREATE OR REPLACE TRIGGER trg_before_insert_etudiant
    BEFORE INSERT
    ON etudiant
    FOR EACH ROW
BEGIN
    -- Génération du matricule
    :NEW.matricule :=
        -- Première lettre du prénom (en majuscule)
        UPPER(SUBSTR(:NEW.prenom, 1, 1)) ||
        -- Première lettre du nom (en majuscule)
        UPPER(SUBSTR(:NEW.nom, 1, 1)) ||
        -- Les deux derniers chiffres de l'année de naissance
        SUBSTR(TO_CHAR(:NEW.date_naissance, 'YYYY'), 3, 2) ||
        -- Numéro incrémenté à partir de la séquence
        LPAD(matricule_seq.NEXTVAL, 3, '0');
END;
/



-- Étape 5 : Créer le déclencheur pour ajouter des groupes par défaut pour chaque matière insérée
CREATE OR REPLACE TRIGGER trg_after_insert_matieres
    AFTER INSERT
    ON Matieres
    FOR EACH ROW
BEGIN
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES ( :NEW.matiere_nom, 'CM', 0,  80, 80);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 1, 40, 40);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 2, 40, 40);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 1, 20, 20);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 2, 20, 20);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 3, 20, 20);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 4, 20, 20);
END;
/

CREATE OR REPLACE TRIGGER trg_after_insert_etudiant
    BEFORE INSERT ON etudiant
    FOR EACH ROW
DECLARE
    v_groupe_id NUMBER;
BEGIN
    -- Parcourir les matières inscrites de l'étudiant
    FOR i IN 1 .. :NEW.matieres_inscrit.COUNT LOOP
        -- Affecter un groupe de CM pour chaque matière
        SELECT groupe_id INTO v_groupe_id
        FROM groupe
        WHERE matiere = :NEW.matieres_inscrit(i).matiere_nom
          AND type_group = 'CM'
          AND place_libre > 0
        ORDER BY place_libre DESC
        FETCH FIRST 1 ROWS ONLY;

        -- Ajouter le groupe à la liste de groupes inscrits de l'étudiant
        :NEW.groupes_inscrit.EXTEND;
        :NEW.groupes_inscrit(:NEW.groupes_inscrit.COUNT) := v_groupe_id;

        -- Mise à jour des places libres
        UPDATE groupe
        SET place_libre = place_libre - 1
        WHERE groupe_id = v_groupe_id;

        -- Affecter un groupe de TD
        SELECT groupe_id INTO v_groupe_id
        FROM groupe
        WHERE matiere = :NEW.matieres_inscrit(i).matiere_nom
          AND type_group = 'TD'
          AND place_libre > 0
        ORDER BY place_libre DESC
        FETCH FIRST 1 ROWS ONLY;

        -- Ajouter le groupe de TD
        :NEW.groupes_inscrit.EXTEND;
        :NEW.groupes_inscrit(:NEW.groupes_inscrit.COUNT) := v_groupe_id;

        -- Mise à jour des places libres pour TD
        UPDATE groupe
        SET place_libre = place_libre - 1
        WHERE groupe_id = v_groupe_id;

        -- Affecter un groupe de TP
        SELECT groupe_id INTO v_groupe_id
        FROM groupe
        WHERE matiere = :NEW.matieres_inscrit(i).matiere_nom
          AND type_group = 'TP'
          AND place_libre > 0
        ORDER BY place_libre DESC
        FETCH FIRST 1 ROWS ONLY;

        -- Ajouter le groupe de TP
        :NEW.groupes_inscrit.EXTEND;
        :NEW.groupes_inscrit(:NEW.groupes_inscrit.COUNT) := v_groupe_id;

        -- Mise à jour des places libres pour TP
        UPDATE groupe
        SET place_libre = place_libre - 1
        WHERE groupe_id = v_groupe_id;
    END LOOP;
END;
/


-- Exemple d’insertion dans la table Matieres
INSERT INTO Matieres (matiere_nom) VALUES ('Algèbre');
INSERT INTO Matieres (matiere_nom) VALUES ('Analyse');
INSERT INTO Matieres (matiere_nom) VALUES ('Algo');
INSERT INTO Matieres (matiere_nom) VALUES ('Concepts Informatique');
COMMIT;

-- Insertion d'un étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null, -- matricule vide
        'Abdallah', -- nom
        'Abderraouf', -- prénom
        TO_DATE('2001-12-18', 'YYYY-MM-DD'), -- date de naissance
        'Abderraouf.Abdallah@example.com', -- email
        '0796020304', -- téléphone
        'Première Inscription', -- type d'inscription
    -- Liste des matières inscrites
        matiere_list(
                Matiere_Inscrit('Algo')
        ),
    -- Liste des groupes inscrits avec sous-requêtes pour les IDs
        groupe_list()
        ));

-- Insertion d'un étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null, -- matricule vide
        'Kerrouche', -- nom
        'Wissam', -- prénom
        TO_DATE('2002-10-30', 'YYYY-MM-DD'), -- date de naissance
        'Wissam.Kerrouche@example.com', -- email
        '0704020304', -- téléphone
        'Première Inscription', -- type d'inscription
    -- Liste des matières inscrites
        matiere_list(
                Matiere_Inscrit('Algèbre'),
                Matiere_Inscrit('Analyse')
        ),
    -- Liste des groupes inscrits avec sous-requêtes pour les IDs
        groupe_list()
        ));

-- Insertion d'un étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null, -- matricule vide
        'Ait Mokhtar', -- nom
        'Amine', -- prénom
        TO_DATE('2002-05-14', 'YYYY-MM-DD'), -- date de naissance
        'Amine.AitMokhtar@example.com', -- email
        '0704026304', -- téléphone
        'Première Inscription', -- type d'inscription
    -- Liste des matières inscrites
        matiere_list(
                Matiere_Inscrit('Concepts Informatique'),
                Matiere_Inscrit('Analyse')
        ),
    -- Liste des groupes inscrits avec sous-requêtes pour les IDs
        groupe_list()
        ));

-- Insertion d'un étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null, -- matricule vide
        'Abrous', -- nom
        'Celia', -- prénom
        TO_DATE('2002-02-04', 'YYYY-MM-DD'), -- date de naissance
        'Celia.Abrous@example.com', -- email
        '0742026304', -- téléphone
        'Première Inscription', -- type d'inscription
    -- Liste des matières inscrites
        matiere_list(
                Matiere_Inscrit('Algo'),
                Matiere_Inscrit('Algèbre')
        ),
    -- Liste des groupes inscrits avec sous-requêtes pour les IDs
        groupe_list()
        ));

-- Insertion d'un étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null, -- matricule vide
        'Sanogo', -- nom
        'Mohamed', -- prénom
        TO_DATE('2001-05-24', 'YYYY-MM-DD'), -- date de naissance
        'Mohamed.Sanogo@example.com', -- email
        '0762046304', -- téléphone
        'Première Inscription', -- type d'inscription
    -- Liste des matières inscrites
        matiere_list(
                Matiere_Inscrit('Algo'),
                Matiere_Inscrit('Algèbre')
        ),
    -- Liste des groupes inscrits avec sous-requêtes pour les IDs
        groupe_list()
        ));

-- Insertion d'un étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null, -- matricule vide
        'Gana-gey', -- nom
        'Idris', -- prénom
        TO_DATE('2001-12-03', 'YYYY-MM-DD'), -- date de naissance
        'Idris.Ganagey@example.com', -- email
        '0742003204', -- téléphone
        'Première Inscription', -- type d'inscription
    -- Liste des matières inscrites
        matiere_list(
                Matiere_Inscrit('Concepts Informatique'),
                Matiere_Inscrit('Analyse'),
                Matiere_Inscrit('Algo'),
                Matiere_Inscrit('Algèbre')
        ),
    -- Liste des groupes inscrits avec sous-requêtes pour les IDs
        groupe_list()
        ));

CREATE OR REPLACE TYPE edt_type AS OBJECT (
    edt_id NUMBER,
    jour_semaine VARCHAR2(10),
    horaire NUMBER(1), -- 1, 2, 3 ou 4
    groupe_id Number
);

CREATE TABLE emploi_du_temps OF edt_type(
    CONSTRAINT edt_id_pk PRIMARY KEY (edt_id),
    CONSTRAINT jour_semaine_check CHECK (jour_semaine IN ('Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi')),
    CONSTRAINT horaire_check CHECK (horaire IN (1, 2, 3, 4)),
    CONSTRAINT fk_groupe_id FOREIGN KEY (groupe_id) REFERENCES groupe(groupe_id)
);

CREATE SEQUENCE seq_emploi_du_temps
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_auto_edt_id
BEFORE INSERT ON emploi_du_temps
FOR EACH ROW
BEGIN
    -- Attribuer la prochaine valeur de la séquence à edt_id si edt_id n'est pas spécifié
    IF :NEW.edt_id IS NULL THEN
        :NEW.edt_id := seq_emploi_du_temps.NEXTVAL;
    END IF;
END;


CREATE OR REPLACE TRIGGER trg_check_emploi_du_temps
BEFORE INSERT ON emploi_du_temps
FOR EACH ROW
DECLARE
    v_conflict_count NUMBER;
BEGIN
    -- Vérification des conflits pour chaque étudiant dans le groupe inscrit
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM emploi_du_temps edt
    WHERE edt.jour_semaine = :NEW.jour_semaine
      AND edt.horaire = :NEW.horaire
      AND EXISTS (
          SELECT 1
          FROM etudiant e
          WHERE :NEW.groupe_id MEMBER OF e.groupes_inscrit
            AND EXISTS (
                SELECT 1
                FROM TABLE(e.groupes_inscrit) g
                WHERE g.column_value = edt.groupe_id
                  AND edt.jour_semaine = :NEW.jour_semaine
                  AND edt.horaire = :NEW.horaire
            )
      );

    -- Si un conflit est trouvé
    IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Conflit d''emploi du temps : Un étudiant est déjà inscrit dans un autre cours au même horaire dans un autre groupe.');
    END IF;
END;
/

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    1,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'CM') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    2,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algèbre' AND type_group = 'CM') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    4,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '2') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    4,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TD' AND num_groupe = '2') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    2,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algèbre' AND type_group = 'CM') -- groupe_id dynamique basé sur type_group
);

-- cette insertion est sensée à échouer !!!!
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    2,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '1') -- groupe_id dynamique basé sur type_group
);

-- cette insertion est sensée à échouer !!!!
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi', -- jour_semaine
    2,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '1') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mardi', -- jour_semaine
    4,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '1') -- groupe_id dynamique basé sur type_group
);


INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mardi', -- jour_semaine
    4,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TD' AND num_groupe = '2') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mercredi', -- jour_semaine
    1,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = '1') -- groupe_id dynamique basé sur type_group
);

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mercredi', -- jour_semaine
    1,       -- horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Concepts Informatique' AND type_group = 'TP' AND num_groupe = '2') -- groupe_id dynamique basé sur type_group
);



SELECT * from Matieres;
SELECT * from ETUDIANT;
SELECT * from groupe;
SELECT * from emploi_du_temps;

-- Requete emploi du temps avec JOIN
/*

SELECT
    CASE
        WHEN e.horaire = 1 THEN '8h-10h'
        WHEN e.horaire = 2 THEN '10h-12h'
        WHEN e.horaire = 3 THEN '13h30-14h30'
        WHEN e.horaire = 4 THEN '14h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Horaire",

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
    groupe g ON e.groupe_id = g.groupe_id
GROUP BY
    e.horaire
ORDER BY
    e.horaire;
*/

-- Requete emploi du temps sans JOIN explicite et utilisant la méthode get details du type objet groupe
SELECT
    CASE
        WHEN e.horaire = 1 THEN '8h-10h'
        WHEN e.horaire = 2 THEN '10h-12h'
        WHEN e.horaire = 3 THEN '13h30-14h30'
        WHEN e.horaire = 4 THEN '14h30-17h30'
        ELSE 'Horaire inconnu'
    END AS "Horaire",

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
    e.horaire
ORDER BY
    e.horaire;

DECLARE
    v_sql VARCHAR2(4000);
    v_columns VARCHAR2(4000);
BEGIN
    -- Étape 1 : Générer dynamiquement les colonnes pour le PIVOT (les matières)
    -- On récupère les matières à l'aide de LISTAGG et on les stocke dans v_columns
    SELECT LISTAGG('''' || matiere_nom || '''', ', ') WITHIN GROUP (ORDER BY matiere_nom)
    INTO v_columns
    FROM Matieres;

    -- Étape 2 : Construire la requête dynamique sans la partie PIVOT
    v_sql := 'SELECT matricule, matiere_nom,
                      LISTAGG(g.type_group || '' '' || g.num_groupe, '','') WITHIN GROUP (ORDER BY g.num_groupe) AS groupes
               FROM etudiant e
               JOIN TABLE(e.matieres_inscrit) m ON 1 = 1
               LEFT JOIN groupe g ON g.matiere = m.matiere_nom
               AND g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit))
               GROUP BY matricule, matiere_nom';

    -- Étape 3 : Construire la partie PIVOT dynamiquement
    v_sql := 'SELECT * FROM (' || v_sql || ') PIVOT (
                 MAX(groupes)
                 FOR matiere_nom IN (' || v_columns || ')
             ) ORDER BY matricule';

    -- Afficher la requête dynamique pour vérification
    DBMS_OUTPUT.PUT_LINE(v_sql);

    -- Étape 4 : Exécuter la requête dynamique
    EXECUTE IMMEDIATE v_sql;

END;
/

-- Requete pour afficher la table étudiant avec JOIN
/*
SELECT * FROM (SELECT matricule, matiere_nom,
LISTAGG(g.type_group || ' ' || g.num_groupe, ',') WITHIN GROUP (ORDER BY g.num_groupe) AS groupes
FROM etudiant e
JOIN TABLE(e.matieres_inscrit) m ON 1 = 1
LEFT JOIN groupe g ON g.matiere = m.matiere_nom
AND g.groupe_id IN (SELECT COLUMN_VALUE FROM TABLE(e.groupes_inscrit))
GROUP BY matricule, matiere_nom) PIVOT (
MAX(groupes)
FOR matiere_nom IN ('Algo', 'Algèbre', 'Analyse', 'Concepts Informatique')
) ORDER BY matricule
*/

-- Requete pour afficher la table étudiant sans JOIN
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

commit;

TRUNCATE TABLE emploi_du_temps;  -- pour vider la table emploi du temps