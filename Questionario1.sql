SELECT * FROM departamento
SELECT * FROM empregado
SELECT * FROM tipo_empregado
--1) a) Recupere o número de empregados cadastrados no BD.
SELECT COUNT(*) FROM empregado

--- b)Que tipos de empregados estão presentes em um ou mais departamentos? 
--(i.e. em qualquer departamento ou em toda a empresa)

SELECT tipo_empregado FROM empregado 
WHERE depto IS NOT NULL

--c) Recupere a média dos salários dos departamentos em que a média dos salários é maior que $1200,00.
SELECT AVG(salario) as media
FROM empregado
WHERE depto IN (SELECT depto
			   FROM empregado
			   GROUP BY depto, cpf
			   HAVING AVG(salario)>1200)


--2) Construa uma stored procedure que retorne o número de EMPREGADOS de um DEPARTAMENTO (com o nome fornecido como parâmetro).
--O parâmetro do nome_dpto, quando não especificado, usa um padrão predefinido: nomes que começam com o prefixo ’In’

CREATE OR REPLACE FUNCTION pq_numEmpr(text) RETURNS integer AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM EMPREGADO INNER JOIN departamento ON depto = cod
    WHERE nome_depto ILIKE $1);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM pq_numEmpr('rh')
SELECT * FROM pq_numEmpr('informatica')
DROP FUNCTION pq_numEmpr


/*3) a)
ROW TYPE: É um tipo de variável especial, que é um tipo de "tupla" vazia relacionado a uma tabela, 
assim criasse um tipo de dado semelhante a uma struct com os tipos do elementos da tupla determinada.



%TYPE:  É um tipo de dados que copia/tem sua tipo igual ao tipo de uma coluna.



RECORD: É um tipo de dado usando quando não se sabe previamente o tipo dos dados usados, 
funcionando assim como um tipo coringa ou um tipo void.*/

/*b) Construa uma stored procedure que retorne os EMPREGADOS de um DEPARTAMENTO (com o nome fornecido como parâmetro), s
eus salários e a descrição de TIPO_EMPREGADO.

O parâmetro do nome_dpto, quando não especificado, usa um padrão predefinido: nomes que começam com o prefixo ’In’*/

CREATE OR REPLACE FUNCTION pq_Empr(text) RETURNS setof RECORD AS $$
BEGIN
    RETURN QUERY (SELECT * FROM EMPREGADO INNER JOIN departamento ON depto = cod
    WHERE nome_depto ILIKE $1);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM pq_Empr('rh') as (cpf varchar, nome_empregado varchar, salario numeric, tipo_empregado integer, depto integer,cod integer, nome_depto varchar);
DROP FUNCTION pq_Empr


/*4)a) Construa uma trigger para conferir que o supervisor de um empregado não seja ele mesmo 
– ao inserir ou atualizar um registro da tabela de empregados!

Acrescente os campos necessários na tabela de empregados (auto-relacionamento: campo supervisor)*/
ALTER TABLE empregado ADD supervisor VARCHAR(100);
ALTER TABLE empregado ADD COLUMN trigger_executado boolean DEFAULT FALSE;

CREATE OR REPLACE FUNCTION pq_Supervisor() RETURNS TRIGGER AS $$
DECLARE
    cpf varchar(11);
    nome_empregado varchar;
    salario numeric;
    tipo_empregado integer;
    depto integer;
    supervisor varchar;
BEGIN
    cpf := TG_ARGV[0];
    nome_empregado := TG_ARGV[1];
    salario := TG_ARGV[2]::numeric;
    tipo_empregado := TG_ARGV[3]::integer;
    depto := TG_ARGV[4]::integer;
    supervisor := TG_ARGV[5];
	
	 IF (NEW.trigger_executado = TRUE) THEN
        RETURN NEW;
    END IF;
	
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.cpf = NEW.supervisor) THEN
            RAISE EXCEPTION 'Um supervisor não pode supervisionar a si mesmo';
            RETURN NULL;
        END IF;
        
        RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.cpf = NEW.supervisor) THEN
            RAISE EXCEPTION 'Um supervisor não pode supervisionar a si mesmo';
            RETURN NULL;
        END IF;
        
        RETURN NEW;
    END IF;
	
	 NEW.trigger_executado := TRUE;
    -- Outras operações, como DELETE, não são tratadas nessa função
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_supervisor BEFORE INSERT OR UPDATE ON empregado
FOR EACH ROW EXECUTE PROCEDURE pq_Supervisor();

