require "httpd_configmap_generator/export"

describe HttpdConfigmapGenerator::Export do
  describe "#requied_options" do
    before do
      @export = described_class.new()
    end

    it "returns the correct required options" do
      required_options = @export.required_options
      expect(required_options.keys.count).to eq(3)
      expect(required_options.has_key?(:input)).to be_truthy
      expect(required_options.has_key?(:output)).to be_truthy
      expect(required_options.has_key?(:file)).to be_truthy
      expect(required_options.has_key?(:host)).to be_falsy
    end
  end
end
