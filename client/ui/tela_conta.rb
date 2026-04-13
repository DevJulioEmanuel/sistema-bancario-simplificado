require 'pastel'
require 'tty-prompt'
require_relative 'banner'
# Certifique-se de que a Connection está acessível aqui. Como você a chamou no main.rb, 
# ela provavelmente já está na memória, mas se der erro de classe não encontrada, 
# adicione: require_relative 'connection'

module UI
  class TelaConta
    def initialize
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
    end

    def exibir(conta)
      loop do
        UI.cabecalho(@pastel)

        puts @pastel.yellow("  ┌──────────────────────────────────────────┐")
        puts @pastel.yellow("  │               MINHA CONTA                │")
        puts @pastel.yellow("  └──────────────────────────────────────────┘")
        puts

        puts @pastel.bright_black("  TITULAR")
        UI.divisor(@pastel)
        campo("Nome",  conta.titular.nome)
        campo("CPF",   conta.titular.cpf)
        puts

        puts @pastel.bright_black("  CONTA")
        UI.divisor(@pastel)
        campo("Tipo",   @pastel.blue(conta.tipo_nome))
        campo("Número", conta.numero.to_s)
        campo("Saldo",  @pastel.green("R$ #{'%.2f' % conta.saldo}"))

        if conta.corrente?
          campo("Limite",     "R$ #{'%.2f' % conta.limite}")
        else
          campo("Rendimento", "#{'%.3f' % (conta.rendimento * 100)}% a.m.")
        end

        puts
        UI.divisor(@pastel)
        puts

        opcao = @prompt.select(@pastel.bright_black("  O que deseja fazer?"), cycle: true) do |menu|
          menu.choice "Depositar", :depositar
          menu.choice "Sacar", :sacar
          menu.choice "Transferir", :transferir
          menu.choice "Pagar Boleto/Conta", :pagar if conta.corrente?
          menu.choice "Projetar Rendimento", :projetar if conta.poupanca?
          menu.choice "Sair (Logout)", :sair
        end

        case opcao
        when :depositar
          valor = @prompt.ask(@pastel.cyan("  Valor do depósito (R$): "), convert: :float)
          
          if valor && valor > 0
            begin
              conn = Connection.new
              resultado = conn.depositar(conta.numero, valor)
              conn.close

              if resultado == :ok
                conta.saldo += valor # Atualiza o saldo na tela automaticamente
                UI.sucesso(@pastel, "Depósito de R$ #{'%.2f' % valor} realizado!")
              else
                UI.erro(@pastel, "Falha ao realizar depósito.")
              end
            rescue
              UI.erro(@pastel, "Erro de comunicação com o servidor.")
            end
            sleep 2
          else
            UI.erro(@pastel, "Valor inválido!")
            sleep 1
          end

        when :sacar
          valor = @prompt.ask(@pastel.cyan("  Valor do saque (R$): "), convert: :float)
          
          if valor && valor > 0
            begin
              conn = Connection.new
              resultado = conn.sacar(conta.numero, valor)
              conn.close

              if resultado == :ok
                conta.saldo -= valor # Atualiza o saldo na tela automaticamente
                UI.sucesso(@pastel, "Saque de R$ #{'%.2f' % valor} realizado!")
              elsif resultado == :saldo_insuficiente
                UI.erro(@pastel, "Saldo ou Limite insuficiente!")
              else
                UI.erro(@pastel, "Falha ao realizar saque.")
              end
            rescue
              UI.erro(@pastel, "Erro de comunicação com o servidor.")
            end
            sleep 2
          else
            UI.erro(@pastel, "Valor inválido!")
            sleep 1
          end
        
        when :transferir
          destino = @prompt.ask(@pastel.cyan("  Número da conta destino: "), convert: :integer)
          valor = @prompt.ask(@pastel.cyan("  Valor da transferência (R$): "), convert: :float)

          if destino && valor && valor > 0
            if destino == conta.numero
              UI.erro(@pastel, "Você não pode transferir para si mesmo!")
              sleep 2
              next # Pula para o próximo ciclo do loop sem fazer requisição
            end

            begin
              conn = Connection.new
              resultado = conn.transferir(conta.numero, destino, valor)
              conn.close

              case resultado
              when :ok
                conta.saldo -= valor # Atualiza o saldo na tela
                UI.sucesso(@pastel, "Transferência de R$ #{'%.2f' % valor} realizada!")
              when :destino_invalido
                UI.erro(@pastel, "Conta destino (#{destino}) não existe!")
              when :saldo_insuficiente
                UI.erro(@pastel, "Saldo ou Limite insuficiente para transferência!")
              else
                UI.erro(@pastel, "Falha ao realizar transferência.")
              end
            rescue => e
              UI.erro(@pastel, "Erro de comunicação: #{e.message}")
            end
            sleep 2
          else
            UI.erro(@pastel, "Dados inválidos!")
            sleep 1
          end

        when :pagar
          descricao = @prompt.ask(@pastel.cyan("  Descrição (ex: Conta de Luz): "), required: true)
          valor = @prompt.ask(@pastel.cyan("  Valor do pagamento (R$): "), convert: :float)

          if valor && valor > 0
            begin
              conn = Connection.new
              resultado = conn.pagar(conta.numero, valor, descricao)
              conn.close

              case resultado
              when :ok
                conta.saldo -= valor # Atualiza o saldo na tela
                UI.sucesso(@pastel, "Pagamento de R$ #{'%.2f' % valor} (#{descricao}) realizado!")
              when :saldo_insuficiente
                UI.erro(@pastel, "Saldo ou Limite insuficiente para o pagamento!")
              else
                UI.erro(@pastel, "Falha ao realizar pagamento.")
              end
            rescue => e
              UI.erro(@pastel, "Erro de comunicação: #{e.message}")
            end
            sleep 2
          else
            UI.erro(@pastel, "Valor inválido!")
            sleep 1
          end

        when :projetar
          meses = @prompt.ask(@pastel.cyan("  Quantidade de meses: "), convert: :integer)
          
          if meses && meses > 0
            begin
              conn = Connection.new
              resultado = conn.projetar_rendimento(conta.numero, meses)
              conn.close

              if resultado[:status] == :ok
                puts
                UI.sucesso(@pastel, "Em #{meses} meses, o saldo projetado é:")
                puts @pastel.green("  R$ #{'%.2f' % resultado[:valor]}")
                puts
                @prompt.keypress(@pastel.bright_black("  Pressione qualquer tecla para continuar..."))
              else
                UI.erro(@pastel, "Falha ao projetar rendimento.")
                sleep 2
              end
            rescue => e
              UI.erro(@pastel, "Erro de comunicação: #{e.message}")
              sleep 2
            end
          else
            UI.erro(@pastel, "Quantidade de meses inválida!")
            sleep 1
          end

        when :sair
          break # Sai do loop e volta para o menu principal
        end
      end
    end

    private

    def campo(label, valor)
      l = @pastel.bright_black("  %-10s: " % label)
      puts "#{l}#{valor}"
    end
  end
end