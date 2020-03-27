require 'httparty'

class SapBusinessOne
  def initialize
    @username = 'itpilot'
    @password = '1tp1l0t'
    @content_type = 'text/xml'
    @urlstring = 'https://bpa.netcos.de:4433/api/RunTask?'

    @header = set_headers
  end

  def create_customer(invoice)
    puts ">>>>>> Invoice Data"
    puts invoice

    task_hash = {taskid: 14}
    puts ">>>>>> url"
    puts url_to_hit(task_hash)

    begin
      @result = HTTParty.post(url_to_hit(task_hash),
          :body => invoice,
          :headers => @header
        )
      @result
    rescue => ex
      "error - " + ex.message
    end
  end

  def get_invoice(invoice_id)
    task_hash = {taskid: 3, InvoiceID: invoice_id}

    @result = HTTParty.get(url_to_hit(task_hash), 
        :headers => @header 
      )
    
    @result
  end

private

  def url_to_hit(task_hash)
    return @urlstring.to_s + hash_to_query(task_hash).to_s
  end

  def hash_to_query(hash)
    require 'uri'
    return URI.encode(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
  end

  def set_headers
    # @header = {'X-BPAUsernameBase64' => encode_string(@username), 'X-BPAPasswordBase64' => encode_string(@password), 'Content-Type' => @content_type}
  end

  def encode_string(string_to_encode)
    return Base64::encode64(string_to_encode)
  end

end