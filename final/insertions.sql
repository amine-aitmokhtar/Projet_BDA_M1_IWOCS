-- Insertion des matières dans la table Matieres
INSERT INTO Matieres (matiere_nom) VALUES ('Algèbre');               -- Ajoute la matière Algèbre
INSERT INTO Matieres (matiere_nom) VALUES ('Analyse');               -- Ajoute la matière Analyse
INSERT INTO Matieres (matiere_nom) VALUES ('Algo');                  -- Ajoute la matière Algo
INSERT INTO Matieres (matiere_nom) VALUES ('Concepts Informatique'); -- Ajoute la matière Concepts Informatique
COMMIT;  -- Valide toutes les insertions effectuées

-- Insertion des étudiants dans la table etudiant avec des données détaillées
INSERT INTO etudiant
VALUES (Etudiant_type(
        null,                        -- Matricule vide, généré automatiquement
        'Ait mokhtar',               -- Nom
        'Amine',                     -- Prénom
        TO_DATE('2002-12-08', 'YYYY-MM-DD'),  -- Date de naissance
        'Amine.Aitmokhtar@univ-lehavre.fr',       -- Email
        '0704026304',                -- Téléphone
        'Première Inscription',      -- Type d'inscription
        matiere_list(                -- Liste des matières inscrites
                Matiere_Inscrit('Concepts Informatique'),
                Matiere_Inscrit('Analyse')
        ),
        groupe_list()                -- Liste des groupes inscrits
        ));
COMMIT;  -- Valide toutes les insertions effectuées

-- Insertion d'un autre étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null,                        -- Matricule vide, généré automatiquement
        'Abdallah',                  -- Nom de l'étudiant
        'Abderraouf',                -- Prénom de l'étudiant
        TO_DATE('2001-12-18', 'YYYY-MM-DD'),  -- Date de naissance
        'Abderraouf.Abdallah@univ-lehavre.fr',    -- Adresse email
        '0796020304',                -- Numéro de téléphone
        'Première Inscription',      -- Type d'inscription
        matiere_list(                -- Liste des matières inscrites
                Matiere_Inscrit('Algo')
        ),
        groupe_list()                -- Liste vide des groupes inscrits (initialement)
        ));
COMMIT;  -- Valide toutes les insertions effectuées

-- Insertion d'un autre étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null,                        -- Matricule vide, généré automatiquement
        'Sanogo',                    -- Nom
        'Mohamed',                   -- Prénom
        TO_DATE('2001-05-24', 'YYYY-MM-DD'),  -- Date de naissance
        'Mohamed.Sanogo@example.com',         -- Email
        '0762046304',                -- Téléphone
        'Première Inscription',      -- Type d'inscription
        matiere_list(                -- Liste des matières inscrites
                Matiere_Inscrit('Algo'),
                Matiere_Inscrit('Algèbre')
        ),
        groupe_list()                -- Liste des groupes inscrits
        ));
COMMIT;  -- Valide toutes les insertions effectuées

-- Insertion d'un autre étudiant
INSERT INTO etudiant
VALUES (Etudiant_type(
        null,                        -- Matricule vide, généré automatiquement
        'Gana-gey',                  -- Nom
        'Idriss',                    -- Prénom
        TO_DATE('2001-12-03', 'YYYY-MM-DD'),  -- Date de naissance
        'Idriss.Ganagey@example.com',         -- Email
        '0742003204',                -- Téléphone
        'Première Inscription',      -- Type d'inscription
        matiere_list(                -- Liste des matières inscrites
                Matiere_Inscrit('Concepts Informatique'),
                Matiere_Inscrit('Analyse'),
                Matiere_Inscrit('Algo'),
                Matiere_Inscrit('Algèbre')
        ),
        groupe_list()                -- Liste des groupes inscrits
        ));
COMMIT;  -- Valide toutes les insertions effectuées

-- Insertion dans la table emploi_du_temps
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    1,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'CM')  -- Groupe ID basé sur la matière
);
COMMIT;  -- Valide toutes les insertions effectuées

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    2,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algèbre' AND type_group = 'CM')  -- Groupe ID basé sur la matière
);
COMMIT;  -- Valide toutes les insertions effectuées

-- Ajout d'une séance de TD pour Analyse
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    4,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '2')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées

-- Ajout d'une séance de TD pour Algo
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    4,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TD' AND num_groupe = '2')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées

/*
-- Insertion d'un créneau horaire pour Algèbre
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    2,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algèbre' AND type_group = 'CM')  -- Groupe ID basé sur la matière
);
COMMIT;  -- Valide toutes les insertions effectuées
*/

/*
-- Insertion censée échouer pour vérifier les contraintes
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    2,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '1')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées
 */

/*
-- Insertion censée échouer pour vérifier les contraintes
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    2,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '1')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées
*/



-- Insertion d'une séance pour Mardi
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mardi',
    4,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'TD' AND num_groupe = '1')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées


    -- Insertion d'une séance pour Mardi
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    4,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = '1')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',
    4,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = '2')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées

/*
-- Insertion d'une séance pour Algo le Mardi
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mardi',
    4,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TD' AND num_groupe = '2')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées
*/

-- Insertion d'une séance pour Algo le Mercredi
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mercredi',
    1,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = '1')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées


-- Insertion d'une séance pour Concepts Informatique le Mercredi
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mercredi',
    1,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Concepts Informatique' AND type_group = 'TP' AND num_groupe = '2')  -- Groupe ID basé sur la matière et type de groupe
);
COMMIT;  -- Valide toutes les insertions effectuées




-- Insertion dans la table emploi_du_temps avec enseignant_id
INSERT INTO emploi_du_temps ( jour_semaine, horaire, groupe_id)
VALUES (
    'Lundi',                                                      -- Jour de la semaine
    1,                                                            -- Horaire
    (SELECT groupe_id FROM groupe WHERE matiere = 'Analyse' AND type_group = 'CM')  -- Groupe ID basé sur la matière
);
COMMIT;

-- Insertion d'une autre séance pour Algèbre avec enseignant_id
-- Exemple d'insertion avec des noms et types de groupe vérifiés
-- INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
-- VALUES (
--     'Mercredi',
--     2,
--     (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = 1)
-- );
-- Insérer en utilisant REF pour référencer le groupe
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mercredi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algo' AND g.type_group = 'TP' AND g.num_groupe = 1)
);

DECLARE
    grp_ref REF Groupe_type;
BEGIN
    -- Récupérer une référence vers un groupe spécifique
    SELECT REF(g) INTO grp_ref
    FROM groupe g
    WHERE g.matiere = 'Algo' AND g.type_group = 'TP' AND g.num_groupe = 1;

    -- Insérer un emploi du temps avec la référence récupérée
    INSERT INTO emploi_du_temps (edt_id, jour_semaine, horaire, groupe_ref)
    VALUES (
        seq_emploi_du_temps.NEXTVAL,
        'Mercredi',
        2,
        grp_ref
    );
END;
/


COMMIT;

rollback;

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Vendredi',
    1,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = 4)
);
COMMIT;

INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_id)
VALUES (
    'Mercredi',
    2,
    (SELECT groupe_id FROM groupe WHERE matiere = 'Algo' AND type_group = 'TP' AND num_groupe = 2)
);
COMMIT;
