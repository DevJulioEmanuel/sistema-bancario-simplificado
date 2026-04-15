# 🏦 Sistema Bancário Distribuído — Comunicação entre Processos

> Trabalho 1 — Sockets, Streams, Serialização e Representação Externa de Dados  
> Disciplina: Sistemas Distribuídos

> Integrantes: Arthur Lelis, Julio Emanuel

> Link do vídeo: https://www.youtube.com/watch?v=s6Vr0I9ImBg 


## 🌐 Visão Geral

Sistema bancário distribuído com comunicação cliente-servidor via sockets TCP. O servidor é desenvolvido em **Java** e o cliente em **Ruby**, demonstrando interoperabilidade entre linguagens via protocolo binário customizado.

O servidor persiste os dados em arquivo binário (`contas.bin`) usando streams customizados, atende múltiplos clientes simultaneamente com threads e transmite notificações em tempo real via **UDP Multicast**. O cliente Ruby oferece uma interface de terminal interativa e visualmente estilizada.

---

## ▶️ Como Executar

### Servidor (Java)

```bash
# Compilar (a partir da pasta server/)
javac -cp . interfaces/*.java models/*.java service/*.java stream/*.java notificacao/*.java sockets/*.java

# Executar
java sockets.ServidorTCP
```

O servidor inicia na porta **7897**, carrega o `contas.bin` se existir, e já sobe a thread de multicast automaticamente.

### Cliente (Ruby)

```bash
# Instalar dependências
gem install tty-prompt pastel

# Executar (a partir da pasta client/)
ruby client.rb
```

O cliente conecta ao servidor em `10.10.255.63:7897` e já inicia a escuta multicast em `239.0.0.1:12347` em background.

---

## 🧱 Modelagem do Sistema

### Hierarquia de Classes

```
Conta (abstrata)
├── ContaCorrente   implements Tributável   → numeração a partir de 1000
└── ContaPoupanca                           → numeração a partir de 5000
```

### 📦 Classes POJO

#### `Cliente`
| Atributo | Tipo     | Detalhe |
|----------|----------|---------|
| id       | `int`    | Auto-incremento a partir de 1000 |
| nome     | `String` | Nome completo |
| cpf      | `String` | CPF do titular |

#### `Conta` (abstrata)
| Atributo | Tipo      | Detalhe |
|----------|-----------|---------|
| numero   | `int`     | Gerado automaticamente por subtipo |
| saldo    | `double`  | Saldo atual |
| titular  | `Cliente` | Referência ao cliente |
| senha    | `String`  | Senha de acesso à conta |

#### `ContaCorrente` extends `Conta` implements `Tributável`
| Atributo | Tipo     | Detalhe |
|----------|----------|---------|
| limite   | `double` | Padrão R$ 1.200,00 |

#### `ContaPoupanca` extends `Conta`
| Atributo   | Tipo     | Detalhe |
|------------|----------|---------|
| rendimento | `double` | Padrão 0,5% ao mês (0.005) |

#### `Banco`
| Atributo | Tipo            |
|----------|-----------------|
| clientes | `List<Cliente>` |
| contas   | `List<Conta>`   |

---

## 💰 Interface Tributável

Implementada por `ContaCorrente`. O imposto (10%) é aplicado sobre transferências enviadas por conta corrente, debitado junto ao valor transferido.

| Método | Retorno |
|--------|---------|
| `calcularImposto()` | `0.10` (10%) |

---

## ⚙️ Classes de Serviço

### `ContaService`

| Método | Descrição |
|--------|-----------|
| `abrirConta(Cliente, String senha, int tipo)` | Cria ContaCorrente (tipo 1) ou ContaPoupanca (tipo 2) |
| `sacar(Conta, double)` | Remove saldo se houver cobertura |
| `depositar(Conta, double)` | Adiciona saldo |
| `transferir(Conta origem, Conta destino, double)` | Transfere com imposto de 10% para ContaCorrente |
| `pagar(Conta, double, String descricao)` | Pagamento exclusivo para ContaCorrente |
| `projetarRendimento(Conta, int meses)` | Projeção de saldo futuro para ContaPoupanca |
| `buscarConta(int numero)` | Localiza conta pelo número |
| `consultarExtrato(int numero)` | Retorna histórico de movimentações |

### `ClienteService`

| Método | Descrição |
|--------|-----------|
| `salvarOuObter(String nome, String cpf)` | Cadastra ou retorna cliente existente |
| `buscarPorCpf(String cpf)` | Localiza cliente pelo CPF |
| `listarContas(String cpf)` | Lista todas as contas de um cliente |

---

## 📌 Exercício 1 — POJOs e Serviços

**Requisito:** Classes POJO representando o domínio e 2 classes que implementam serviços.

