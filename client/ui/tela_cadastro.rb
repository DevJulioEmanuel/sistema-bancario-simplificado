# tela_cadastro.rb
require 'tty-prompt'
require 'pastel'
require_relative 'banner'

module UI
  class TelaCadastro
    TIPOS = {
      1 => { nome: "Corrente",  detalhe: "Limite R$ 1.200,00",    badge_cor: :blue   },
      2 => { nome: "Poupança",  detalhe: "Rendimento 0,500% a.m.", badge_cor: :green  },
    }.freeze

    def initialize
      @prompt = TTY::Prompt.new(interrupt: :exit)
    end

    def exibir
      UI.cabecalho(nil, "ABERTURA DE CONTA")
      UI.titulo_secao("DADOS PESSOAIS")

      nome  = @prompt.ask(UI.secundario("  Nome completo : "), required: true)
      cpf   = @prompt.ask(UI.secundario("  CPF           : "), required: true)
      senha = @prompt.mask(UI.secundario("  Senha         : "), required: true)

      UI.espaco
      UI.label_secao("TIPO DE CONTA")
      UI.espaco

      tipo = @prompt.select(UI.secundario("  Escolha o tipo:"), cycle: true) do |menu|
        TIPOS.each do |id, info|
          menu.choice "#{info[:nome].ljust(12)}  #{UI.secundario(info[:detalhe])}", id
        end
      end

      # Preview da conta que será criada
      UI.espaco
      UI.linha_fina
      UI.espaco
      _resumo_abertura(nome, cpf, tipo)
      UI.espaco
      UI.linha_fina
      UI.espaco

      confirmar = @prompt.select(UI.secundario("  Confirmar abertura?"), cycle: true) do |menu|
        menu.choice UI.valor_pos("✔  Confirmar"),  :confirmar
        menu.choice UI.valor_neg("✖  Cancelar"),   :voltar
      end

      return nil if confirmar == :voltar

      { nome: nome, cpf: cpf, senha: senha, tipo: tipo }
    end

    private

    def _resumo_abertura(nome, cpf, tipo)
      info = TIPOS[tipo]
      UI.label_secao("RESUMO DA ABERTURA")
      UI.campo("Titular",   UI.primario(nome))
      UI.campo("CPF",       UI.secundario(cpf))
      UI.campo("Tipo",      UI.badge(info[:nome], cor: info[:badge_cor]))
      UI.campo("Condições", UI.secundario(info[:detalhe]))
    end
  end
end