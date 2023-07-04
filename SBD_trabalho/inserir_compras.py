import random
from datetime import datetime, timedelta
import psycopg2
import numpy as np

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

# Gerar o comentário com base na avaliação
def gerar_comentario(avaliacao):
    if avaliacao >= 80:
        return "Excelente"
    elif avaliacao >= 70:
        return "Ótimo"
    elif avaliacao >= 55:
        return "Bom"
    elif avaliacao >= 40:
        return "Regular"
    elif avaliacao >= 30:
        return "Ruim"
    else:
        return "Péssimo"

# Gerar as compras para cada usuário na sequência
def gerar_compras(conn, usuarios, jogos, num_compras, media_compras, desvio_padrao_compras):
    cur = conn.cursor()
    num_usuarios = len(usuarios)
    num_jogos = len(jogos)
    id_compra_base = 1010100501
    compras_feitas = 0

    while compras_feitas < num_compras:

        # Escolher o próximo usuário na sequência
        idx_usuario = compras_feitas % num_usuarios
        ID_usuario = usuarios[idx_usuario]

        # Gerar o número de compras para o usuário seguindo uma distribuição normal
        num_compras_usuario = int(round(random.gauss(media_compras,dp_compras)))

        # Limitar o número de compras para não ser negativo
        num_compras_usuario = max(num_compras_usuario, 0)

        # Gerar as compras para o usuário
        for _ in range(num_compras_usuario):

            ID_compra = id_compra_base
            # Escolher um jogo aleatório
            idx_jogo = random.randint(0, num_jogos - 1)
            ID_jogo = jogos[idx_jogo]

            # Gerar a data da compra aleatoriamente (nos últimos 4 anos)
            data_compra = datetime.now() - timedelta(days=random.randint(0, 1460))

            # Buscar o valor médio do jogo com base no ID_jogo
            cur.execute("SELECT preco FROM jogos WHERE ID_jogo = %s", (ID_jogo,))
            preco = cur.fetchone()[0]

            avaliacao = round(random.gauss(50, 7), 2) #media = 50, dp = 7
            comentario = gerar_comentario(avaliacao)

            # Inserir a compra na tabela "compras"
            cur.execute(
                "INSERT INTO compras (ID_compra, ID_usuario, ID_jogo, data_compra, valor, avaliacao, comentario) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (ID_compra, ID_usuario, ID_jogo, data_compra, preco, avaliacao, comentario)
            )

            id_compra_base += 1
            compras_feitas += 1
            if compras_feitas >= num_compras:
                break

    cur.close()
    conn.commit()

# Função principal para gerar as compras
def gerar_compras_sequenciais(num_compras, media_compras, dp_compras):
    conn = conectar_banco_dados()
    usuarios = buscar_usuarios(conn)
    jogos = buscar_jogos(conn)
    gerar_compras(conn, usuarios, jogos, num_compras, media_compras, dp_compras)
    conn.close()

# Executar a função principal para gerar as compras

media_compras = 7
dp_compras = 3
num_compras = 1000000
gerar_compras_sequenciais(num_compras, media_compras, dp_compras)
