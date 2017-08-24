describe Httpd::AuthConfig do
  describe "implementation" do
    it "declares a version number" do
      expect(Httpd::AuthConfig::VERSION).not_to be nil
    end
  end
end
