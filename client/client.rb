require 'tty-prompt'
require 'pastel'
require_relative 'models'
require_relative 'protocol'
require_relative 'ui/banner'
require_relative 'ui/tela_login'
require_relative 'ui/tela_conta'
require_relative 'ui/tela_cadastro'

pastel  = Pastel.new
prompt  = TTY::Prompt.new

# Futuramente: contas virão do servidor via socket
# Por agora lê do arquivo local pra testar as telas
contas = File.open('contas.bin', 'rb') { |f| Protocol.read_contas(f) }

loop do
  UI.cabecalho(pastel)

  opcao = prompt.select(pastel.bright_black("  O que deseja fazer?"), cycle: true) do |menu|
    menu.choice "Login",        :login
    menu.choice "Criar conta",  :cadastro
    menu.choice "Sair",         :sair
  end

  case opcao
  when :login
    resultado = UI::TelaLogin.new.exibir

    # MOCK temporário — remove quando o servidor estiver pronto
    titular = Cliente.new(1000, "Julio Emanuel", "012.345.678-90")
    conta   = Conta.new(1, 1000, 2500.00, titular, 1200.00)

    UI::TelaConta.new.exibir(conta)

  when :cadastro
    dados = UI::TelaCadastro.new.exibir
    if dados
      UI.cabecalho(pastel)
      UI.sucesso(pastel, "Cadastro enviado! Aguardando servidor...")
      sleep 2
    end

  when :sair
    UI.limpar
    puts pastel.cyan("  Até logo!\n\n")
    break
  end
end