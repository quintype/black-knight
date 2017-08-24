module PostToSlack
  def self.post(message, opts = {})
    return unless message
    uri = URI(Rails.application.secrets[:slack_hook])
    params = {channel: opts[:channel] || "#deploy-#{Rails.application.secrets[:qt_environment]}",
              username: "#{opts[:user]} (Black Knight)",
              text: message,
              icon_emoji: opts[:icon] || ":wrench:"}.to_json
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.body = params
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(request) }
  end
end
