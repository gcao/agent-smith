require 'bunny'
require 'json'

SERVER   = ENV['AMQP_SERVER']   || 'localhost'
USERNAME = ENV['AMQP_USERNAME'] || 'guest'
PASSWORD = ENV['AMQP_PASSWORD'] || 'guest'

conn = Bunny.new "amqp://#{USERNAME}:#{PASSWORD}@#{SERVER}"
conn.start

puts "Connected to #{SERVER} as #{USERNAME}"

ch = conn.create_channel

ch.queue("requests", durable: true).subscribe do |delivery_info, metadata, payload|
  parsed = JSON.parse payload

  if parsed["message"] =~ /check disk space/i
    puts "=" * 80
    puts "Check disk space request is received"
    resp = ch.queue("tasks", durable: true)
    message = {
      #id: uuid.v4() #TODO: generate a uuid for each task
      #source: {
        reply_to: parsed["reply_to"],
        room: parsed["room"],
      #},
      type: 'check-disk-space',
      server: 'TODO',
    }
    resp.publish(message.to_json, routing_key: 'tasks')
  end
end

ch.queue("tasks", durable: true).subscribe do |delivery_info, metadata, payload|
  puts payload

  parsed = JSON.parse payload

  resp = ch.queue("responses", durable: true)
  message = {
    content: `df`,
    reply_to: parsed["reply_to"],
    room: parsed["room"]
  }
  resp.publish(message.to_json, routing_key: 'responses')
end

sleep 1 while true

