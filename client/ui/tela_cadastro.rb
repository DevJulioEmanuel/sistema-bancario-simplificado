require 'tty-prompt'
require 'pastel'
require_relative 'banner'

module UI
  class TelaCadastro
    def initialize
      @prompt = TTY::Prompt.new
      @pastel = Pastel.new
    end

    def exibir
  UI.cabecalho(@pastel)

  puts @pastel.yellow("  ┌─────────────────────────────────────┐")
  puts @pastel.yellow("  │              NOVA CONTA             │")
  puts @pastel.yellow("  └─────────────────────────────────────┘")
  puts

  nome  = @prompt.ask(@pastel.cyan("  Nome completo : "), required: true)
  cpf   = @prompt.ask(@pastel.cyan("  CPF           : "), required: true)
  senha = @prompt.mask(@pastel.cyan("  Senha         : "), required: true)

  puts
  tipo = @prompt.select(@pastel.cyan("  Tipo de conta :")) do |menu|
    menu.choice "Conta Corrente   (limite R$ 1.200,00)",    1
    menu.choice "Conta Poupança   (rendimento 0,5% a.m.)", 2
  end

  puts
  UI.divisor(@pastel)
  puts

  confirmar = @prompt.select(@pastel.bright_black("  Confirmar?")) do |menu|
    menu.choice @pastel.green("Confirmar cadastro"), :confirmar
    menu.choice "Voltar",                             :voltar
  end

  return nil if confirmar == :voltar

  { nome: nome, cpf: cpf, senha: senha, tipo: tipo }
    end
  end
end