import random
import psycopg2

# Conexão com o banco de dados PostgreSQL
# Substitua as informações de conexão com o seu banco de dados específico
def conectar_banco_dados():
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="projetoSBD_marketplace_jogos",
            user="user",
            password="password"
        )
        return conn
    except psycopg2.Error as e:
        print("Erro ao conectar ao PostgreSQL:", e)
        exit(1)

# Buscar usuários e jogos da tabela "compras"
def buscar_usuarios_jogos(conn):
    cur = conn.cursor()
    cur.execute("SELECT ID_usuario, ID_jogo FROM compras")
    dados_compras = cur.fetchall()
    cur.close()
    return dados_compras

# Gerar dados aleatórios para a tabela "biblioteca"
def gerar_dados_biblioteca(conn, dados_compras, media_jogos, dp_jogos):
    cur = conn.cursor()
    ID_biblioteca = 5599443311
    num_jogos = len(dados_compras)

    for dados in dados_compras:
        ID_usuario = dados[0]
        ID_jogo = dados[1]
        tempo_jogo = random.gauss(25, 3)  # media = 25, dp = 3
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

# Função principal para popular a tabela "biblioteca"
def popular_biblioteca():
    conn = conectar_banco_dados()
    dados_compras = buscar_usuarios_jogos(conn)
    media_jogos = 3
    dp_jogos = 1
    gerar_dados_biblioteca(conn, dados_compras, media_jogos, dp_jogos)
    conn.close()

# Executar a função principal para popular a tabela "biblioteca"
popular_biblioteca()
