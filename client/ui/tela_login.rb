# tela_login.rb
require 'tty-prompt'
require 'pastel'
require_relative 'banner'

module UI
  class TelaLogin
    def initialize
      @prompt = TTY::Prompt.new(interrupt: :exit)
    end

    def exibir
      UI.cabecalho(nil, "ACESSO À CONTA")
      UI.titulo_secao("IDENTIFICAÇÃO DO CLIENTE")

      cpf   = @prompt.ask(UI.secundario("  CPF          : "), required: true) do |q|
        q.validate(/\A[\d.\-]+\z/, "CPF inválido — use apenas números")
      end

      senha = @prompt.mask(UI.secundario("  Senha        : "), required: true)

      UI.espaco
      UI.linha_fina
      UI.espaco

      { cpf: cpf, senha: senha }
    end
  end
end