require "httpd_configmap_generator/saml"

describe HttpdConfigmapGenerator::Saml do
  describe "#requied_options" do
    before do
      @saml = described_class.new()
    end

    it "returns the correct required options" do
      required_options = @saml.required_options
      expect(required_options.keys.count).to eq(2)
      expect(required_options.has_key?(:output)).to be_truthy
      expect(required_options.has_key?(:host)).to be_truthy
    end
  end
end
