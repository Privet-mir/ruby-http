require 'socket'

server = TCPServer.new('0.0.0.0', 8000)

loop do
  client = server.accept
  request = client.readpartial(2048)

  method, path, version = request.lines[0].split

  puts "#{method} #{path} #{version}"

  if path == "/healthcheck"
    response = "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: 2\r\n" +
               "\r\n" +
               "OK"
  else
    response = "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: 15\r\n" +
               "\r\n" +
               "Well, hello there!"
  end

  # Send the HTTP/1.1 response
  client.write(response)

  client.close
end

