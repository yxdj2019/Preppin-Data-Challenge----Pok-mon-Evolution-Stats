create database Pokemon_Evolution_Stats;

use Pokemon_Evolution_Stats;

-- --------------------- prepping and cleaning data of Pokemon_Evolution_Stats
-- ------------------------------------------------------------------

-- remove the columns height, weight and evolves from
Alter table pks
drop height,
drop weight,
drop evolves_from;

-- sum up hp, attack, defense, special_attack, special_defense, and speed for combat_factors
CREATE TABLE pks1 AS SELECT name,
    pokedex_number,
    gen_introduced,
    (hp + attack + defense + special_attack + special_defense + speed) AS combat_factors FROM
    pks;

-- If a Pokémon doesn't evolve remove it from the dataset
DELETE FROM pke 
WHERE
    Stage_2 IS NULL AND Stage_3 IS NULL;

-- left join pke with pks1 on Stage_1
CREATE TABLE Combine_pk AS SELECT * FROM
    pke
        LEFT JOIN
    pks1 ON pke.Stage_1 = pks1.name;

-- drop name column
alter table Combine_pk drop name;

-- change name of combat_power
alter table Combine_pk change combat_factors initial_combat_power int;

-- drop pokedex_number, gen_introduced in pks1
alter table pks1 drop pokedex_number, drop gen_introduced;

-- left join Combine_pk with pks1 on Stage_3
CREATE TABLE Combine_pk1 AS SELECT Combine_pk.*, pks1.combat_factors AS final_combat_power FROM
    Combine_pk
        LEFT JOIN
    pks1 ON Combine_pk.Stage_3 = pks1.name;


-- fill values of final_combat_power for pokemon with only Stage_2 
UPDATE Combine_pk1,
    pks1 
SET 
    Combine_pk1.final_combat_power = pks1.combat_factors
WHERE
    Combine_pk1.Stage_2 = pks1.name
        AND Combine_pk1.Stage_3 IS NULL;

-- add combat_power_increase
alter table Combine_pk1 add combat_power_increase float;

UPDATE Combine_pk1 
SET 
    combat_power_increase = final_combat_power / initial_combat_power - 1;

-- Sort the dataset, ascending by percentage increase
SELECT 
    *
FROM
    Combine_pk1
ORDER BY combat_power_increase ASC;



