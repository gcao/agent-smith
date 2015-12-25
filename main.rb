require 'bunny'
require 'json'

SERVER   = ENV['AMQP_SERVER']   || 'localhost'
USERNAME = ENV['AMQP_USERNAME'] || 'guest'
PASSWORD = ENV['AMQP_PASSWORD'] || 'guest'

conn = Bunny.new "amqp://#{USERNAME}:#{PASSWORD}@#{SERVER}"
conn.start

puts "Connected to #{SERVER} as #{USERNAME}"

ch = conn.create_channel
#x  = ch.topic("tasks", auto_delete: true)

#ch.queue("tasks", durable: true).bind(x).subscribe do |delivery_info, metadata, payload|
ch.queue("tasks", durable: true).subscribe do |delivery_info, metadata, payload|
  puts payload

  parsed = JSON.parse payload

  resp = ch.queue("responses", durable: true)
  message = {
    content: `df`,
    user: parsed["user"],
    room: parsed["room"]
  }
  resp.publish(message.to_json, routing_key: 'responses')
end

sleep 1 while true

