Cliente = Struct.new(:id, :nome, :cpf)

Conta = Struct.new(:tipo, :numero, :saldo, :titular, :extra) do
  def corrente?  = tipo == 1
  def poupanca?  = tipo == 2
  def limite     = corrente? ? extra : nil
  def rendimento = poupanca? ? extra : nil

  def tipo_nome
    corrente? ? "Conta Corrente" : "Conta Poupança"
  end
end