DROP FUNCTION pq_Supervisor() CASCADE;
DROP TRIGGER IF EXISTS tg_supervisor ON empregado;

INSERT INTO empregado
VALUES (65345678919,'Vandeee', 65.0, 10, 10, 65345678910);

INSERT INTO empregado
VALUES (65345678919,'Vandeee', 65.0, 10, 10, 65345678919);

UPDATE empregado SET supervisor = '65345678919' WHERE cpf = '65345678919'
UPDATE empregado SET supervisor = '65345678919' WHERE cpf = '65345678917'


/* 4b) Construa uma trigger para atualizar o número de empregados de um departamento – 
ao inserir, remover ou atualizar o campo de lotação da tabela de empregados!
Acrescente os campos necessários na tabela de departamentos (relacionamento: campo num_empregados)*/

ALTER TABLE departamento ADD num_empregados INT DEFAULT 0;

CREATE OR REPLACE FUNCTION pq_atualizarNumEmpregado() RETURNS TRIGGER AS $$
BEGIN
    cpf := TG_ARGV[0];
    nome_empregado := TG_ARGV[1];
    salario := TG_ARGV[2]::numeric;
    tipo_empregado := TG_ARGV[3]::integer;
    depto := TG_ARGV[4]::integer;
    supervisor := TG_ARGV[5];
	
	 IF (NEW.trigger_executado = TRUE) THEN
        RETURN NEW;
    END IF;
	
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.cpf = NEW.supervisor) THEN
            RAISE EXCEPTION 'Um supervisor não pode supervisionar a si mesmo';
            RETURN NULL;
        END IF;
        
        RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.cpf = NEW.supervisor) THEN
            RAISE EXCEPTION 'Um supervisor não pode supervisionar a si mesmo';
            RETURN NULL;
        END IF;
        
        RETURN NEW;
    END IF;
	
	 NEW.trigger_executado := TRUE;
    -- Outras operações, como DELETE, não são tratadas nessa função
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
/*4c)  Construa uma view para retornar o número de empregados de todos os departamentos. 
Esta visão é atualizável?*/
CREATE VIEW numEmpr AS 
SELECT COUNT(*)
FROM empregado
WHERE depto IS NOT NULL
SELECT * FROM numEmpr
--Esta view é atualizada automaticamente.

INSERT INTO empregado
VALUES (92345678919,'Vand', 65.0, 10, 10);
SELECT * FROM numEmpr
/*4d) Crie uma tabela temporária para inserir todos os funcionários com a descrição do seu cargo 
(tipo de empregado)*/	

CREATE VIEW funcionario_ AS
SELECT descricao, nome_empregado
FROM empregado INNER JOIN tipo_empregado ON depto = cod

select * from funcionario_

-- 9)Construa uma view para retornar o número de empregados de todos os departamentos. 
--Esta visão é atualizável?

CREATE VIEW numEmpr AS
SELECT COUNT(*)
FROM empregado
WHERE depto IS NOT NULL

SELECT * FROM numEmpr
INSERT INTO empregado
VALUES (92345678919,'Vand', 65.0, 10, 10);
SELECT * FROM numEmpr

--23) a) Construa uma visão que reúna os seguintes campos: nome do empregado, descrição do departamento, 
--descrição do tipo empregado e salário do empregado.

CREATE VIEW dados_empr AS
SELECT nome_empregado, nome_depto, descricao, salario
FROM empregado E INNER JOIN departamento D ON E.depto = D.cod 
INNER JOIN tipo_empregado T ON E.tipo_empregado = T.cod

SELECT * FROM dados_empr

INSERT INTO dados_empr
VALUES ('Ariel', 'financeiro', 'contador', 107.34);
 --b) Selecione a descrição dos departamentos que possuem algum empregado com salário > R$500.
