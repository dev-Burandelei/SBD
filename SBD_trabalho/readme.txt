Utilizamos scripts para popular as tabelas "usuario", "compras" e "biblioteca". 
Os dados da tabela "jogos" foram inventados pelo grupo.

Ordem para popular o banco de dados (BD): usuarios, jogos, compras, biblioteca

1)
Baixar o backup do banco de dados (BD) e restaurar no PgAdmin4.

2)
Abrir o script "inserir_usuarios.py", inserir as informações para conexão com o BD. Depois, executar o script pelo comando "python inserir_usarios.py". Esse script utiliza o arquivo "cpf.csv" para obter os CPFs dos usuários.

3)
Popular a tabela jogos através do arquivo jogos.csv. Indicamos o seguinte comando, a ser executado no PgAdmin4: 
COPY jogos(ID_jogo, titulo, desenvolvedora, publicadora, genero, classificacao_indicativa, nota, preco, ano_lancamento, dlc) FROM '/caminho/do/arquivo' DELIMITER ',' CSV HEADER;

4)
Para a inserção de compras, inserir as informações de conexão no script "inserir_compras.py" e, na sequência, executar "python inserir_compras.py" 

5)
Por fim, inserir as informações de conexão no script "inserir_biblioteca.py" e, na sequência, executar "python inserir_biblioteca.py" 


Informações sobre as tabelas:

Tabela: usuario
Num registros: 500 mil
Tamanho: 86MB

Tabela: jogos
Num registros: 120
Tamanho: 56KB

Tabela: compras
Num registros: 1 milhão
Tamanho: 119MB

Tabela: biblioteca
Num registros: 1 milhão
Tamanho: 112MB




