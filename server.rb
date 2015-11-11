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
    @power_level += 1
  end

  def current_energy
    @power_level
  end

  def reduce_energy
    @power_level -= 1 if @power_level > 0
  end
end

goku = Goku.new

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    client = Client.new(ws)

    ws.onopen { |handshake|
      puts "Goku, someone is tranfering your their energy."

      ws.send "You are now connected to Goku."
    }

    ws.onclose {
      client.remove_from_list
    }

    ws.onmessage { |msg|
      client.send_energy(goku)
    }

  end

  EventMachine.add_periodic_timer(1) {
    puts "Current energy: #{goku.current_energy}"
    puts "Current users: #{Client.all_offspring.count}"
    if goku.current_energy > 200
      puts "WE BEAT FREEZA"
      EM.stop
    else
      goku.reduce_energy
    end
  }
}