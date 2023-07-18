SELECT * FROM biblioteca
SELECT * FROM compras
SELECT * FROM usuarios 
SELECT * FROM jogos

select version()

EXPLAIN (ANALYZE)SELECT J.ID_jogo, J.titulo, J.genero, J.nota, COUNT(C.ID_jogo) AS qtd_vendas
FROM jogos J
INNER JOIN compras C ON J.ID_jogo = C.ID_jogo
WHERE J.titulo ILIKE '%Pokémon%' AND j.ano_lancamento >= 2010
GROUP BY J.ID_jogo

SELECT * FROM compras_pokemon

CREATE MATERIALIZED VIEW compras_pokemon AS
SELECT J.ID_jogo FROM Jogos J NATURAL JOIN compras C 
WHERE J.titulo LIKE '%Pokémon%'
ORDER BY J.titulo DESC

DROP MATERIALIZED VIEW compras_pokemon

CREATE MATERIALIZED VIEW jogos_pokemon AS 
SELECT * FROM jogos J
WHERE J.titulo LIKE '%Pokémon%'
ORDER BY J.titulo, J.ano_lancamento DESC

ALTER TABLE jogos_pokemon SET (fillfactor = 100);
ALTER TABLE compras_pokemon SET (fillfactor = 100);


SELECT * FROM jogos_pokemon
DROP MATERIALIZED VIEW jogos_pokemon


CREATE INDEX id_pokemon_idx ON compras_pokemon (id_jogo)
DROP INDEX id_pokemon_idx


EXPLAIN (ANALYZE) SELECT J.ID_jogo, COUNT(P.ID_jogo) AS qtd_vendas
FROM jogos_pokemon J NATURAL JOIN compras_pokemon P 
WHERE  j.ano_lancamento >= 2010 
GROUP BY J.id_jogo