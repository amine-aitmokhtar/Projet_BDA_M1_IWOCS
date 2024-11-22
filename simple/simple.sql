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
CREATE OR REPLACE TYPE groupe_list AS TABLE OF NUMBER;

-- Définition du type "Etudiant_type" représentant un étudiant avec ses attributs et inscriptions
CREATE OR REPLACE TYPE Etudiant_type AS OBJECT
(
    matricule        VARCHAR2(10),     -- Matricule unique de l'étudiant
    nom              VARCHAR2(50),     -- Nom de l'étudiant
    prenom           VARCHAR2(50),     -- Prénom de l'étudiant
    date_naissance   DATE,             -- Date de naissance
    email            VARCHAR2(100),    -- Adresse email
    telephone        VARCHAR2(15),     -- Numéro de téléphone
    type_inscription VARCHAR2(50),     -- Type d'inscription (Première inscription, Réinscription, etc.)
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
    groupe_id NUMBER,               -- Identifiant du groupe associé
    enseignant_id NUMBER            -- Identifiant de l'enseignant associé
);


-- Séquence pour générer automatiquement les identifiants des emplois du temps
CREATE SEQUENCE seq_emploi_du_temps
    START WITH 1 INCREMENT BY 1;    -- Débute à 1, incrément de 1


------------------------------------------
-- Étape 1 : Créer la table des matières
-- Définition de la table "Matieres" avec "matiere_nom" comme clé primaire
CREATE TABLE Matieres
(
    matiere_nom VARCHAR2(50) PRIMARY KEY
);

-- Étape 2 : Créer la table "groupe" avec contraintes
-- Définition de la table "groupe" basée sur le type "Groupe_type"
CREATE TABLE groupe OF Groupe_type(
    CONSTRAINT group_id_pk PRIMARY KEY(groupe_id),   -- Clé primaire sur "groupe_id"
    CONSTRAINT capacite_not_null CHECK (capacite IS NOT NULL),  -- Vérifie que "capacite" n'est pas NULL
    CONSTRAINT capacite_positive CHECK (capacite > 0),         -- Vérifie que "capacite" est positive
    CONSTRAINT type_group_valid CHECK (type_group IN ('CM', 'TD', 'TP')),  -- Vérifie les valeurs valides de "type_group"
    CONSTRAINT matiere_valid_fk FOREIGN KEY (matiere) REFERENCES Matieres(matiere_nom) -- Clé étrangère vers "Matieres"
);


-- Étape 3 : Créer la table "etudiant" avec types de table imbriqués
-- Définition de la table "etudiant" basée sur le type "Etudiant_type"
CREATE TABLE etudiant OF Etudiant_type(
    CONSTRAINT pk_matricule PRIMARY KEY (matricule),        -- Clé primaire sur "matricule"
    CONSTRAINT email_not_null CHECK (email IS NOT NULL),    -- Vérifie que "email" n'est pas NULL
    CONSTRAINT unique_email_telephone UNIQUE (email, telephone),  -- Contrainte d'unicité sur "email" et "telephone"
    CONSTRAINT telephone_not_null CHECK (telephone IS NOT NULL),  -- Vérifie que "telephone" n'est pas NULL
    CONSTRAINT chk_type_inscription CHECK (type_inscription IN ('Autres Entrées', 'Première Inscription', 'Réinscription')) -- Vérifie les valeurs valides de "type_inscription"
)
NESTED TABLE matieres_inscrit STORE AS matieres_tab_nested  -- Stockage des matières inscrites dans une table imbriquée
NESTED TABLE groupes_inscrit STORE AS groupes_tab_nested;   -- Stockage des groupes inscrits dans une table imbriquée

-- Étape 4 : Créer la table "emploi_du_temps" avec contraintes
-- Définition de la table "emploi_du_temps" basée sur le type "edt_type"
CREATE TABLE emploi_du_temps OF edt_type (
    CONSTRAINT edt_id_pk PRIMARY KEY (edt_id),                         -- Clé primaire sur "edt_id"
    CONSTRAINT jour_semaine_check CHECK (jour_semaine IN ('Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi')), -- Vérifie les jours valides
    CONSTRAINT horaire_check CHECK (horaire IN (1, 2, 3, 4)),          -- Vérifie les horaires valides
    CONSTRAINT fk_groupe_id FOREIGN KEY (groupe_id) REFERENCES groupe(groupe_id), -- Clé étrangère vers "groupe"
    CONSTRAINT fk_enseignant_id FOREIGN KEY (enseignant_id) REFERENCES enseignant(enseignant_id) -- Clé étrangère vers "enseignant"

);

-- Création du type "Enseignant_type"
CREATE OR REPLACE TYPE Enseignant_type AS OBJECT
(
    enseignant_id   NUMBER,               -- Identifiant unique de l'enseignant
    nom             VARCHAR2(50),         -- Nom de l'enseignant
    prenom          VARCHAR2(50),         -- Prénom de l'enseignant
    email           VARCHAR2(100),        -- Adresse email de l'enseignant
    specialisation  VARCHAR2(50),         -- Spécialisation de l'enseignant
    matieres_groupes matiere_list,        -- Liste des matières et des groupes associés

    -- Méthode pour obtenir une description de l'enseignant
    MEMBER FUNCTION get_details RETURN VARCHAR2
);

-- Implémentation de la méthode "get_details" pour "Enseignant_type"
CREATE OR REPLACE TYPE BODY Enseignant_type AS
    MEMBER FUNCTION get_details RETURN VARCHAR2 IS
    BEGIN
        RETURN nom || ' ' || prenom || ' (' || specialisation || ')';  -- Détails de l'enseignant
    END get_details;
END;
/

-- Séquence pour générer automatiquement les identifiants des enseignants
CREATE SEQUENCE enseignant_id_seq
    START WITH 1 INCREMENT BY 1 NOCACHE;  -- Commence à 1, incrément de 1, sans mise en cache

-- Création de la table "enseignant" avec le type "Enseignant_type"
CREATE TABLE enseignant OF Enseignant_type(
    CONSTRAINT enseignant_id_pk PRIMARY KEY (enseignant_id),  -- Clé primaire
    CONSTRAINT unique_email CHECK (email IS NOT NULL)         -- Vérifie que l'email n'est pas NULL
)
NESTED TABLE matieres_groupes STORE AS matieres_enseignant_tab_nested;



