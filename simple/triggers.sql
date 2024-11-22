-- Déclencheur pour insérer des groupes par défaut après insertion d'une matière
CREATE OR REPLACE TRIGGER trg_after_insert_matieres
    AFTER INSERT
    ON Matieres
    FOR EACH ROW
BEGIN
    -- Insertion de groupes par défaut pour chaque type de cours (CM, TD, TP)
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'CM', 0, 80, 80);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 1, 40, 40);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 2, 40, 40);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 3, 40, 40);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 4, 40, 40);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 1, 20, 20);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 2, 20, 20);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 3, 20, 20);
    INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 4, 20, 20);
END;
/

CREATE OR REPLACE TRIGGER trg_before_insert_groupe
    BEFORE INSERT
    ON groupe
    FOR EACH ROW
BEGIN
    :NEW.groupe_id := groupe_id_seq.NEXTVAL;  -- Attribue l'ID de groupe suivant de la séquence
END;

-- Déclencheur pour générer automatiquement l'ID de l'emploi du temps
CREATE OR REPLACE TRIGGER trg_auto_edt_id
    BEFORE INSERT ON emploi_du_temps
    FOR EACH ROW
BEGIN
    -- Attribue l'ID de l'emploi du temps de la séquence si non spécifié
    IF :NEW.edt_id IS NULL THEN
        :NEW.edt_id := seq_emploi_du_temps.NEXTVAL;
    END IF;
END;
/

commit;