require 'pastel'
require 'tty-prompt'
require_relative 'banner'

module UI
  class TelaConta
    def initialize
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
    end

    def exibir(conta)
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
      UI.sucesso(@pastel, "Conta carregada com sucesso")
      UI.divisor(@pastel)
      puts

      @prompt.keypress(@pastel.bright_black("  Pressione qualquer tecla para voltar..."))
    end

    private

    def campo(label, valor)
      l = @pastel.bright_black("  %-10s: " % label)
      puts "#{l}#{valor}"
    end
  end
end