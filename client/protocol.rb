require_relative 'models'

module Protocol
  def self.read_int(io)
    io.read(4).unpack1('N')
  end

  def self.read_double(io)
    io.read(8).unpack1('G')
  end

  def self.read_string(io)
    tamanho = read_int(io)
    io.read(tamanho).force_encoding('UTF-8')
  end

  def self.read_contas(io)
    quantidade = read_int(io)

    quantidade.times.map do
      tipo     = read_int(io)
      _payload = read_int(io)

      id    = read_int(io)
      nome  = read_string(io)
      cpf   = read_string(io)
      
      
      titular = Cliente.new(id, nome, cpf)

      numero = read_int(io)
      saldo  = read_double(io)
      _senha = read_string(io)
      extra  = read_double(io)

      Conta.new(tipo, numero, saldo, titular, extra)
    end
  end
end