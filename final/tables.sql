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
    CONSTRAINT type_group_valid CHECK (type_group IN ('CM', 'TD', 'TP'))  -- Vérifie les valeurs valides de "type_group"
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
    CONSTRAINT horaire_check CHECK (horaire IN (1, 2, 3, 4))          -- Vérifie les horaires valides
--     groupe_ref REF Groupe_type SCOPE IS groupe
--     CONSTRAINT fk_groupe_id FOREIGN KEY (groupe_id) REFERENCES groupe(groupe_id) -- Clé étrangère vers "groupe"
);

