-- Création du type "Groupe_type" pour représenter un groupe avec ses attributs
CREATE OR REPLACE TYPE Groupe_type AS OBJECT
(
    groupe_id  NUMBER,               -- Identifiant unique du groupe
    matiere    VARCHAR2(50),         -- Nom de la matière associée
    type_group VARCHAR2(2),          -- Type de groupe : CM, TD ou TP
    num_groupe NUMBER(1),            -- Numéro du groupe (1, 2, 3, 4 ; 0 pour CM)
    capacite   NUMBER,               -- Capacité totale du groupe
    place_libre NUMBER,              -- Nombre de places libres restantes

    -- Méthode pour obtenir une description détaillée du groupe
    MEMBER FUNCTION get_details RETURN VARCHAR2
);

-- Implémentation de la méthode "get_details" pour "Groupe_type"
CREATE OR REPLACE TYPE BODY Groupe_type AS
    MEMBER FUNCTION get_details RETURN VARCHAR2 IS
    BEGIN
        RETURN matiere || ' ' || type_group || ' ' || num_groupe;  -- Retourne les détails du groupe
    END get_details;
END;
/

-- Séquence pour générer automatiquement les identifiants des groupes
CREATE SEQUENCE groupe_id_seq
    START WITH 1 INCREMENT BY 1 NOCACHE;  -- Commence à 1, incrément de 1, sans mise en cache

-- Définition du type "Matiere_Inscrit" pour représenter une matière inscrite
CREATE OR REPLACE TYPE Matiere_Inscrit AS OBJECT
(
    matiere_nom VARCHAR2(50)         -- Nom de la matière inscrite
);

-- Définition d'une collection (liste) de matières inscrites
CREATE OR REPLACE TYPE matiere_list AS TABLE OF Matiere_Inscrit;

-- Définition d'une collection (liste) d'identifiants de groupes
CREATE OR REPLACE TYPE groupe_list AS TABLE OF REF Groupe_type;

-- Définition du type "Etudiant_type" représentant un étudiant avec ses attributs et inscriptions
CREATE OR REPLACE TYPE Etudiant_type AS OBJECT
(
    matricule        VARCHAR2(10),     -- Matricule unique de l'étudiant
    nom              VARCHAR2(50),     -- Nom de l'étudiant
    prenom           VARCHAR2(50),     -- Prénom de l'étudiant
    date_naissance   DATE,             -- Date de naissance
    email            VARCHAR2(100),    -- Adresse email
    telephone        VARCHAR2(15),     -- Numéro de téléphone
    type_inscription VARCHAR2(50),     -- ype d'inscription (Première inscription, Réinscription, etc.)
    matieres_inscrit matiere_list,     -- Liste des matières auxquelles l'étudiant est inscrit
    groupes_inscrit  groupe_list       -- Liste des groupes auxquels l'étudiant est inscrit
);

-- Séquence pour générer automatiquement les matricules des étudiants
CREATE SEQUENCE matricule_seq
    START WITH 1        -- Débute à 1
    INCREMENT BY 1      -- Incrémente de 1
    NOCACHE;            -- Pas de mise en cache des valeurs

-- Définition du type "edt_type" pour représenter une entrée d'emploi du temps
-- Mise à jour du type "edt_type" pour inclure l'enseignant_id
CREATE OR REPLACE TYPE edt_type AS OBJECT
(
    edt_id NUMBER,                  -- Identifiant unique de l'emploi du temps
    jour_semaine VARCHAR2(10),      -- Jour de la semaine (ex : Lundi, Mardi)
    horaire NUMBER(1),              -- Numéro de l'horaire (1, 2, 3, 4)
    groupe_ref REF Groupe_type
);


-- Séquence pour générer automatiquement les identifiants des emplois du temps
CREATE SEQUENCE seq_emploi_du_temps
    START WITH 1 INCREMENT BY 1;    -- Débute à 1, incrément de 1

commit;