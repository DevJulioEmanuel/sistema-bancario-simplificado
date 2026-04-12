module UI
  BANNER = <<~BANNER
    ██████╗  █████╗ ███╗   ██╗ ██████╗ ██████╗ 
    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██╔═══██╗
    ██████╔╝███████║██╔██╗ ██║██║     ██║   ██║
    ██╔══██╗██╔══██║██║╚██╗██║██║     ██║   ██║
    ██████╔╝██║  ██║██║ ╚████║╚██████╗╚██████╔╝
    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ 
  BANNER

  def self.limpar
    system('clear') || system('cls')
  end

  def self.cabecalho(pastel, subtitulo = nil)
    limpar
    puts pastel.cyan(BANNER)
    puts pastel.bright_black("  Sistema Bancário Distribuído  •  v1.0")
    puts pastel.bright_black("  " + "─" * 43)
    puts pastel.yellow("  #{subtitulo}") if subtitulo
    puts
  end

  def self.divisor(pastel)
    puts pastel.bright_black("  " + "─" * 43)
  end

  def self.sucesso(pastel, msg)
    puts pastel.green("  ✔  #{msg}")
  end

  def self.erro(pastel, msg)
    puts pastel.red("  ✖  #{msg}")
  end
end