# 📄 Documento do Projeto — Sistema Distribuído

## 🎓 Informações Gerais

- **Disciplina:** Sistemas Distribuídos
- **Professor:** Rafael Braga
- **Universidade:** UFC - Campus Quixadá
- **Trabalho:** Comunicação entre processos (Sockets e Streams)

---

## 👥 Equipe

- **Cliente:** Julio Emanuel
- **Servidor:** Arthur Lelis

---

## 🧩 Arquitetura Geral

O sistema será dividido em duas aplicações:

### 🖥️ Servidor

- Linguagem: **Java**
- Responsável por:
  - Processamento das requisições
  - Regras de negócio
  - Controle de contas e clientes
  - Persistência de dados
  - Comunicação com múltiplos clientes (multi-thread)

---

### 💻 Cliente

- Linguagem: **Golang**
- Responsável por:
  - Interface de interação
  - Envio de requisições ao servidor
  - Recebimento e exibição de respostas

---

## 🔗 Comunicação

- **Protocolo:** TCP (Sockets)
- **Formato de dados:** JSON (recomendado)
- **Modelo:**
  - Cliente envia requisição → Servidor processa → Servidor responde

---

## 🗄️ Persistência

- **Banco de dados:** PostgreSQL
- Uso:
  - Armazenamento de clientes
  - Armazenamento de contas
  - Histórico de operações (opcional)

> ⚠️ Observação: O banco será utilizado apenas para persistência, não para comunicação direta entre cliente e servidor.

---

## 🧱 Modelagem do Sistema

### 📦 Classes POJO

As classes representam os dados do sistema:

- **Cliente**
  - id
  - nome
  - cpf

- **ContaCorrente**
  - numero
  - saldo
  - limite

- **ContaPoupanca**
  - numero
  - saldo
  - rendimento

- **Banco**
  - lista de clientes
  - lista de contas

---

## 🔌 Interface

### 💰 Tributável (Impostos)

Interface aplicada a contas que possuem cobrança de imposto.

**Método esperado:**

- calcularImposto()

**Exemplo de uso:**

- ContaCorrente implementa Tributável

---

## ⚙️ Classes de Serviço

Responsáveis pelas regras de negócio:

- **Pagamento**
  - Realiza pagamentos a partir de uma conta

- **Depósito**
  - Adiciona saldo a uma conta

- **Saque**
  - Remove saldo de uma conta

- **Transferência**
  - Transfere valor entre contas

---

## 🔄 Fluxo de Operação

### 📌 Exemplo: Transferência

1. Cliente envia requisição:

   ```json
   {
     "operacao": "transferencia",
     "origem": 123,
     "destino": 456,
     "valor": 100.0
   }
   ```

2. Servidor:
   - Recebe a requisição
   - Desserializa (JSON → objeto)
   - Executa regra de negócio
   - Atualiza banco de dados
   - Retorna resposta

3. Cliente:
   - Recebe resposta
   - Exibe resultado

---

## 🔁 Serialização

Será necessário:

- **Cliente:**
  - Empacotar dados (objeto → JSON)
  - Desempacotar resposta (JSON → objeto)

- **Servidor:**
  - Desempacotar requisição
  - Empacotar resposta

---

## 🌐 Sockets

### TCP

- Comunicação principal cliente-servidor

---

## 🧪 Streams Customizados

### OutputStream (Java)

- Classe personalizada para enviar objetos como bytes

### InputStream (Java)

- Classe personalizada para ler bytes e reconstruir objetos

---

## 🧵 Concorrência

O servidor será **multi-thread**, permitindo múltiplos clientes simultaneamente.

**Modelo:**

- Uma thread por conexão

---

## 📌 Organização do Projeto

### Servidor (Java)

- models/
- services/
- streams/
- sockets/
- database/

### Cliente (Golang)

- main.go
- client/
- models/

---

## ✅ Requisitos Atendidos

- Comunicação via sockets
- Serialização de dados
- Cliente e servidor em linguagens diferentes
- Uso de streams personalizados
- Separação em camadas (modelo, serviço, comunicação)
- Persistência com banco de dados

---

## 🚀 Observações Finais

- Priorizar funcionamento da comunicação antes da persistência
- Começar com mensagens simples (string/JSON)
- Evoluir para objetos mais complexos
- Testar cada parte separadamente

---
