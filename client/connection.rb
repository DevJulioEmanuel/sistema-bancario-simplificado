require 'socket'
require 'timeout'

require_relative 'protocol'

class Connection
  NGROK_HOST = '0.tcp.sa.ngrok.io'
  NGROK_PORT = 16962
  TIMEOUT    = 5  

  def initialize(host: NGROK_HOST, port: NGROK_PORT)
    @socket = TCPSocket.new(host, port)
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, [TIMEOUT, 0].pack('l_2'))
  end

  def write_int(val)
    @socket.write([val].pack('N'))
  end

  def write_utf(str)
    bytes = str.encode('UTF-8').b
    @socket.write([bytes.bytesize].pack('n'))
    @socket.write(bytes)
  end

  def write_double(val)
    # 'G' é o formato float 64-bit network byte order (Big-Endian) compatível com o Java
    @socket.write([val].pack('G')) 
  end

  def read_int
    bytes = @socket.read(4)
    # Proteção: Se o Java fechar a conexão do nada, evitamos o travamento do Ruby
    raise "Servidor encerrou a conexão inesperadamente" if bytes.nil? || bytes.bytesize < 4
    bytes.unpack1('N')
  end

  def cadastro(nome, cpf, senha, tipo)
    write_int(1)         # op = 1 (Cadastro)
    write_utf(nome)
    write_utf(cpf)
    write_utf(senha)
    write_int(tipo)

    resposta = read_int
    resposta == 0 ? :ok : :erro
  end

  def login(cpf, senha, tipo)
    write_int(2)         # op = 2 (Login)
    write_utf(cpf)
    write_utf(senha)
    write_int(tipo)

    resposta = read_int
    return :erro if resposta != 0

    contas = Protocol.read_contas(@socket)
    return contas.first
  end

  def depositar(numero_conta, valor)
    write_int(4)             # op = 4 (Depósito)
    write_int(numero_conta)
    write_double(valor)

    resposta = read_int
    resposta == 0 ? :ok : :erro
  end

  def sacar(numero_conta, valor)
    write_int(3)             # op = 3 (Saque)
    write_int(numero_conta)
    write_double(valor)

    resposta = read_int
    case resposta
    when 0  then :ok
    when -2 then :saldo_insuficiente
    else :erro
    end
  end

  def close
    @socket.close rescue nil
  end
end