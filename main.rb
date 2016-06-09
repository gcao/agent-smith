require 'stomp'
require 'json'
require 'securerandom'

ENV["STOMP_SERVER"]   ||= "subscribe-vm-06.dloco.s.vonagenetworks.net"
ENV["STOMP_PORT"]     ||= "61613"
ENV["STOMP_USERNAME"] ||= "admin"
ENV["STOMP_PASSWORD"] ||= "admin"

ABOUT_ME = {
  name: "Agent Smith",
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

client = Stomp::Client.new("stomp://#{ENV["STOMP_USERNAME"]}:#{ENV["STOMP_PASSWORD"]}@#{ENV["STOMP_SERVER"]}:#{ENV["STOMP_PORT"]}")

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

