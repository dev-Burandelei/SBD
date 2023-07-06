import random
import psycopg2
import csv
from faker import Faker

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

# Ler CPFs do arquivo CSV
def ler_cpfs_arquivo():
    cpfs = []
    with open('cpf.csv', 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            cpfs.append(row[0])
    return cpfs

# Atualizar função gerar_dados_usuarios para receber a lista de CPFs
def gerar_dados_usuarios(num_users, cpfs):
    fake = Faker()
    data = []
    for i in range(num_users):
        cpf = cpfs[i]
        nome = fake.first_name()
        sobrenome = fake.last_name()
        status = random.choice(['online', 'offline', 'ocupado', 'ausente'])
        data_nascimento = fake.date_of_birth(minimum_age=18, maximum_age=90).strftime('%Y-%m-%d')
        email = f"{nome.lower()}.{sobrenome.lower()}@email.com"
        saldo = round(random.gauss(1000, 170), 2)
        endereco = fake.address().replace('\n', ', ')
        data.append((cpf, nome, sobrenome, status, data_nascimento, email, saldo, endereco))
    return data

def inserir_dados(conn, dados):
    cur = conn.cursor()

    for dado in dados:
        cpf, nome, sobrenome, status, data_nascimento, email, saldo, endereco = dado

        # Inserir os dados na tabela "usuarios"
        cur.execute(
            "INSERT INTO usuarios (cpf, nome, sobrenome, status, data_nascimento, email, saldo, endereco) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (cpf, nome, sobrenome, status, data_nascimento, email, saldo, endereco)
        )

    cur.close()
    conn.commit()

# Atualizar função principal para incluir leitura dos CPFs e passar como parâmetro
def inserir_dados_sql():
    conn = conectar_banco_dados()
    num_users = 500000
    cpfs = ler_cpfs_arquivo()  # Ler CPFs do arquivo CSV
    dados = gerar_dados_usuarios(num_users, cpfs)  # Passar lista de CPFs para gerar dados
    inserir_dados(conn, dados)
    conn.close()

inserir_dados_sql()
