require 'socket'
require 'ipaddr'
require_relative 'session'

class NotificacaoListener
  MULTICAST_ADDR = "239.0.0.1"
  PORT = 12347

  def start
    Thread.new do
      socket = UDPSocket.new
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      socket.bind("0.0.0.0", PORT)

      membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new("0.0.0.0").hton
      socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, membership)

      loop do
        data, _ = socket.recvfrom(1024)
        mensagem = data.force_encoding("UTF-8")
        next unless Session.logado?

        Session.add_notificacao(mensagem)
        # Aciona o callback de UI se houver um registrado
        Session.notificacao_callback&.call(mensagem)
      end
    end
  end
end