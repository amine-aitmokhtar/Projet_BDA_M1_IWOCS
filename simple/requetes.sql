select *
from emploi_du_temps;
select *
from MATIERES;
select *
from etudiant;
select *
from groupe;

commit;

-- Obtenir les cours donnés un jour donné
SELECT DISTINCT DEREF(edt.groupe_ref).matiere AS matiere
FROM emploi_du_temps edt
WHERE edt.jour_semaine = 'Mardi';


-- Liste des étudiants inscrits dans un groupe spécifique
SELECT e.matricule,
       e.nom,
       e.prenom,
       DEREF(VALUE(g)).get_details() AS groupe_details
FROM etudiant e,
     TABLE (e.groupes_inscrit) g
WHERE DEREF(VALUE(g)).matiere = 'Programmation'
  AND DEREF(VALUE(g)).type_group = 'TP'
  AND DEREF(VALUE(g)).num_groupe = 2;


-- Détails d'un étudiant donné
SELECT e.matricule,
       e.nom,
       e.prenom,
       LISTAGG(DEREF(VALUE(g)).get_details(), ', ')
               WITHIN GROUP (ORDER BY DEREF(VALUE(g)).num_groupe) AS groupes_details
FROM etudiant e,
     TABLE (e.groupes_inscrit) g
WHERE e.matricule = '2024001' -- Remplacez '12345' par le matricule de l'étudiant.
GROUP BY e.matricule, e.nom, e.prenom;

-- Emploi du temps d'un étudiant donné
SELECT
    e.matricule,
    e.nom,
    e.prenom,
    edt.jour_semaine,
    edt.horaire,
    DEREF(VALUE(g)).get_details() AS groupe_details

FROM
    etudiant e,
    TABLE(e.groupes_inscrit) g,
    emploi_du_temps edt
WHERE
    e.matricule = '2024001' -- Remplacez par le matricule de l'étudiant
    AND edt.groupe_ref = VALUE(g) -- Associe l'emploi du temps avec les groupes de l'étudiant
ORDER BY
    edt.jour_semaine,
    edt.horaire;




