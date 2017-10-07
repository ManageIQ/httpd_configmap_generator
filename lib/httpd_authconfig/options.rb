module HttpdAuthConfig
  def self.required_options
    {
      :host => { :description => "Application Domain" }
    }
  end

  def self.optional_options
    {
      :force => { :description => "Force configuration if configured already", :default => false }
    }
  end
end
