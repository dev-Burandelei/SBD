import random
import psycopg2
from faker import Faker

# Conexão com o banco de dados PostgreSQL
# Substitua as informações de conexão com o seu banco de dados específico
def conectar_banco_dados():
    try:
        conn = psycopg2.connect(
            host="",
            database="",
            user="",
            password=""
        )
        return conn
    except psycopg2.Error as e:
        print("Erro ao conectar ao PostgreSQL:", e)
        exit(1)

# Gerar dados aleatórios para usuários
def gerar_dados_usuarios(num_users):
    fake = Faker()
    data = []
    for i in range(num_users):
        cpf = str(12347229939 + i)
        nome = fake.first_name()
        sobrenome = fake.last_name()
        status = random.choice(['online', 'offline'])  # Seleciona aleatoriamente entre "online" e "offline"
        data_nascimento = fake.date_of_birth(minimum_age=18, maximum_age=90).strftime('%Y-%m-%d')
        email = f"{nome.lower()}.{sobrenome.lower()}@email.com"
        saldo = round(random.gauss(1000, 170), 2)
        endereco = fake.address().replace('\n', ', ')
        data.append((cpf, nome, sobrenome, status, data_nascimento, email, saldo, endereco))
    return data

# Inserir os dados no banco de dados
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

# Função principal para inserir os dados no banco de dados
def inserir_dados_sql():
    conn = conectar_banco_dados()
    num_users = 500000  # Número de usuários a serem gerados
    dados = gerar_dados_usuarios(num_users)
    inserir_dados(conn, dados)
    conn.close()

# Executar a função principal para inserir os dados no banco de dados
inserir_dados_sql()
