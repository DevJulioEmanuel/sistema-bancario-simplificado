require 'tty-prompt'
require 'pastel'
require_relative 'models'
require_relative 'protocol'
require_relative 'connection'
require_relative 'ui/banner'
require_relative 'ui/tela_login'
require_relative 'ui/tela_cadastro'
require_relative 'ui/tela_conta'
require_relative 'session'
require_relative 'notificacao_listener'

listener = NotificacaoListener.new
listener.start

pastel = Pastel.new
prompt = TTY::Prompt.new

loop do
  UI.cabecalho(pastel)
  notifs = Session.pegar_notificacoes
  unless notifs.empty?
    puts
    notifs.each do |msg|
      puts pastel.yellow("📢 #{msg}")
    end
    puts
  end
  opcao = prompt.select(pastel.bright_black("  O que deseja fazer?"), cycle: true) do |menu|
    menu.choice "Login",       :login
    menu.choice "Criar conta", :cadastro
    menu.choice "Sair",        :sair
  end

  case opcao
  when :login
    resultado = UI::TelaLogin.new.exibir

    tipo = prompt.select(pastel.cyan("  Tipo de conta:")) do |menu|
      menu.choice "Conta Corrente", 1
      menu.choice "Conta Poupança", 2
    end

    begin
      conn  = Connection.new
      conta = conn.login(resultado[:cpf], resultado[:senha], tipo)
      conn.close

      if conta == :erro || conta.nil?
        UI.cabecalho(pastel)
        UI.erro(pastel, "CPF, senha ou tipo de conta incorretos.")
        sleep 2
      else
        Session.login
        UI::TelaConta.new.exibir(conta)
      end
    rescue Errno::ECONNREFUSED, Errno::EAGAIN, Errno::EWOULDBLOCK, IO::TimeoutError
      UI.cabecalho(pastel)
      UI.erro(pastel, "Servidor não respondeu. Tente novamente.")
      sleep 2
    end

  when :cadastro
    dados = UI::TelaCadastro.new.exibir
    next unless dados

    begin
      conn      = Connection.new
      resposta  = conn.cadastro(dados[:nome], dados[:cpf], dados[:senha], dados[:tipo])
      conn.close

      UI.cabecalho(pastel)
      if resposta == :ok
        UI.sucesso(pastel, "Cadastro realizado com sucesso!")
      else
        UI.erro(pastel, "CPF já cadastrado.")
      end
      sleep 2
    rescue Errno::ECONNREFUSED, Errno::EAGAIN, Errno::EWOULDBLOCK, IO::TimeoutError
      UI.cabecalho(pastel)
      UI.erro(pastel, "Servidor não respondeu. Tente novamente.")
      sleep 2
    end
    
  when :sair
    UI.limpar
    puts pastel.cyan("  Até logo!\n\n")
    break
  end
end