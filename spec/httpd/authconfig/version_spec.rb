describe HttpdConfigmapGenerator do
  describe "implementation" do
    it "declares a version number" do
      expect(HttpdConfigmapGenerator::VERSION).not_to be nil
    end
  end
end
