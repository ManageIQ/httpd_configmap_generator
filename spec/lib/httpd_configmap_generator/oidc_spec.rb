require "httpd_configmap_generator/oidc"

describe HttpdConfigmapGenerator::Oidc do
  describe "#requied_options" do
    before do
      @oidc = described_class.new()
    end

    it "returns the correct required options" do
      required_options = @oidc.required_options
      expect(required_options.keys.count).to eq(4)
      expect(required_options.has_key?(:output)).to be_truthy
      expect(required_options.has_key?(:host)).to be_falsy
      expect(required_options.has_key?(:oidc_url)).to be_truthy
      expect(required_options.has_key?(:oidc_client_id)).to be_truthy
      expect(required_options.has_key?(:oidc_client_secret)).to be_truthy
    end
  end
end
