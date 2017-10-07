describe HttpdAuthConfig do
  describe "implementation" do
    it "declares a version number" do
      expect(HttpdAuthConfig::VERSION).not_to be nil
    end
  end
end
