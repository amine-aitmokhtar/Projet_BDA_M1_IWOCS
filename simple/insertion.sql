TRUNCATE TABLE emploi_du_temps;
TRUNCATE TABLE MATIERES;
TRUNCATE TABLE etudiant;
TRUNCATE TABLE groupe;

-- Insertion des matières dans la table Matieres
INSERT INTO Matieres (matiere_nom) VALUES ('Programmation');          -- Ajoute la matière Programmation
INSERT INTO Matieres (matiere_nom) VALUES ('Linux');                  -- Ajoute la matière Linux
INSERT INTO Matieres (matiere_nom) VALUES ('Anglais');                -- Ajoute la matière Anglais
INSERT INTO Matieres (matiere_nom) VALUES ('Astrophysique');          -- Ajoute la matière Astrophysique
INSERT INTO Matieres (matiere_nom) VALUES ('NSI');                    -- Ajoute la matière NSI
INSERT INTO Matieres (matiere_nom) VALUES ('Concepts informatiques'); -- Ajoute la matière Concepts informatiques
INSERT INTO Matieres (matiere_nom) VALUES ('Analyse');                -- Ajoute la matière Analyse
INSERT INTO Matieres (matiere_nom) VALUES ('Algèbre');                -- Ajoute la matière Algèbre
INSERT INTO Matieres (matiere_nom) VALUES ('Remediation');            -- Ajoute la matière Remediation
COMMIT;  -- Valide toutes les insertions effectuées

-- Etudiant 1
INSERT INTO etudiant
VALUES (Etudiant_type(
    '2024001',
    'Martin',
    'Pierre',
    TO_DATE('2001-01-01', 'YYYY-MM-DD'),
    'martin.pierre@example.com',
    '0601020304',
    'Première Inscription',
    matiere_list(
        Matiere_Inscrit('Programmation'),
        Matiere_Inscrit('Linux'),
        Matiere_Inscrit('Algèbre'),
        Matiere_Inscrit('Anglais')
    ),
    groupe_list(
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe =2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe =2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algèbre' AND g.type_group = 'CM' AND g.num_groupe =0),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Anglais' AND g.type_group = 'TD' AND g.num_groupe =3)
    )
));

-- Durand, Lucie
INSERT INTO etudiant
VALUES (Etudiant_type(
    '20240002',
    'Durand',
    'Lucie',
    TO_DATE('2001-01-01', 'YYYY-MM-DD'),
    'lucie.durand@example.com',
    '0601020304',
    'Première Inscription',
    matiere_list(
        Matiere_Inscrit('Programmation'),
        Matiere_Inscrit('Linux'),
        Matiere_Inscrit('Algèbre'),
        Matiere_Inscrit('Anglais')
    ),
    groupe_list(
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algèbre' AND g.type_group = 'CM' AND g.num_groupe = 1),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Anglais' AND g.type_group = 'TD' AND g.num_groupe = 3)
    )
));

-- Lefevre, Jean
INSERT INTO etudiant
VALUES (Etudiant_type(
    '20240003',
    'Lefevre',
    'Jean',
    TO_DATE('2001-02-02', 'YYYY-MM-DD'),
    'jean.lefevre@example.com',
    '0602030405',
    'Première Inscription',
    matiere_list(
        Matiere_Inscrit('Programmation'),
        Matiere_Inscrit('Linux'),
        Matiere_Inscrit('Algèbre'),
        Matiere_Inscrit('Anglais')
    ),
    groupe_list(
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algèbre' AND g.type_group = 'CM' AND g.num_groupe = 1),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Anglais' AND g.type_group = 'TD' AND g.num_groupe = 3)
    )
));

-- Simon, Marie
INSERT INTO etudiant
VALUES (Etudiant_type(
    '20240004',
    'Simon',
    'Marie',
    TO_DATE('2001-03-03', 'YYYY-MM-DD'),
    'marie.simon@example.com',
    '0603040506',
    'Première Inscription',
    matiere_list(
        Matiere_Inscrit('Programmation'),
        Matiere_Inscrit('Linux'),
        Matiere_Inscrit('Algèbre'),
        Matiere_Inscrit('Anglais')
    ),
    groupe_list(
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algèbre' AND g.type_group = 'CM' AND g.num_groupe = 1),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Anglais' AND g.type_group = 'TD' AND g.num_groupe = 3)
    )
));

-- Roux, Sophie
INSERT INTO etudiant
VALUES (Etudiant_type(
    '20240006',
    'Roux',
    'Sophie',
    TO_DATE('2001-06-06', 'YYYY-MM-DD'),
    'sophie.roux@example.com',
    '0606070809',
    'Première Inscription',
    matiere_list(
        Matiere_Inscrit('Concepts informatiques'),
        Matiere_Inscrit('Linux'),
        Matiere_Inscrit('Algèbre'),
        Matiere_Inscrit('Anglais')
    ),
    groupe_list(
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Concepts informatiques' AND g.type_group = 'TP' AND g.num_groupe = 4),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algèbre' AND g.type_group = 'CM' AND g.num_groupe = 1),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Anglais' AND g.type_group = 'TD' AND g.num_groupe = 3)
    )
));

-- Petit, Vincent
INSERT INTO etudiant
VALUES (Etudiant_type(
    '20240007',
    'Petit',
    'Vincent',
    TO_DATE('2001-07-07', 'YYYY-MM-DD'),
    'vincent.petit@example.com',
    '0607080910',
    'Première Inscription',
    matiere_list(
        Matiere_Inscrit('Programmation'),
        Matiere_Inscrit('Linux'),
        Matiere_Inscrit('Algèbre'),
        Matiere_Inscrit('Anglais')
    ),
    groupe_list(
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Algèbre' AND g.type_group = 'CM' AND g.num_groupe = 1),
        (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Anglais' AND g.type_group = 'TD' AND g.num_groupe = 3)
    )
));

-- Lundi, 1, Programmation, TP, 1
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Lundi',
    1,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 1)
);

-- Mercredi, 2, Programmation, TP, 1
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mercredi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 1)
);

-- Lundi, 3, Linux, TP, 1
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Lundi',
    3,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 1)
);

-- Vendredi, 2, Linux, TP, 1
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Vendredi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 1)
);

-- Mardi, 1, Programmation, TP, 2
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mardi',
    1,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 2)
);

-- Jeudi, 2, Programmation, TP, 2
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Jeudi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 2)
);

-- Mercredi, 2, Linux, TP, 2
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mercredi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2)
);

-- Jeudi, 1, Linux, TP, 2
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Jeudi',
    1,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 2)
);

-- Lundi, 3, Programmation, TP, 3
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Lundi',
    3,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 3)
);

-- Mercredi, 3, Programmation, TP, 3
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mercredi',
    3,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 3)
);

-- Mardi, 4, Linux, TP, 3
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mardi',
    4,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 3)
);

-- Jeudi, 2, Linux, TP, 3
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Jeudi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 3)
);

-- Mardi, 4, Programmation, TP, 4
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mardi',
    4,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 4)
);

-- Jeudi, 2, Programmation, TP, 4
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Jeudi',
    2,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Programmation' AND g.type_group = 'TP' AND g.num_groupe = 4)
);

-- Mardi, 1, Linux, TP, 4
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mardi',
    1,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 4)
);

-- Mercredi, 1, Linux, TP, 4
INSERT INTO emploi_du_temps (jour_semaine, horaire, groupe_ref)
VALUES (
    'Mercredi',
    1,
    (SELECT REF(g) FROM groupe g WHERE g.matiere = 'Linux' AND g.type_group = 'TP' AND g.num_groupe = 4)
);

commit;