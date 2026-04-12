require_relative 'protocol'

begin
  File.open('contas.bin', 'rb') do |f|  
    contas = Protocol.read_contas(f)

    contas.each do |conta|
      puts "========================="
      puts "Tipo:    #{conta.tipo_nome}"
      puts "Número:  #{conta.numero}"
      puts "Saldo:   R$ #{'%.2f' % conta.saldo}"
      puts "Titular: #{conta.titular.nome}"
      puts "CPF:     #{conta.titular.cpf}"
      puts "ID:      #{conta.titular.id}"

      if conta.corrente?
        puts "Limite:     R$ #{'%.2f' % conta.limite}"
      else
        puts "Rendimento: #{(conta.rendimento * 100).round(3)}% a.m."
      end
    end

  puts "========================="
  end
rescue Errno::ENOENT
  puts "Arquivo contas.bin não encontrado! Gere-o com o TesteStreams.java primeiro."
rescue => e
  puts "Erro ao ler o arquivo: #{e.message}"
end