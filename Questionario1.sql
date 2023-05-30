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
        
        INSERT INTO empregado (cpf, nome_empregado, salario, tipo_empregado, depto, supervisor)
        VALUES (cpf, nome_empregado, salario, tipo_empregado, depto, supervisor);
        
        RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.cpf = NEW.supervisor) THEN
            RAISE EXCEPTION 'Um supervisor não pode supervisionar a si mesmo';
            RETURN NULL;
        END IF;
        
        UPDATE empregado SET supervisor = NEW.supervisor WHERE cpf = NEW.cpf;
        
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