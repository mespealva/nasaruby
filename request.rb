require 'uri'
require 'net/http'
require 'json'
require 'openssl'

def request(url_address, api_key)
    url=URI("#{url_address}&api_key=#{api_key}")
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
        image.push("<li><img src='#{img['img_src']}'></li>")
    end
    head = "<!doctype html>
    <html lang='en'>
    <head>
        <title>Nasa</title>
        <!-- Required meta tags -->
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>

        <!-- Bootstrap CSS -->
        <link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css' integrity='sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T' crossorigin='anonymous'>
    </head>
    <body>
        <h1 class='text-center'>Fotos de Curiosity</h1>
        <ul>
        "
    foot = "
            </ul>
            <script src='https://code.jquery.com/jquery-3.3.1.slim.min.js' integrity='sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo' crossorigin='anonymous'></script>
            <script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js' integrity='sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1' crossorigin='anonymous'></script>
            <script src='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js' integrity='sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM' crossorigin='anonymous'></script>
          </body>
        </html>"
    index = "#{head} #{image.join("\n")} #{foot}"

    File.write('index.html', index)
end

def photo_count(hash)
    contador = []
    hash["photos"].map!{|photo| [photo["camera"]]}
    hash["photos"].each do |data|
        data.each do |cam|
            cam.each do |k,v|
                contador << v if k == "name"
            end
        end
    end
    camaras = contador.group_by {|x| x}
    camaras.each do |k,v|
        camaras[k] = v.count
    end
    return camaras
end

api_key = "WrWVobuPJjr2yotBA5TwRGroR0Uh0dynRgCAaZKz"
nasa = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1000"

data = request(nasa, api_key)
build_page(data)
print photo_count(data)
puts