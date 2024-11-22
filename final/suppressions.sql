-- Instructions pour supprimer les déclencheurs
DROP TRIGGER trg_after_insert_etudiant;
DROP TRIGGER trg_after_insert_matieres;
DROP TRIGGER trg_check_emploi_du_temps;
DROP TRIGGER trg_before_insert_etudiant;
DROP TRIGGER trg_before_insert_groupe;

-- Instructions pour supprimer les types
DROP TYPE edt_type;
DROP TYPE groupe_list;
DROP TYPE matiere_list;
DROP TYPE Groupe_type;
DROP TYPE Matiere_Inscrit;

-- Instructions pour supprimer les tables
DROP TABLE emploi_du_temps;
DROP TABLE etudiant;
DROP TABLE groupe;
DROP TABLE Matieres;

-- Instructions pour supprimer les séquences
DROP SEQUENCE groupe_id_seq;
DROP SEQUENCE matricule_seq;
DROP SEQUENCE seq_emploi_du_temps;


-- Vider la table emploi_du_temps
TRUNCATE TABLE emploi_du_temps;  -- Supprime toutes les données de la table
TRUNCATE TABLE MATIERES;  -- Supprime toutes les données de la table



/*
-- Supprimer les déclencheurs
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_before_insert_groupe';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le déclencheur n'existe pas
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_after_insert_matieres';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le déclencheur n'existe pas
END;

-- Supprimer les tables
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE etudiant';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si la table n'existe pas
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE groupe';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si la table n'existe pas
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Matieres';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si la table n'existe pas
END;

-- Supprimer la séquence
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE groupe_id_seq';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si la séquence n'existe pas
END;

-- Supprimer les types de table imbriquée
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE groupe_list';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le type n'existe pas
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE matiere_list';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le type n'existe pas
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE Matiere_Inscrit';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le type n'existe pas
END;

-- Supprimer les types pour les objets
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE Etudiant_type';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le type n'existe pas
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE Groupe_type';
EXCEPTION
    WHEN OTHERS THEN
        NULL;  -- Ignore l'erreur si le type n'existe pas
END;

*/

