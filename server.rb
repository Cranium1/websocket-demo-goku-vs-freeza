require 'em-websocket'

class Client
  @@clients = []
  def initialize(ws)
    @@clients << self
    @ws = ws
  end
  def self.all_offspring
    @@clients
  end

  def send_energy(goku)
    goku.increase_power_level
    @ws.send("Energy received!")
  end

  def remove_from_list
    @@clients.delete(self)
  end
end

class Goku
  def initialize
    @power_level = 0
  end

  def increase_power_level
    @power_level += 10
  end

  def current_energy
    @power_level
  end

  def reduce_energy
    @power_level -= 100 if @power_level > 100
  end
end

goku = Goku.new

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    client = Client.new(ws)

    ws.onopen { |handshake|
    }

    ws.onclose {
      client.remove_from_list
    }

    ws.onmessage { |msg|
      client.send_energy(goku)
    }

  end

  EventMachine.add_periodic_timer(1) {
    system "clear"
    puts "Current energy: #{goku.current_energy}"
    puts "Current users: #{Client.all_offspring.count}"
    puts "Progress"
    if goku.current_energy > 9000
      puts "ITS OVER 9000!"
      puts "WE BEAT FREEZA"
      EM.stop
    else
      puts "["+"="*(goku.current_energy/900)+" "*((9000-goku.current_energy)/900)+"]"
      goku.reduce_energy
    end
  }
}