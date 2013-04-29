require "bunny"

# Start a communication session with RabbitMQ
conn = Bunny.new
conn.start

# open a channel
ch = conn.create_channel

x = Bunny::Exchange.new(ch, :tagged, "test", :auto_delete => true)


q = ch.queue("dummy", :auto_delete => true).bind(x, :arguments => {:tags => "wind_pred,op"})
q.subscribe do |delivery_info, properties, payload|
  p delivery_info, properties, payload
end

# publish a message to the exchange which then gets routed to the queue
x.publish("this should arrive1", :headers => {:tags => "wind_pred"})
x.publish("this should arrive2", :headers => {:tags => "op"})
x.publish("this should arrive3", :headers => {:tags => "wind_pred,op"})

x.publish("this should not arrive1", :headers => {:tags => "wind_pred,op,extra"})
x.publish("this should not arrive2", :headers => {:tags => "whatever,op"})

5.times do
  q.pop
end

conn.stop
