# banner.rb
require 'io/console'
require 'pastel'

module UI
  # ── Identidade visual ────────────────────────────────────────────────────────
  LOGO = <<~LOGO
    ╔╗ ╔═╗╔╗╔╔═╗╔═╗
    ╠╩╗╠═╣║║║║  ║ ║
    ╚═╝╩ ╩╝╚╝╚═╝╚═╝
  LOGO

  NOME_BANCO   = "BANCO DISTRIBUÍDO"
  VERSAO       = "v1.0  •  Sistema Bancário"
  LARGURA_UI   = 51

  # ── Paleta ───────────────────────────────────────────────────────────────────
  def self.p
    @pastel ||= Pastel.new
  end

  # Estilos semânticos — use estes em vez de cores diretas
  def self.primario(txt)   = p.bold.white(txt)
  def self.secundario(txt) = p.bright_black(txt)
  def self.destaque(txt)   = p.bold.cyan(txt)
  def self.valor_pos(txt)  = p.bold.green(txt)
  def self.valor_neg(txt)  = p.bold.red(txt)
  def self.alerta(txt)     = p.bold.yellow(txt)

  # ── Layout ───────────────────────────────────────────────────────────────────
  def self.margem
    cols = (IO.console&.winsize&.[](1)) || 80
    " " * [((cols - LARGURA_UI) / 2), 0].max
  end

  def self.limpar = system("clear") || system("cls")

  # Linha horizontal fina
  def self.linha_fina(cor: :bright_black)
    m = margem
    puts m + p.decorate("─" * LARGURA_UI, cor)
  end

  # Linha horizontal dupla (uso em headers de seção)
  def self.linha_dupla
    m = margem
    puts m + p.bold.cyan("═" * LARGURA_UI)
  end

  # ── Blocos de UI ─────────────────────────────────────────────────────────────

  # Cabeçalho premium: logo + nome do banco + subtítulo opcional
  def self.cabecalho(pastel = p, subtitulo = nil)
    limpar
    m = margem
    puts

    # Logo em 3 linhas com nome do banco na lateral (linha do meio)
    logo_linhas = LOGO.lines.map(&:chomp)
    meio = logo_linhas.size / 2

    logo_linhas.each_with_index do |linha, i|
      sufixo = i == meio ? "  #{p.bold.white(NOME_BANCO)}" : ""
      puts m + p.bold.cyan(linha) + sufixo
    end

    puts m + p.bright_black(VERSAO.rjust(LARGURA_UI))
    puts m + p.cyan("═" * LARGURA_UI)
    puts m + p.bold.yellow(subtitulo.center(LARGURA_UI)) if subtitulo
    puts
  end

  # Título de seção com moldura leve
  def self.titulo_secao(texto)
    m = margem
    largura_interna = LARGURA_UI - 2
    puts m + p.yellow("┌" + "─" * largura_interna + "┐")
    puts m + p.yellow("│") + p.bold.white(texto.center(largura_interna)) + p.yellow("│")
    puts m + p.yellow("└" + "─" * largura_interna + "┘")
    puts
  end

  # Label de sub-seção (ex: "TITULAR", "CONTA")
  def self.label_secao(texto)
    m = margem
    puts m + p.bold.cyan("▸ ") + p.bold.bright_black(texto)
    puts m + p.bright_black("─" * LARGURA_UI)
  end

  # Campo chave → valor alinhados
  def self.campo(label, valor, largura_label: 14)
    m = margem
    rotulo = p.bright_black("%-#{largura_label}s" % label)
    puts "#{m}  #{rotulo}#{valor}"
  end

  # Mensagens de feedback
  def self.sucesso(pastel = p, msg)
    puts
    puts margem + p.bold.green("  ✔  ") + p.green(msg)
  end

  def self.erro(pastel = p, msg)
    puts
    puts margem + p.bold.red("  ✖  ") + p.red(msg)
  end

  def self.info(msg)
    puts margem + p.bold.cyan("  ℹ  ") + p.cyan(msg)
  end

  # Badge colorido inline (ex: tipo de conta)
  def self.badge(texto, cor: :cyan)
    p.decorate(" #{texto} ", cor, :bold)
  end

  # Separador vazio (respiro)
  def self.espaco(n = 1) = n.times { puts }
end