SELECT descricao, salario FROM dados_empr
WHERE salario>500


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Cursores*/

/*Consulte todos os engenheiros com 2 ou mais projetos.

1. Crie um atributo “projetos” para armazenar os projetos (em
que o engenheiro participa) na tabela de empregados, que é
somente preenchido para os empregados de tipo
‘engenheiro’.*/

ALTER TABLE empregado ADD projetos varchar;
ALTER TABLE empregado DROP COLUMN projetos;
CREATE TABLE projetos(

    cod int,
    
);PRIMARY KEY(cod)

CREATE TABLE engenheiro_projetos(
    cod_eng int NOT NULL 
    cod_proj int NOT NULL 
    FOREIGN KEY (cod_eng) REFERENCES empregado(cpf)
    ON DELETE SET NULL
    FOREIGN KEY (cod_proj) REFERENCES projetos(cod)
    ON DELETE SET NULL
);



CREATE OR REPLACE FUNCTION CursorEng() RETURNS SETOF RECORD AS $$
DECLARE
	registro empregado%ROWTYPE;
    num_pg INTEGER;
    i INT DEFAULT 0;
	crs_1fn_engenheiro CURSOR FOR
		SELECT cpf
		FROM empregado E INNER JOIN tipo_empregado T ON E.tipo_empregado = T.cod
		WHERE T.descricao ILIKE 'engenheiro';
BEGIN
    OPEN crs_1fn_engenheiro;

    LOOP
        FETCH NEXT FROM crs_1fn_engenheiro INTO registro;
        EXIT WHEN NOT FOUND;
		
        IF (registro.projetos LIKE '%;%') THEN
            RETURN NEXT registro;
        END IF;

        i := i + 1;
    END LOOP;

    CLOSE crs_1fn_engenheiro;
    RETURN;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION CursorEng()

SELECT * FROM CursorEng() AS (cpf varchar, nome_empregado varchar, salario numeric, 
								 tipo_empregado integer, depto integer,cod integer, nome_depto varchar, 
								 projetos varchar);

UPDATE empregado SET projetos = '%;%' WHERE cpf LIKE '92345678919'
UPDATE empregado SET tipo_empregado = 1 WHERE cpf LIKE '92345678919'

SELECT * FROM empregado WHERE cpf LIKE '92345678919'

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Crie uma função showdb que lista
todos os bancos de dados no servidor (visualizar apenas o nome e o dono do BD).*/
CREATE OR REPLACE FUNCTION showdb() RETURNS setof RECORD AS $$
BEGIN 

	RETURN QUERY(

		SELECT datname, rolname
		FROM pg_database JOIN pg_roles ON pg_database.datdba = pg_roles.oid);
END;


$$LANGUAGE plpgsql;

DROP FUNCTION showdb()
SELECT * FROM showdb() as (datname name, rolname name)



 /* Crie uma função showtable que descreve uma tabela: mostra as informações sobre as colunas da tabela 
 passada como parâmetro (visualizar nome do campo, tipo de dado  e se tem restrição de not null ou não). 
 Obs.: O nome da tabela do resultado entregue deve começar com a terceira letra do seu primeiro nome! */

CREATE OR REPLACE FUNCTION showtable(tablename TEXT) 
RETURNS table(column_name TEXT, data_type TEXT, is_nullable TEXT) AS $$

BEGIN

  RETURN QUERY
    EXECUTE 'SELECT column_name::TEXT, data_type::TEXT, is_nullable::TEXT 
	FROM information_schema.columns WHERE table_name = $1'
    USING tablename;
END;

$$LANGUAGE plpgsql;


DROP FUNCTION showtable()
DROP FUNCTION IF EXISTS showtable(TEXT);
SELECT * FROM showtable('empregado')

--Funcionamento de EXPLAIN e EXPLAIN ANALYZE--
EXPLAIN SELECT * FROM showtable('empregado')

EXPLAIN ANALYZE SELECT * FROM showtable('empregado')
SELECT * FROM pg_statistic

/*Você só pode usar esta palavra-chave junto com ANALYZE, 
e mostra quantos blocos de 8kB cada etapa lê, escreve e suja. Você sempre quer isso.*/

