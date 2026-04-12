require 'socket'

class Connection
  def initialize(host: 'localhost', port: 7896)
    @socket = TCPSocket.new(host, port)
  end

  def stream = @socket

  def close = @socket.close
end