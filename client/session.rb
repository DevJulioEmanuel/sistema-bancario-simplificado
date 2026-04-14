module Session
  @logado        = false
  @notificacoes  = []
  @callback      = nil
  @mutex         = Mutex.new

  def self.logado?      = @logado
  def self.login        = (@logado = true)
  def self.logout       = (@logado = false; @callback = nil)

  def self.notificacao_callback=(blk)
    @callback = blk
  end
  def self.notificacao_callback      
    @callback
  end

  def self.add_notificacao(msg)
    @mutex.synchronize { @notificacoes << msg }
  end

  def self.pegar_notificacoes
    @mutex.synchronize do
      msgs = @notificacoes.dup
      @notificacoes.clear
      msgs
    end
  end
end