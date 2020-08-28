require 'uri'
require 'net/http'
require 'json'
require 'openssl'

def request(url_address, api_key)
    url=URI("#{url_address}+&api_key=#{api_key}")
    http = Net::HTTP.new(url.host, url.port)
    request  = Net::HTTP::Get.new(url)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    respond = http.request(request)
    if respond.code.to_i>=400
        puts "not found"
    else
        return JSON.parse(respond.read_body)
    end
end

def build_page(hash)
    image = []
    hash ['photos'].each do |img|
        image.push("\t<li><img src='#{img['img_src']}'></li>")
    end
    head = "<html>
    <head>
        <title>Nasa</title>
    </head>
        <body>"
    foot = "\n</ul>\n</body>\n</html>"
    pag = "#{head} #{image.join("\n")} #{foot}"

    File.write('index.html', pag)
end

api_key = "WrWVobuPJjr2yotBA5TwRGroR0Uh0dynRgCAaZKz"
nasa = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1000"

data = request(nasa, api_key)
build_page(data)