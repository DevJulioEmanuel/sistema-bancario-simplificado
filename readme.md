# 🏦 Sistema Bancário Distribuído — Comunicação entre Processos

> Trabalho 1 — Sockets, Streams, Serialização e Representação Externa de Dados  
> Disciplina: Sistemas Distribuídos
> Integrantes: Arthur Lelis, Julio Emanuel.

---

## 📋 Sumário

- [Visão Geral](#-visão-geral)
- [Modelagem do Sistema](#-modelagem-do-sistema)
- [Classes de Serviço](#️-classes-de-serviço)
- [Exercício 1 — POJOs e Serviços](#-exercício-1--pojos-e-serviços)
- [Exercício 2 — OutputStream Customizado](#-exercício-2--outputstream-customizado)
- [Exercício 3 — InputStream Customizado](#-exercício-3--inputstream-customizado)
- [Exercício 4 — Comunicação Cliente-Servidor com Serialização](#-exercício-4--comunicação-cliente-servidor-com-serialização)
- [Exercício 5 — Notificações Segmentadas com UDP Multicast](#-exercício-5--notificações-segmentadas-com-udp-multicast)
- [Organização do Projeto](#-organização-do-projeto)
- [Tecnologias](#-tecnologias)
- [Como Executar](#-como-executar)

---

## 🌐 Visão Geral

Sistema bancário distribuído implementado com comunicação cliente-servidor via sockets TCP/UDP. O servidor é desenvolvido em **Java** e o cliente em **Ruby**, demonstrando interoperabilidade entre linguagens via serialização JSON e streams binários customizados.

O sistema cobre operações bancárias básicas (depósito, saque, transferência, pagamento) e inclui um subsistema de notificações segmentadas via multicast UDP, onde o servidor envia alertas para clientes elegíveis com base no perfil de conta.

---

## 🧱 Modelagem do Sistema

### Hierarquia de Classes (POJOs)

```
Conta (superclasse abstrata)
├── ContaCorrente   implements Tributável
└── ContaPoupanca
```

### 📦 Classes POJO

#### `Cliente`
| Atributo | Tipo     | Bytes |
|----------|----------|-------|
| id       | `int`    | 4     |
| nome     | `String` | variável (2 bytes de tamanho + conteúdo UTF-8) |
| cpf      | `String` | 11 bytes fixos |

#### `Conta` (abstrata)
| Atributo | Tipo      | Bytes |
|----------|-----------|-------|
| numero   | `int`     | 4     |
| saldo    | `double`  | 8     |
| titular  | `Cliente` | referência OO |

#### `ContaCorrente` extends `Conta` implements `Tributável`
| Atributo | Tipo     | Bytes |
|----------|----------|-------|
| limite   | `double` | 8     |

#### `ContaPoupanca` extends `Conta`
| Atributo   | Tipo     | Bytes |
|------------|----------|-------|
| rendimento | `double` | 8     |

#### `Banco`
| Atributo       | Tipo            |
|----------------|-----------------|
| clientes       | `List<Cliente>` |
| contas         | `List<Conta>`   |

> `List<Conta>` é polimórfico — aceita `ContaCorrente` e `ContaPoupanca` sem duplicação de lógica.

---

## 💰 Interface Tributável

Aplicada a contas com incidência de imposto.

```java
public interface Tributavel {
    double calcularImposto();
}
```

`ContaCorrente` implementa `Tributavel`. O imposto é calculado e descontado no momento do saque.

---

## ⚙️ Classes de Serviço

### `ContaService`
Centraliza as regras de negócio sobre contas.

| Método | Descrição |
|--------|-----------|
| `depositar(Conta, double)` | Adiciona saldo à conta |
| `sacar(Conta, double)` | Remove saldo (valida limite em ContaCorrente) |
| `transferir(Conta, Conta, double)` | Transfere valor entre duas contas |
| `pagar(Conta, double, String)` | Realiza pagamento a um destinatário |

### `ClienteService`
Gerencia operações relacionadas a clientes.

| Método | Descrição |
|--------|-----------|
| `cadastrar(Cliente)` | Registra novo cliente |
| `buscarPorCpf(String)` | Localiza cliente pelo CPF |
| `listarContas(String cpf)` | Retorna todas as contas de um cliente |

---

## 📌 Exercício 1 — POJOs e Serviços

**Requisito:** Criar classes POJO representando o domínio e 2 classes que implementam serviços.

**Entrega:**
- POJOs: `Cliente`, `Conta`, `ContaCorrente`, `ContaPoupanca`, `Banco`
- Interface: `Tributavel`
- Serviços: `ContaService`, `ClienteService`

---

## 📤 Exercício 2 — OutputStream Customizado

**Requisito:** Criar uma subclasse de `OutputStream` que serializa um array de POJOs como bytes.

### Classe: `ContaOutputStream`

```java
public class ContaOutputStream extends OutputStream {
    public ContaOutputStream(Conta[] contas, int quantidade, OutputStream destino);
    
    @Override
    public void write(int b) throws IOException;
    
    public void enviar() throws IOException;
}
```

**Protocolo de serialização por objeto `Conta`:**

```
[4 bytes] numero (int)
[8 bytes] saldo (double)
[4 bytes] id do titular (int)
[2 bytes] tamanho do nome (short)
[N bytes] nome do titular (UTF-8)
[11 bytes] CPF do titular (String fixa)
```

**Testes:**

| Destino | Implementação |
|---------|--------------|
| Saída padrão | `System.out` |
| Arquivo | `FileOutputStream` |
| Servidor remoto | Socket TCP |

---

## 📥 Exercício 3 — InputStream Customizado

**Requisito:** Criar uma subclasse de `InputStream` que lê os bytes gerados pelo `ContaOutputStream` e reconstrói os objetos.

### Classe: `ContaInputStream`

```java
public class ContaInputStream extends InputStream {
    public ContaInputStream(InputStream origem);
    
    @Override
    public int read() throws IOException;
    
    public Conta[] receber(int quantidade) throws IOException;
}
```

**Testes:**

| Origem | Implementação |
|--------|--------------|
| Entrada padrão | `System.in` |
| Arquivo | `FileInputStream` |
| Servidor remoto | Socket TCP |

---

## 🔄 Exercício 4 — Comunicação Cliente-Servidor com Serialização

**Requisito:** Serviço remoto via TCP com empacotamento/desempacotamento de mensagens JSON.

### Fluxo de uma Transferência

**1. Cliente empacota e envia:**
```json
{
  "operacao": "transferencia",
  "origem": 123,
  "destino": 456,
  "valor": 100.0
}
```

**2. Servidor:**
- Recebe a requisição via socket TCP
- Desserializa JSON → objeto
- Executa regra de negócio via `ContaService`
- Empacota e retorna a resposta

**3. Servidor responde:**
```json
{
  "status": "sucesso",
  "saldoAtualizado": 250.0,
  "mensagem": "Transferência realizada com sucesso"
}
```

**4. Cliente desempacota e exibe o resultado.**

### Operações suportadas

| Operação       | Campos obrigatórios na requisição |
|----------------|-----------------------------------|
| `deposito`     | `conta`, `valor` |
| `saque`        | `conta`, `valor` |
| `transferencia`| `origem`, `destino`, `valor` |
| `pagamento`    | `conta`, `valor`, `destinatario` |
| `saldo`        | `conta` |

### Servidor Multi-thread

O servidor cria uma nova thread para cada conexão recebida:

```
ServidorTCP
└── aceita conexão
    └── nova Thread(ManipuladorCliente)
        ├── desempacota requisição
        ├── executa ContaService
        └── empacota e envia resposta
```

---

## 📣 Exercício 5 — Notificações Segmentadas com UDP Multicast

**Requisito:** Comunicação multicast UDP adaptada ao contexto bancário. O servidor envia notificações para grupos de clientes com base no perfil de conta (ex: saldo mínimo), com a **validação feita inteiramente no servidor**.

### Ideia Central

O gerente do banco dispara uma notificação direcionada a clientes com saldo acima de um determinado valor. O servidor consulta os clientes elegíveis, gera um token individual para cada um e envia a mensagem via multicast UDP. Cada cliente recebe a mensagem, mas só a exibe se o token presente na mensagem for o seu — garantindo que a regra de negócio fica no servidor.

### Arquitetura

```
┌─────────────┐  TCP (login/token)  ┌──────────────────────┐
│   Cliente   │◄───────────────────►│                      │
│   Bancário  │                     │  Servidor Bancário   │
└─────────────┘                     │    (multi-thread)    │
                                    │                      │
┌─────────────┐  TCP (unicast)      │  1. Consulta saldos  │
│  Gerente    │───────────────────► │  2. Gera tokens      │
└─────────────┘  dispara notif.     │  3. Envia multicast  │
                                    └──────────┬───────────┘
                                               │
                              UDP Multicast    │
                         (todos recebem,       │
                      só o dono do token exibe)│
                    ┌──────────────────────────┘
                    ▼
         224.0.0.1:5000 (grupo multicast)
```

### Fluxo Detalhado

**1. Cliente faz login via TCP**
O servidor autentica e registra o cliente com seu token único na sessão.

**2. Gerente dispara uma notificação via TCP:**
```json
{
  "tipo": "notificacao",
  "condicao": "saldo_minimo",
  "valor": 5000.0,
  "mensagem": "Você tem uma oferta exclusiva de investimento disponível."
}
```

**3. Servidor processa (regra de negócio centralizada):**
- Consulta todos os clientes conectados
- Filtra quem possui saldo ≥ R$ 5.000
- Para cada cliente elegível, gera um token único
- Envia via UDP multicast uma mensagem com a lista de tokens autorizados

**4. Mensagem multicast enviada para o grupo:**
```json
{
  "tipo": "notificacao",
  "tokens": ["tok_abc123", "tok_xyz789"],
  "mensagem": "Você tem uma oferta exclusiva de investimento disponível.",
  "timestamp": "2024-06-10T14:30:00"
}
```

**5. Cada cliente recebe e verifica:**
- Recebeu o pacote UDP (todos no grupo recebem)
- Verifica se seu token está na lista `tokens`
- Se sim → exibe a notificação
- Se não → descarta silenciosamente

### Exemplos de Notificações Suportadas

| Condição no servidor | Mensagem enviada |
|----------------------|-----------------|
| Saldo ≥ R$ 5.000 | "Oferta exclusiva de investimento disponível" |
| Saldo ≥ R$ 10.000 | "Seu perfil foi atualizado para cliente Premium" |
| Possui `ContaCorrente` com limite | "Nova condição especial de crédito disponível" |
| Todos os clientes | "O sistema entrará em manutenção às 23h" |

### Por que a validação fica no servidor?

A regra de negócio (quem tem saldo suficiente) é sensível e não deve ser exposta ao cliente. O cliente nunca sabe o critério de elegibilidade — ele apenas verifica se possui um token válido na mensagem recebida. Isso mantém a lógica centralizada e segura, enquanto o multicast UDP ainda é usado para o broadcast eficiente da notificação.

---

## 📁 Organização do Projeto

```
sistema-bancario-distribuido/
│
├── servidor/                        # Java
│   ├── models/
│   │   ├── Cliente.java
│   │   ├── Conta.java
│   │   ├── ContaCorrente.java
│   │   ├── ContaPoupanca.java
│   │   └── Banco.java
│   │
│   ├── interfaces/
│   │   └── Tributavel.java
│   │
│   ├── services/
│   │   ├── ContaService.java
│   │   └── ClienteService.java
│   │
│   ├── streams/                     # Exercícios 2 e 3
│   │   ├── ContaOutputStream.java
│   │   └── ContaInputStream.java
│   │
│   ├── sockets/                     # Exercícios 4 e 5
│   │   ├── ServidorTCP.java
│   │   ├── ManipuladorCliente.java
│   │   └── MulticastSender.java
│   │
│   └── notificacao/                 # Exercício 5
│       ├── Notificacao.java
│       ├── GerenciadorTokens.java
│       └── ServidorMulticast.java
│
├── cliente/                         # Ruby
│   ├── main.rb
│   ├── client/
│   │   ├── banco_client.rb          # Exercício 4
│   │   └── notificacao_client.rb    # Exercício 5 — escuta grupo multicast
│   └── models/
│       ├── conta.rb
│       └── cliente.rb
│
└── README.md
```

---

## 🛠 Tecnologias

| Componente | Tecnologia |
|------------|------------|
| Servidor | Java 17+ |
| Cliente | Ruby 3.x |
| Comunicação principal | TCP Sockets |
| Comunicação multicast | UDP Sockets |
| Serialização (ex. 4 e 5) | JSON |
| Streams binários (ex. 2 e 3) | Java OutputStream/InputStream customizados |
| Concorrência | Java Threads (uma por conexão) |

---

## ▶️ Como Executar

### Servidor (Java)

```bash
# Compilar
javac -cp . servidor/**/*.java

# Exercício 4 — Servidor bancário TCP
java servidor.sockets.ServidorTCP

# Exercício 5 — Servidor de notificações multicast
java servidor.sockets.MulticastSender
```

### Cliente (Ruby)

```bash
# Instalar dependências
bundle install

# Exercício 4 — Cliente bancário
ruby cliente/main.rb

# Exercício 5 — Cliente escutando notificações
ruby cliente/client/notificacao_client.rb
```

### Testes dos Streams (Exercícios 2 e 3)

```bash
# Saída padrão
java servidor.streams.TesteOutputStream stdout

# Arquivo
java servidor.streams.TesteOutputStream arquivo contas.bin

# Servidor TCP
java servidor.streams.TesteOutputStream tcp localhost 9090
```

---

## 📌 Ordem de Implementação Recomendada

1. **POJOs e hierarquia de classes** (Conta → ContaCorrente/ContaPoupanca)
2. **ContaOutputStream** com destino `System.out` (mais simples para depurar)
3. **ContaInputStream** lendo de `System.in`
4. **Testes com arquivo** (FileOutputStream / FileInputStream)
5. **Servidor TCP simples** com mensagens de texto
6. **Serialização JSON** e integração com `ContaService`
7. **Testes com socket TCP** nos streams
8. **Cliente Ruby** conectando ao servidor
9. **Sistema de notificações** com multicast UDP e tokens

---

> **Nota:** A persistência em banco de dados é opcional para o escopo deste trabalho. Os dados são mantidos em memória dentro da instância de `Banco` durante a execução do servidor.
