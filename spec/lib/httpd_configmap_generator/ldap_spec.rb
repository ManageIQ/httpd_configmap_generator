require "httpd_configmap_generator/ldap"

describe HttpdConfigmapGenerator::Ldap do
  describe "#requied_options" do
    before do
      @ldap = described_class.new()
    end

    it "returns the correct required options" do
      required_options = @ldap.required_options
      expect(required_options.keys.count).to eq(6)
      expect(required_options.has_key?(:output)).to be_truthy
      expect(required_options.has_key?(:host)).to be_truthy
      expect(required_options.has_key?(:cert_file)).to be_truthy
      expect(required_options.has_key?(:ldap_host)).to be_truthy
      expect(required_options.has_key?(:ldap_mode)).to be_truthy
      expect(required_options.has_key?(:ldap_basedn)).to be_truthy
    end
  end
end
