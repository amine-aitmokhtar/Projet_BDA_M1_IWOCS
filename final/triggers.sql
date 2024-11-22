-- Déclencheur pour générer automatiquement l'ID du groupe avant insertion
CREATE OR REPLACE TRIGGER trg_before_insert_groupe
    BEFORE INSERT
    ON groupe
    FOR EACH ROW
BEGIN
    :NEW.groupe_id := groupe_id_seq.NEXTVAL;  -- Attribue l'ID de groupe suivant de la séquence
END;
/

-- -- Déclencheur pour générer le matricule de l'étudiant avant insertion
-- CREATE OR REPLACE TRIGGER trg_before_insert_etudiant
--     BEFORE INSERT
--     ON etudiant
--     FOR EACH ROW
-- BEGIN
--     -- Génère un matricule unique basé sur le prénom, le nom et l'année de naissance
--     :NEW.matricule :=
--         UPPER(SUBSTR(:NEW.prenom, 1, 1)) ||  -- Première lettre du prénom en majuscule
--         UPPER(SUBSTR(:NEW.nom, 1, 1)) ||     -- Première lettre du nom en majuscule
--         SUBSTR(TO_CHAR(:NEW.date_naissance, 'YYYY'), 3, 2) ||  -- Deux derniers chiffres de l'année de naissance
--         LPAD(matricule_seq.NEXTVAL, 3, '0');  -- Numéro incrémenté de la séquence, avec zéro-padding
-- END;
-- /
--
-- -- Déclencheur pour insérer des groupes par défaut après insertion d'une matière
-- CREATE OR REPLACE TRIGGER trg_after_insert_matieres
--     AFTER INSERT
--     ON Matieres
--     FOR EACH ROW
-- BEGIN
--     -- Insertion de groupes par défaut pour chaque type de cours (CM, TD, TP)
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'CM', 0, 80, 80);
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 1, 40, 40);
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TD', 2, 40, 40);
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 1, 20, 20);
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 2, 20, 20);
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 3, 20, 20);
--     INSERT INTO groupe (matiere, type_group, num_groupe, capacite, place_libre) VALUES (:NEW.matiere_nom, 'TP', 4, 20, 20);
-- END;
-- /

-- Déclencheur pour affecter des groupes à un étudiant avant insertion
-- CREATE OR REPLACE TRIGGER trg_after_insert_etudiant
--     BEFORE INSERT ON etudiant
--     FOR EACH ROW
-- DECLARE
--     v_groupe_id NUMBER;
-- BEGIN
--     -- Parcourt chaque matière inscrite de l'étudiant pour lui affecter des groupes
--     FOR i IN 1 .. :NEW.matieres_inscrit.COUNT LOOP
--         -- Affecte un groupe de CM disponible
--         SELECT groupe_id INTO v_groupe_id
--         FROM groupe
--         WHERE matiere = :NEW.matieres_inscrit(i).matiere_nom
--           AND type_group = 'CM'
--           AND place_libre > 0
--         ORDER BY place_libre DESC
--         FETCH FIRST 1 ROWS ONLY;
--
--         :NEW.groupes_inscrit.EXTEND;  -- Étend la liste des groupes
--         :NEW.groupes_inscrit(:NEW.groupes_inscrit.COUNT) := v_groupe_id;  -- Ajoute le groupe
--         UPDATE groupe SET place_libre = place_libre - 1 WHERE groupe_id = v_groupe_id;  -- Met à jour les places disponibles
--
--         -- Affecte un groupe de TD disponible
--         SELECT groupe_id INTO v_groupe_id
--         FROM groupe
--         WHERE matiere = :NEW.matieres_inscrit(i).matiere_nom
--           AND type_group = 'TD'
--           AND place_libre > 0
--         ORDER BY place_libre DESC
--         FETCH FIRST 1 ROWS ONLY;
--
--         :NEW.groupes_inscrit.EXTEND;
--         :NEW.groupes_inscrit(:NEW.groupes_inscrit.COUNT) := v_groupe_id;
--         UPDATE groupe SET place_libre = place_libre - 1 WHERE groupe_id = v_groupe_id;
--
--         -- Affecte un groupe de TP disponible
--         SELECT groupe_id INTO v_groupe_id
--         FROM groupe
--         WHERE matiere = :NEW.matieres_inscrit(i).matiere_nom
--           AND type_group = 'TP'
--           AND place_libre > 0
--         ORDER BY place_libre DESC
--         FETCH FIRST 1 ROWS ONLY;
--
--         :NEW.groupes_inscrit.EXTEND;
--         :NEW.groupes_inscrit(:NEW.groupes_inscrit.COUNT) := v_groupe_id;
--         UPDATE groupe SET place_libre = place_libre - 1 WHERE groupe_id = v_groupe_id;
--     END LOOP;
-- END;
-- /

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