EXPLAIN(ANALYZE, BUFFERS) SELECT * FROM showtable('empregado')

/*EXPLAIN fornecerá: o custo estimado, o número estimado de linhas e o tamanho estimado da linha de resultado médio. 
A unidade para o custo estimado da consulta é artificial (1 é o custo para ler uma página de 8kB durante uma varredura sequencial). 
Existem dois valores de custo: o custo inicial (custo para retornar a primeira linha) e o custo total (custo para retornar todas as linhas).*/


/*ANALYZE fornece um segundo parêntese com o tempo de execução real em milissegundos,
a contagem de linha real e uma contagem de loop que mostra com que frequência esse nó foi executado. 
Ele também mostra o número de linhas que os filtros removeram*/

EXPLAIN ANALYZE SELECT * FROM showtable('empregado')
EXPLAIN ANALYZE SELECT * FROM empregado


 /*Primeiro, você deve entender que um plano de execução do PostgreSQL é uma estrutura em árvore composta por vários nós . 
 O nó superior (o Aggregateacima) está no topo e os nós inferiores são recuados e começam com uma seta ( ->). 
 Nós com o mesmo recuo estão no mesmo nível (por exemplo, as duas relações combinadas com uma junção)*/



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 /*O custo estimado é calculado como (páginas de disco lidas * seq_page_cost ) + (linhas verificadas * cpu_tuple_cost ). 
 Por padrão, seq_page_costé 1,0 e cpu_tuple_costé 0,01, portanto, o custo estimado é (358 * 1,0) + (10000 * 0,01) = 458.*/


-- relpages número total de paginas de disco--
-- reltuplas número total de tuplas-- 
SELECT relpages, reltuples FROM pg_class WHERE relname = 'empregado'
--relpages = 16682
--reltuples = 2 * 10^6

CREATE OR REPLACE FUNCTION calcular_custo_estimado(nome  TEXT) RETURNS INTEGER AS $$
DECLARE         
    relpages INTEGER := (SELECT relpages FROM pg_class WHERE relname = nome);
    reltuples INTEGER := (SELECT reltuples FROM pg_class WHERE relname = nome);
	seq_page_cost FLOAT := current_setting('seq_page_cost')::FLOAT;
	cpu_tuple_cost FLOAT := current_setting('cpu_tuple_cost')::FLOAT;
BEGIN
    
    RETURN (relpages * seq_page_cost) + (reltuples * cpu_tuple_cost);

END;
$$LANGUAGE plpgsql;
DROP FUNCTION calcular_custo_estimado(TEXT)
SELECT * FROM calcular_custo_estimado('empregado')



/*O current_setting() aceita o nome de uma opção de configuração como parâmetro e retorna o valor atual dessa opção como uma string. 
É útil quando você precisa acessar dinamicamente os valores de configuração dentro de uma função ou consulta SQL.*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

EXPLAIN ANALYZE SELECT * FROM empregado WHERE depto = 10

/*EXPLAIN saída mostra a WHERE cláusula sendo aplicada como uma condição de “ filtro ” anexada ao nó do plano Seq Scan.
Isso significa que o nó do plano verifica a condição para cada linha que varre e gera apenas aquelas que passam na condição.
A estimativa de linhas de saída foi reduzida por causa da WHERE cláusula. No entanto, a varredura ainda terá que visitar todas as 10.000 linhas,
portanto, o custo não diminuiu; na verdade, 
aumentou um pouco (em 10000 * cpu_operator_cost , para ser exato) para refletir o tempo extra de CPU gasto na verificação da WHERE condição.*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE INDEX TABLE nome_empregado

EXPLAIN ANALYZE SELECT * FROM empregado WHERE depto = 10




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Para agilizar seu andamento, uma vez criados os índices, ao invés de remover (drop) /criar (create) de novo, use:

-- COMANDOS PARA HABILITAR/DESABILITAR INDICES

SET enable_indexscan to OFF;
SET enable_bitmapscan to OFF;

SET enable_indexscan to ON;
SET enable_bitmapscan to ON;
*/

