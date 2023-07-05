# Gerar dados aleatórios para usuários
def gerar_dados_usuarios(num_users):
    fake = Faker()
    data = []
    for i in range(num_users):
        cpf = str(12347229939 + i)
        nome = fake.first_name()
        sobrenome = fake.last_name()
        status = random.choice(['online', 'offline', 'ocupado', 'ausente'])  # Seleciona aleatoriamente entre "online" e "offline"
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