-- -- Déclencheur pour vérifier les conflits d'emploi du temps avant insertion
-- CREATE OR REPLACE TRIGGER trg_check_emploi_du_temps
--     BEFORE INSERT ON emploi_du_temps
--     FOR EACH ROW
-- DECLARE
--     v_conflict_count NUMBER;
-- BEGIN
--     -- Vérifie les conflits d'emploi du temps pour les étudiants inscrits
--     SELECT COUNT(*)
--     INTO v_conflict_count
--     FROM emploi_du_temps edt
--     WHERE edt.jour_semaine = :NEW.jour_semaine
--       AND edt.horaire = :NEW.horaire
--       AND EXISTS (
--           SELECT 1
--           FROM etudiant e
--           WHERE :NEW.groupe_id MEMBER OF e.groupes_inscrit
--             AND EXISTS (
--                 SELECT 1
--                 FROM TABLE(e.groupes_inscrit) g
--                 WHERE g.column_value = edt.groupe_id
--                   AND edt.jour_semaine = :NEW.jour_semaine
--                   AND edt.horaire = :NEW.horaire
--             )
--       );
--
--     -- Si un conflit est détecté, lève une erreur
--     IF v_conflict_count > 0 THEN
--         RAISE_APPLICATION_ERROR(-20001, 'Conflit d''emploi du temps : Un étudiant est déjà inscrit dans un autre cours au même horaire dans un autre groupe.');
--     END IF;
-- END;
-- /

-- CREATE OR REPLACE TRIGGER trg_check_emploi_du_temps
--     BEFORE INSERT ON emploi_du_temps
--     FOR EACH ROW
-- DECLARE
--     v_conflict_count NUMBER;
-- BEGIN
--     -- Vérifie les conflits d'emploi du temps pour les étudiants inscrits
--     SELECT COUNT(*)
--     INTO v_conflict_count
--     FROM emploi_du_temps edt
--     WHERE edt.jour_semaine = :NEW.jour_semaine
--       AND edt.horaire = :NEW.horaire
--       AND EXISTS (
--           SELECT 1
--           FROM etudiant e
--           WHERE EXISTS (
--               SELECT 1
--               FROM TABLE(e.groupes_inscrit) g
--               WHERE DEREF(g) = DEREF(:NEW.groupe_ref)
--                 AND edt.jour_semaine = :NEW.jour_semaine
--                 AND edt.horaire = :NEW.horaire
--           )
--       );
--
--     -- Si un conflit est détecté, lever une exception
--     IF v_conflict_count > 0 THEN
--         RAISE_APPLICATION_ERROR(-20001, 'Conflit détecté dans l\''emploi du temps pour ce groupe.');
--     END IF;
-- END;
-- /

drop TRIGGER trg_check_emploi_du_temps;

CREATE OR REPLACE TRIGGER trg_check_emploi_du_temps
    BEFORE INSERT ON emploi_du_temps
    FOR EACH ROW
DECLARE
    v_conflict_count NUMBER;
BEGIN
    -- Vérifie les conflits d'emploi du temps pour les étudiants inscrits
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM emploi_du_temps edt
    WHERE edt.jour_semaine = :NEW.jour_semaine
      AND edt.horaire = :NEW.horaire
      AND EXISTS (
          SELECT 1
          FROM etudiant e
          WHERE EXISTS (
              SELECT 1
              FROM TABLE(e.groupes_inscrit) g
              WHERE g = :NEW.groupe_ref -- Comparaison directe des REF
          )
      );

    -- Si un conflit est détecté, lever une exception
    IF v_conflict_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Conflit détecté dans l\''emploi du temps pour ce groupe.');
    END IF;
END;
/


ALTER TRIGGER trg_check_emploi_du_temps COMPILE;
commit;
