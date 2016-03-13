#require 'bunny'
require 'stomp'
require 'json'
require 'securerandom'

ABOUT_ME = {
  name: "Mr. Smith",
  version: "0.1.0",
  description: "",
  host: `hostname`.strip,
  runningSince: Time.now,
}

WHAT_CAN_I_DO = {
  requests: [
    { message: /check disk space/i.inspect }
  ],
  tasks: [
    { type: "check-disk-space" }
  ],
}

#SERVER   = ENV['AMQP_SERVER']   || 'localhost'
#USERNAME = ENV['AMQP_USERNAME'] || 'guest'
#PASSWORD = ENV['AMQP_PASSWORD'] || 'guest'

#conn = Bunny.new "amqp://#{USERNAME}:#{PASSWORD}@#{SERVER}"
#conn.start

#puts "Connected to #{SERVER} as #{USERNAME}"

#ch = conn.create_channel

##requests_x = ch.fanout("requests-x", durable: true)
#requests = ch.queue("requests", "auto-delete" => true, arguments: {'x-message-ttl' => 30000, 'x-dead-letter-exchange' => 'dead-requests-x'})
##requests.bind(requests_x)

#tasks_x = ch.headers("tasks-x", durable: true)
#tasks = ch.queue("tasks", "auto-delete" => true, arguments: {'x-message-ttl' => 60000, 'x-dead-letter-exchange' => 'dead-tasks-x'})
#tasks.bind(tasks_x)

##responses_x = ch.fanout("responses-x", durable: true)
#responses = ch.queue("responses", "auto-delete" => true, arguments: {'x-message-ttl' => 60000})
##responses.bind(responses_x)

#requests.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
#  parsed = JSON.parse payload

#  if parsed["message"] =~ /check disk space/i
#    puts "=" * 80
#    puts "Check disk space request is received"
#    message = {
#      id: SecureRandom.uuid,
#      source: parsed["source"],
#      type: 'check-disk-space',
#      server: 'TODO',
#    }
#    tasks_x.publish(message.to_json, routing_key: 'tasks')
#    ch.ack delivery_info.delivery_tag, false
#  else
#    puts "Rejected: #{parsed["message"]}"
#    ch.reject delivery_info.delivery_tag, true
#  end

#  puts "Done with the request"
#end

#tasks.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
#  puts payload
#  parsed = JSON.parse payload

#  if parsed["type"] == "check-disk-space"
#    message = {
#      source: parsed['source'],
#      content: `df`,
#    }
#    responses.publish(message.to_json, routing_key: 'responses')
#    ch.ack delivery_info.delivery_tag, false
#  else
#    puts "Rejected: #{parsed["type"]}"
#    ch.reject delivery_info.delivery_tag, true
#  end

#  puts "Done with the task"
#end

client = Stomp::Client.new("stomp://admin:admin@localhost:61613")

client.subscribe "/topic/requests" do |msg|
  begin
    parsed = JSON.parse msg.body

    if parsed["message"] =~ /check disk space/i
      puts "=" * 80
      puts "Check disk space request is received"
      message = {
        id: SecureRandom.uuid,
        source: parsed["source"],
        type: 'check-disk-space',
        server: 'TODO',
      }
      client.publish "/topic/tasks", message.to_json
    end
  rescue => e
    puts "Exception: #{$!}"
    puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
  end
end

client.subscribe "/topic/tasks" do |msg|
  begin
    parsed = JSON.parse msg.body

    if parsed["type"] == "check-disk-space"
      puts ">>> Got task: #{parsed["type"]}"
      message = {
        source: parsed['source'],
        content: `df`,
      }
      client.publish "/topic/responses", message.to_json
      puts ">>> Done with the task."
    end
  rescue => e
    puts "Exception: #{$!}"
    puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
  end
end

sleep 1 while true