/*
1- Se ainda não restaurou o BD de empresa, faça isso agora! 

*Importação simples via linha de comando

-u postgres psql -d <banco_de_destino> -f <arquivo_de_origem>

Resposta: feito durante o questionario de "resivão e aquecimento SQL"
*/

--2- Faça uma consulta que selecione os dados dos empregados de nome "Mary".
SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary'

--2.1 Anote o tempo de processamento.

/* a busca foi concluida em 0.791 segundos.*/

--2.2 Escreva quantas tuplas recuperou.

-- 3539 tuplas

--2.3 Aplique a instrução EXPLAIN (ou melhor EXPLAIN ANALYZE) 
--para observar o plano de execução da consulta. Insira o plano da consulta na resposta.

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary'

--2.4 Quantas tuplas varreu? Anote.

--9.871 tuplas percorridas e 665488 tuplas removidas pelo filtro 

/*3- Faça uma consulta que selecione os dados dos empregados de nome "Mary" OU
dos empregados do departamento 10 (use operador lógico OR). Anote a instrução SQL.*/

SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' OR depto = 10

--3.1 Anote o tempo de processamento.
--0.705 segundos 

/*3.2 Aplique a instrução EXPLAIN (ou melhor EXPLAIN ANALYZE) 
para observar o plano de execução da consulta.  Insira o plano da consulta na resposta.*/

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' OR depto = 10

/*3.3 Faça um UNION das condições e repita o processo de observação em 3.1 e 3.2. 
Explique comparando os planos das consultas qual das duas consultas você escolheria 
(baseado no plano de execução com índices criados)? Mostre os planos de consulta usados na explicação.*/

SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' UNION 
SELECT * FROM empregado
WHERE depto = 10

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' UNION 
SELECT * FROM empregado
WHERE depto = 10

/*RESPOSTA: O plano de consulta com o operador logico “OR” é mais eficiente em relação ao operador 
“UNION”, com o tempo de execução de 0.705 segundos contra o de 0.953 segundos. 
Além disso, o filtro aplicado na consulta “OR” removeu 635976 tuplas com a aplicação simultânea dos 
dois filtros, enquanto a do UNION removeu 665488 tuplas pela aplicação de um filtro “nome = “mary” 
e 1911336 tuplas pela aplicação do filtro depto = 10.

Assim, é Observável que a consulta “OR” é mais eficiente uma vez que aplica os filtros de forma simultâneo,
enquanto a consulta UNION trabalha com os filtros de forma independentes,
o que pode causar redundância em relação as tuplas varridas que serão removidas.*/

/*4- Crie um índice sobre o nome de empregado. Escreva a instrução SQL.
Observe e anote o tempo de criação do índice! */

CREATE INDEX nome_empregrado_idx ON empregado USING Btree (nome_empregado)
--3 segundos e 562 mili segundos para se criar os índices	

--4.1 Qual o método de indexação (ED) que você usou?

--O método adotado foi a utilização da estrutura de dados “B-tree”.


/*5- Repita 2 e 3. Comente sobre as diferenças dos planos de consulta, se houver.*/

CREATE INDEX mary_empregado_idx ON empregado USING Hash (nome_empregado)

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary'

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' OR depto = 10

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' UNION 
SELECT * FROM empregado
WHERE depto = 10


--6- Repita a consulta do item 3 agora usando AND (ao invés de OR). Escreva a instrução SQL. 

SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' AND depto = 10

--6.1 O plano de execução usou o índice? Insira o plano da consulta na resposta.

-- O plano não usou o índice.

SET enable_indexscan to ON;
SET enable_bitmapscan to ON;
EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' AND depto = 10

SELECT *
FROM pg_indexes
WHERE tablename LIKE 'mary_empregado_idx'

/* 6.2 A varredura da segunda condição aconteceu encima do arquivo de dados ou do índice? Explique.

Resposta: Pelo plano de execução fornecido, a varredura ocorreu encima do arquivo de dados,
uma vez que o plano de execução não possui nenhum indicativo que alguns índice foi usado na busca.*/

/*7- Consulte todos os empregados cujo nome começa com a letra M. Anote a instrução SQL.*/

