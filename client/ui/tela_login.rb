require 'tty-prompt'
require 'pastel'
require_relative 'banner'

module UI
  class TelaLogin
    def initialize
      @prompt = TTY::Prompt.new
      @pastel = Pastel.new
    end

    def exibir
      UI.cabecalho(@pastel, "LOGIN")

      cpf   = @prompt.ask(@pastel.cyan("  CPF   : "), required: true)
      senha = @prompt.mask(@pastel.cyan("  Senha : "), required: true)

      
      { cpf: cpf, senha: senha }
    end
  end
end