# banner.rb
require 'io/console'
require 'pastel'

module UI
  LOGO = <<~LOGO
    ╔╗ ╔═╗╔╗╔╔═╗╔═╗
    ╠╩╗╠═╣║║║║  ║ ║
    ╚═╝╩ ╩╝╚╝╚═╝╚═╝
  LOGO

  NOME_BANCO   = "BANCO QUIDESCO"
  VERSAO       = "v1.0  •  Sistema Bancário"
  LARGURA_UI   = 51

  def self.p
    @pastel ||= Pastel.new
  end

  def self.primario(txt)   = p.bold.black(txt)
  def self.secundario(txt) = p.bright_black(txt)
  def self.destaque(txt)   = p.bold.cyan(txt)
  def self.valor_pos(txt)  = p.bold.green(txt)
  def self.valor_neg(txt)  = p.bold.red(txt)
  def self.alerta(txt)     = p.bold.yellow(txt)

  def self.margem
    cols = (IO.console&.winsize&.[](1)) || 80
    " " * [((cols - LARGURA_UI) / 2), 0].max
  end

  def self.limpar = system("clear") || system("cls")

  def self.linha_fina(cor: :bright_black)
    m = margem
    puts m + p.decorate("─" * LARGURA_UI, cor)
  end

  def self.linha_dupla
    m = margem
    puts m + p.bold.cyan("═" * LARGURA_UI)
  end


  def self.cabecalho(pastel = p, subtitulo = nil)
    limpar
    m = margem
    puts

    logo_linhas = LOGO.lines.map(&:chomp)
    meio = logo_linhas.size / 2

    logo_linhas.each_with_index do |linha, i|
      sufixo = i == meio ? "  #{p.bold.black(NOME_BANCO)}" : ""
      puts m + p.bold.blue(linha) + sufixo
    end

    puts m + p.black(VERSAO.rjust(LARGURA_UI))  # corrigido
    puts m + p.blue("═" * LARGURA_UI)           # sem cyan
    puts m + p.bold.blue(subtitulo.center(LARGURA_UI)) if subtitulo
    puts
  end

  def self.titulo_secao(texto)
    m = margem
    largura_interna = LARGURA_UI - 2
    puts m + p.blue("┌" + "─" * largura_interna + "┐")
    puts m + p.blue("│") + p.bold.black(texto.center(largura_interna)) + p.blue("│")
    puts m + p.blue("└" + "─" * largura_interna + "┘")
    puts
  end

  def self.label_secao(texto)
    m = margem
    puts m + p.bold.blue("▸ ") + p.bold.black(texto)
    puts m + p.black("─" * LARGURA_UI)
  end

  def self.campo(label, valor, largura_label: 14)
    m = margem
    rotulo = p.bright_black("%-#{largura_label}s" % label)
    puts "#{m}  #{rotulo}#{valor}"
  end

  def self.sucesso(pastel = p, msg)
    puts
    puts margem + p.bold.green("  ✔  ") + p.green(msg)
  end

  def self.erro(pastel = p, msg)
    puts
    puts margem + p.bold.red("  ✖  ") + p.red(msg)
  end

  def self.info(msg)
    puts margem + p.bold.blue("  ℹ  ") + p.black(msg)
  end

  def self.badge(texto, cor: :blue)
    p.decorate("#{texto} ", cor, :bold)
  end

  def self.espaco(n = 1) = n.times { puts }
end