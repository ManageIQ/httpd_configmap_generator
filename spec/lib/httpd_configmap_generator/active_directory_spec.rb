require "httpd_configmap_generator/active_directory"

describe HttpdConfigmapGenerator::ActiveDirectory do
  describe "#requied_options" do
    before do
      @ad = described_class.new()
    end

    it "returns the correct required options" do
      required_options = @ad.required_options
      expect(required_options.keys.count).to eq(5)
      expect(required_options.has_key?(:output)).to be_truthy
      expect(required_options.has_key?(:host)).to be_truthy
      expect(required_options.has_key?(:ad_domain)).to be_truthy
      expect(required_options.has_key?(:ad_user)).to be_truthy
      expect(required_options.has_key?(:ad_password)).to be_truthy
    end
  end
end