SELECT * FROM empregado
WHERE nome_empregado ILIKE 'M%'

/*7.1- Observe e insira o plano de execução e explique se o plano usou o índice. */
EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'M%'

/*8- Consulte todos os empregados que tem "an" como substring do nome. Anote a instrução SQL.*/

SELECT * FROM empregado
WHERE nome_empregado ILIKE '%an%'

--8.1- Observe e insira o plano de execução e explique se o plano de execução usou o índice. Por quê?

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado LIKE '%an%'

--8.2- Repita a consulta com o operador ILIKE. Anote a instrução SQL. O que observou?
EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE '%an%'

/*9- Acrescente uma ordenação pelo nome do empregado às consultas dos itens 7 e 8. 
Anote a instrução SQL. */

SELECT * FROM empregado
WHERE nome_empregado ILIKE 'M%'
ORDER BY nome_empregado

SELECT * FROM empregado
WHERE nome_empregado LIKE '%an%'
ORDER BY nome_empregado

--9.1- O que acontece no plano de execução. Por quê? Mostre os planos.

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'M%'
ORDER BY nome_empregado

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE '%an%'
ORDER BY nome_empregado

/*10- Crie um índice composto BTree para os campos nome_empregado e depto (nessa ordem). 
Escreva a instrução SQL.*/

CREATE INDEX empregado_depto_idx ON empregado USING Btree (nome_empregado, depto)

--11- Execute as consultas nos itens 6 e 7.
SELECT * FROM empregado
WHERE nome_empregado ILIKE 'M%'

SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' AND depto = 10

--11.1- Qual índice foi utilizado no plano de execução?
EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'M%'

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' AND depto = 10

/*11.3- Substitua o AND da condição pelo OR. O que acontece? Por quê?
(considere na resposta os dois índices: o simples e o composto). 
Mostre o plano da consulta.*/

EXPLAIN ANALYZE SELECT * FROM empregado
WHERE nome_empregado ILIKE 'Mary' OR depto = 10

/*12- Execute a consulta que retorna os nomes dos empregados do departamento de contabilidade
(use a condição de junção na cláusula WHERE). Escreva a instrução SQL.*/

SELECT nome_empregado FROM empregado E INNER JOIN departamento D ON E.depto = D.cod
WHERE nome_depto LIKE 'contabilidade'

/*12.1- Você consegue melhorar o desempenho da consulta? 
Tente criar um índice no atributo depto (campo da junção) da tabela de empregados. 
Explique mostrando os planos de consulta.*/]

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado E INNER JOIN departamento D ON E.depto = D.cod
WHERE nome_depto LIKE 'contabilidade'

CREATE INDEX depto_idx ON empregado USING hash (depto)

/*13- Refaça a consulta do item 12 usando o operador de conjuntos IN. Escreva a instrução SQL. */
SELECT nome_empregado FROM empregado 
WHERE depto IN (SELECT cod FROM departamento 
			   WHERE nome_depto ILIKE 'contabilidade')
			   
/*13.1- Compare os planos de execução das duas consultas. Mostre os planos*/
EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado 
WHERE depto IN (SELECT cod FROM departamento 
			   WHERE nome_depto ILIKE 'contabilidade')
			   
/*13.2- Refaça a consulta usando o operador = (ao invés do IN). 
Escreva a instrução SQL. Mostre os planos. Compare de novo. Anote o tempo de execução.*/

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado 
WHERE depto = (SELECT cod FROM departamento 
			   WHERE nome_depto ILIKE 'contabilidade')
			   
/*14- Existe algum outro recurso que você possa estar utilizando para melhorar 
ainda mais o tempo de execução das consultas dos itens 12 e 13? Qual? Teste! Fez diferença?
Por quê? Mostre o plano da consulta!  */

CREATE MATERIALIZED VIEW depto_conatabilidade AS
SELECT nome_empregado, cod FROM Empregado E INNER JOIN departamento D ON E.depto = D.cod 
WHERE nome_depto ILIKE 'contabilidade'

DROP MATERIALIZED VIEW depto_conatabilidade
EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM depto_conatabilidade 


EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado 
WHERE depto IN (SELECT cod FROM departamento 
			   WHERE nome_depto ILIKE 'contabilidade')
			   
EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado 
WHERE depto IN (SELECT cod FROM departamento 
			   WHERE nome_depto LIKE 'contabilidade')
			   

/*15- Refaça a consulta do item 12 usando a cláusula inner join no FROM. 
Alguma diferença no plano da consulta? Mostre a instrução SQL e o plano. */

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado E INNER JOIN departamento D ON E.depto = D.cod
WHERE nome_depto LIKE 'contabilidade'

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado 
WHERE depto IN (SELECT cod FROM departamento 
			   WHERE nome_depto LIKE 'contabilidade')
			   
/*15.1- Inclua a condição "departamento de contabilidade" no FROM. 
Alguma diferença? Mostre a instrução SQL e o plano. */

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado E INNER JOIN departamento D 
ON E.depto = D.cod AND D.nome_depto LIKE 'contabilidade'
WHERE nome_depto LIKE 'contabilidade'

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado FROM empregado E INNER JOIN departamento D 
ON  D.nome_depto LIKE 'contabilidade' AND E.depto = D.cod
WHERE nome_depto LIKE 'contabilidade'

/*16- Acrescente mais uma condição à consulta do item 12:
E tipo de empregado é contador. Mostre a instrução SQL e o plano.*/

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado,tipo_empregado, depto FROM empregado E INNER JOIN departamento D
ON  D.nome_depto LIKE 'contabilidade' AND
tipo_empregado IN (SELECT cod FROM tipo_empregado WHERE descricao = 'contador')
AND E.depto = D.cod
WHERE nome_depto LIKE 'contabilidade' AND tipo_empregado <> 10


--17- Consulte os empregados com salário maior que 1000 reais. Mostre a instrução SQL. 

SELECT * FROM empregado
WHERE salario > 1000

/*17.2- Melhora se criarmos um índice  sobre o campo salario? 
Observe o tempo de criação do índice. O plano de consulta contém o índice criado?
Por quê? Mostre o plano.*/

CREATE INDEX salario_UP1000_idx ON empregado (salario) WHERE salario > 1000
DROP INDEX salario_UP1000_idx

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM empregado
WHERE salario > 1000

/*17.4- Faça agora a consulta para salários menores que 1000 reais. 
O plano de consulta contém o índice criado? Por quê? Mostre a instrução SQL e o plano. */
EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM empregado
WHERE salario < 1000

/*17.5- Avalie se a mesma explicação se aplica para as consultas:
recupere os dados de empregados dos departamentos 10 ao 20. E do 10 ao 30? 
Mostre as instruções SQL e os planos.*/

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM empregado
WHERE depto BETWEEN  10 AND 20

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM empregado
WHERE depto BETWEEN  10 AND 30

/*18- Procure o mínimo e máximo salário dos empregados da empresa. 
Mostre a instrução SQL. (podem ser duas consultas separadas ou apenas uma consulta!)
*/

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT MIN(salario), MAX(salario)
FROM empregado

/*19- Construa outras consultas que usem as cláusulas de ORDER BY, GROUP BY ou DISTINCT.
Procure explicações relacionadas aos algoritmos e recursos utilizados nos planos de consulta. 
Em todos os casos, mostre a instrução SQL e o plano. */

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT nome_empregado, salario
FROM empregado
ORDER BY salario

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT salario,COUNT(nome_empregado)
FROM empregado
GROUP BY salario
HAVING salario > 1000

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT DISTINCT depto
FROM empregado

/*20- Crie consulta com duas soluções SQL equivalentes 
(por exemplo: usando junção, usando aninhamento de consultas).
Qual das duas consultas SQL você escolheria para implementação 
(baseado no plano de execução com índices)? Em todos os casos, mostre a instrução SQL e o plano. */

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM empregado E INNER JOIN tipo_empregado T ON E.tipo_empregado = T.cod
WHERE descricao LIKE 'contador' AND salario > 1000

EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM empregado E,
(SELECT * FROM tipo_empregado T WHERE descricao LIKE 'contador') AS C
WHERE salario > 1000;

