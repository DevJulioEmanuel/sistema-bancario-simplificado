require 'socket'
require 'timeout'

require_relative 'protocol'

class Connection
  NGROK_HOST = 'localhost'
  NGROK_PORT = 7896
  TIMEOUT    = 5  

  def initialize(host: NGROK_HOST, port: NGROK_PORT)
    @socket = TCPSocket.new(host, port)
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, [TIMEOUT, 0].pack('l_2'))
  end

  # ================= WRITE =================

  def write_int(val)
    @socket.write([val].pack('N')) # int (4 bytes, big-endian)
  end

  def write_double(val)
    @socket.write([val].pack('G')) # double (Java compatível)
  end

  def write_utf(str)
    bytes = str.encode('UTF-8').b
    @socket.write([bytes.bytesize].pack('n')) # tamanho (2 bytes)
    @socket.write(bytes)
  end

  # ================= READ =================

  def read_int
    bytes = @socket.read(4)
    raise "Servidor encerrou a conexão (int)" if bytes.nil? || bytes.bytesize < 4
    bytes.unpack1('N')
  end

  def read_double
    bytes = @socket.read(8)
    raise "Servidor encerrou a conexão (double)" if bytes.nil? || bytes.bytesize < 8
    bytes.unpack1('G')
  end

  def read_utf
    tamanho_bytes = @socket.read(2)
    raise "Erro ao ler UTF (tamanho)" if tamanho_bytes.nil? || tamanho_bytes.bytesize < 2

    tamanho = tamanho_bytes.unpack1('n')
    dados = @socket.read(tamanho)

    raise "Erro ao ler UTF (dados)" if dados.nil? || dados.bytesize < tamanho

    dados.force_encoding('UTF-8')
  end

  # ================= OPERAÇÕES =================

  def cadastro(nome, cpf, senha, tipo)
    write_int(1)
    write_utf(nome)
    write_utf(cpf)
    write_utf(senha)
    write_int(tipo)

    resposta = read_int
    resposta == 0 ? :ok : :erro
  end

  def login(cpf, senha, tipo)
    write_int(2)
    write_utf(cpf)
    write_utf(senha)
    write_int(tipo)

    resposta = read_int
    return :erro if resposta != 0

    contas = Protocol.read_contas(@socket)
    contas.first
  end

  def depositar(numero_conta, valor)
    write_int(4)
    write_int(numero_conta)
    write_double(valor)

    resposta = read_int
    resposta == 0 ? :ok : :erro
  end

  def sacar(numero_conta, valor)
    write_int(3)
    write_int(numero_conta)
    write_double(valor)

    resposta = read_int
    case resposta
    when 0  then :ok
    when -2 then :saldo_insuficiente
    else :erro
    end
  end

  def transferir(num_origem, num_destino, valor)
    write_int(5)
    write_int(num_origem)
    write_int(num_destino)
    write_double(valor)

    resposta = read_int
    case resposta
    when 0  then :ok
    when -1 then :origem_invalida
    when -2 then :destino_invalido
    when -3 then :saldo_insuficiente
    else :erro
    end
  end

  def pagar(numero_conta, valor, descricao)
    write_int(6)
    write_int(numero_conta)
    write_double(valor)
    write_utf(descricao)

    resposta = read_int
    case resposta
    when 0  then :ok
    when -1 then :conta_invalida
    when -2 then :saldo_insuficiente
    else :erro
    end
  end

  def projetar_rendimento(numero_conta, meses)
    write_int(7)
    write_int(numero_conta)
    write_int(meses)

    resposta = read_int
    if resposta == 0
      valor = read_double
      { status: :ok, valor: valor }
    else
      { status: :erro }
    end
  end

  # ⭐ NOVA FUNCIONALIDADE: EXTRATO

  def extrato(numero_conta)
    write_int(8)
    write_int(numero_conta)

    status = read_int
    return nil if status == -1

    tamanho = read_int
    linhas = []

    tamanho.times do
      linhas << read_utf
    end

    linhas
  end

  # ================= FINAL =================

  def close
    @socket.close rescue nil
  end
end