**Entregues:**
- POJOs: `Cliente`, `Conta`, `ContaCorrente`, `ContaPoupanca`, `Banco`
- Interface: `Tributavel`
- Serviços: `ContaService`, `ClienteService`

---

## 📤 Exercício 2 — ContaOutputStream

**Requisito:** Subclasse de `OutputStream` que serializa um array de `Conta` como bytes.

O `ContaOutputStream` encapsula um `DataOutputStream` internamente e serializa cada conta seguindo o protocolo binário definido na seção [Protocolo Binário](#-protocolo-binário). Além do método `write(Banco)`, expõe `writeInt`, `writeDouble` e `writeUTF` para uso pelo `ManipuladorCliente` nas respostas TCP.

**Destinos utilizados no projeto:**

| Destino | Onde é usado |
|---------|-------------|
| `FileOutputStream` | Persistência em `contas.bin` após cada operação |
| Socket TCP (`OutputStream`) | Resposta ao cliente Ruby no login |
| `System.out` | Testes manuais |

---

## 📥 Exercício 3 — ContaInputStream

**Requisito:** Subclasse de `InputStream` que reconstrói objetos a partir dos bytes gerados pelo `ContaOutputStream`.

O `ContaInputStream` encapsula um `DataInputStream` internamente. O método `read(Banco)` lê o arquivo `contas.bin` e reconstrói os objetos `ContaCorrente` e `ContaPoupanca` com seus respectivos titulares. Além disso, expõe `readInt`, `readDouble` e `readUTF` para que o `ManipuladorCliente` leia as requisições TCP.

**Origens utilizadas no projeto:**

| Origem | Onde é usado |
|--------|-------------|
| `FileInputStream` | Carga inicial do `contas.bin` na inicialização do servidor |
| Socket TCP (`InputStream`) | Leitura das requisições do cliente Ruby |

---

## 🔄 Exercício 4 — Comunicação Cliente-Servidor

**Requisito:** Serviço remoto via TCP com empacotamento e desempacotamento de mensagens.

### Servidor Java

O servidor escuta na porta **7897**. Para cada conexão aceita, cria uma nova `Thread` (classe `Connection`). Dentro da thread, um loop contínuo aguarda operações do cliente via `ManipuladorCliente`, executa a regra de negócio e persiste os dados em `contas.bin` após cada operação.

```
ServidorTCP (porta 7897)
└── aceita conexão → new Connection(thread)
    └── loop:
        ├── ManipuladorCliente.processar()
        │   ├── lê operação (int)
        │   ├── executa ContaService / ClienteService
        │   └── envia resposta
        └── persiste contas.bin
```

### Operações disponíveis (protocolo de operações)

| Código | Operação | Enviado pelo cliente | Resposta do servidor |
|--------|----------|----------------------|----------------------|
| `1` | Cadastro | nome, cpf, senha, tipo | `0` = ok, `-1` = CPF já existe |
| `2` | Login | cpf, senha, tipo | `0` + dados da conta, ou `-1` |
| `3` | Saque | numero\_conta, valor | `0` = ok, `-2` = saldo insuficiente |
| `4` | Depósito | numero\_conta, valor | `0` = ok, `-2` = erro |
| `5` | Transferência | num\_origem, num\_destino, valor | `0` + nome\_destino, ou código de erro |
| `6` | Pagamento | numero\_conta, valor, descricao | `0` = ok, `-2` = saldo insuficiente |
| `7` | Projetar rendimento | numero\_conta, meses | `0` + valor projetado |
| `8` | Extrato | numero\_conta | `0` + quantidade + linhas do histórico |

### Cliente Ruby

O cliente conecta via `TCPSocket` na mesma porta. A classe `Connection` encapsula todos os métodos de comunicação, usando `write_int`, `write_double`, `write_utf` para envio e `read_int`, `read_double`, `read_utf` para leitura — todos respeitando big-endian, compatível com o `DataOutputStream` do Java.

A deserialização das contas recebidas no login é feita pelo módulo `Protocol`, que lê os bytes na mesma ordem que o `ContaOutputStream` Java escreve.

### Heterogeneidade entre Java e Ruby

Como Java e Ruby são linguagens diferentes, a comunicação binária exige que ambos os lados usem a mesma convenção de bytes. O Java escreve em **big-endian** por padrão (`DataOutputStream`). O Ruby usa os seguintes format directives no `unpack` para garantir compatibilidade:

| Tipo Java | Format Ruby | Bytes |
|-----------|-------------|-------|
| `int` | `N` | 4 |
| `double` | `G` | 8 |
| `String` (UTF, 2 bytes tamanho) | `n` + leitura manual | variável |

---

## 📣 Exercício 5 — Notificações via UDP Multicast

**Requisito:** Comunicação multicast UDP adaptada ao contexto bancário.

### Como funciona

O servidor roda uma thread dedicada (`ServidorMulticast`) que envia mensagens informativas e avisos bancários a cada **15 segundos** para o grupo multicast `239.0.0.1` na porta **12347**.

O cliente Ruby, ao iniciar, cria uma thread (`NotificacaoListener`) que se inscreve nesse grupo multicast e fica escutando indefinidamente. Quando uma mensagem chega e o usuário está logado (`Session.logado?`), a notificação é exibida no terminal em tempo real sem interromper a navegação nas telas.

### Por que é multicast de verdade

Todos os clientes conectados se inscrevem no mesmo grupo multicast no momento em que iniciam. O servidor envia **uma única vez** para o endereço do grupo — não para cada cliente individualmente. Quem está inscrito recebe; quem não está, não recebe nada. Não há lista de destinatários, não há broadcast para toda a rede.

### Exemplos de mensagens enviadas

- `"SEGURANÇA: O banco nunca solicita tokens ou senhas por telefone."`
- `"OFERTA: Antecipe seu 13º salário com as menores taxas do mercado."`
- `"ALERTA: Identificou uma movimentação estranha? Bloqueie sua conta imediatamente."`
- `"DICA FINANCEIRA: Gastar menos do que ganha é o primeiro passo para o sucesso."`

---

## 📁 Organização do Projeto

```
sistema-bancario-simplificado/
│
├── server/                          # Java
│   ├── interfaces/
│   │   └── Tributavel.java
│   │
│   ├── models/
│   │   ├── Banco.java
│   │   ├── Cliente.java
│   │   ├── Conta.java
│   │   ├── ContaCorrente.java
│   │   └── ContaPoupanca.java
│   │
│   ├── service/
│   │   ├── ClienteService.java
│   │   └── ContaService.java
│   │
│   ├── stream/                      # Exercícios 2 e 3
│   │   ├── ContaOutputStream.java
│   │   └── ContaInputStream.java
│   │
│   ├── sockets/                     # Exercício 4
│   │   ├── ServidorTCP.java
│   │   └── ManipuladorCliente.java
│   │
│   └── notificacao/                 # Exercício 5
│       └── ServidorMulticast.java
│
├── client/                          # Ruby
│   ├── client.rb                    # Ponto de entrada
│   ├── connection.rb                # Comunicação TCP com o servidor
│   ├── protocol.rb                  # Deserialização das contas (unpack)
│   ├── models.rb                    # Structs Cliente e Conta
│   ├── session.rb                   # Controle de sessão do usuário
│   ├── notificacao_listener.rb      # Exercício 5 — escuta multicast UDP
│   └── ui/
│       ├── banner.rb                # Utilitários visuais do terminal
│       ├── tela_login.rb            # Tela de login
│       ├── tela_cadastro.rb         # Tela de abertura de conta
│       └── tela_conta.rb            # Dashboard da conta logada
│
└── README.md
```

---

## 📡 Protocolo Binário

Formato usado pelo `ContaOutputStream` para serializar cada conta. O `ContaInputStream` lê na mesma ordem. O cliente Ruby replica essa leitura via `unpack`.

```
[4 bytes - int]     quantidade de contas
para cada conta:
  [4 bytes - int]   tipo (1 = ContaCorrente, 2 = ContaPoupanca)
  [4 bytes - int]   id do titular
  [4 bytes - int]   tamanho do nome (bytes UTF-8)
  [N bytes]         nome do titular
  [4 bytes - int]   tamanho do CPF (bytes UTF-8)
  [M bytes]         CPF do titular
  [4 bytes - int]   número da conta
  [8 bytes - double] saldo
  [4 bytes - int]   tamanho da senha (bytes UTF-8)
  [S bytes]         senha
  [8 bytes - double] limite (ContaCorrente) ou rendimento (ContaPoupanca)
```

> Todos os valores inteiros e double são escritos em **big-endian**, padrão do `DataOutputStream` do Java.

---

## 🛠 Tecnologias

| Componente | Tecnologia |
|------------|------------|
| Servidor | Java 17+ |
| Cliente | Ruby 3.x |
| Comunicação TCP | Sockets Java / `TCPSocket` Ruby |
| Comunicação Multicast | `DatagramSocket` Java / `UDPSocket` Ruby |
| Serialização | Protocolo binário customizado (big-endian) |
| Persistência | Arquivo binário `contas.bin` |
| Interface do terminal | `tty-prompt`, `pastel` (Ruby gems) |
| Concorrência | Java Threads (uma por conexão) + Thread Ruby (multicast) |

---

> **Nota:** O endereço do servidor está definido em `connection.rb` nas constantes `NGROK_HOST` e `NGROK_PORT`. Altere conforme o ambiente de execução.
