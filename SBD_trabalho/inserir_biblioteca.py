import random
import psycopg2

# Conexão com o banco de dados PostgreSQL
# Substitua as informações de conexão com o seu banco de dados específico
def conectar_banco_dados():
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="projeto_sbd",
            user="andre_portella",
            password="728099"
        )
        return conn
    except psycopg2.Error as e:
        print("Erro ao conectar ao PostgreSQL:", e)
        exit(1)

# Buscar todos os usuários disponíveis
def buscar_usuarios(conn):
    cur = conn.cursor()
    cur.execute("SELECT cpf FROM usuarios")
    usuarios = cur.fetchall()
    cur.close()
    return usuarios

# Buscar todos os jogos disponíveis
def buscar_jogos(conn):
    cur = conn.cursor()
    cur.execute("SELECT ID_jogo FROM jogos")
    jogos = cur.fetchall()
    cur.close()
    return jogos

# Gerar dados aleatórios para a tabela biblioteca
def gerar_dados_biblioteca(conn, usuarios, jogos, media_jogos, dp_jogos):
    cur = conn.cursor()
    ID_biblioteca = 5599443311
    num_jogos = len(jogos)

    for usuario in usuarios:
        num_jogos_biblioteca = int(random.gauss(media_jogos, dp_jogos))  # Número de jogos na biblioteca do usuário
        num_jogos_biblioteca = max(0, min(num_jogos_biblioteca, num_jogos-1))
        lista_jogos = [jogo[0] for jogo in jogos]
        jogos_biblioteca = random.sample(lista_jogos, num_jogos_biblioteca)

        for jogo in jogos_biblioteca:
            ID_usuario = usuario[0]
            ID_jogo = jogo
            tempo_jogo = random.gauss(700, 90) #media = 700, dp = 90
            completado = random.choice([True, False]) 
            reembolsavel = random.choice([True, False])  
            instalado = random.choice([True, False])  

            # Inserir os dados na tabela "biblioteca"
            cur.execute(
                "INSERT INTO biblioteca (ID_biblioteca, ID_usuario, ID_jogo, tempo_jogo, completado, reembolsavel, instalado) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (ID_biblioteca, ID_usuario, ID_jogo, tempo_jogo, completado, reembolsavel, instalado)
            )
            ID_biblioteca += 1

    cur.close()
    conn.commit()

# Função principal para popular a tabela biblioteca
def popular_biblioteca():
    conn = conectar_banco_dados()
    usuarios = buscar_usuarios(conn)
    jogos = buscar_jogos(conn)
    media_jogos = 5
    dp_jogos = 3
    gerar_dados_biblioteca(conn, usuarios, jogos, media_jogos, dp_jogos)
    conn.close()

# Executar a função principal para popular a tabela biblioteca
popular_biblioteca()
