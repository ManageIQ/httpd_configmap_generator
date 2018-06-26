require "httpd_configmap_generator/base"

describe HttpdConfigmapGenerator::Base do
  describe "#requied_options" do
    before do
      @base = described_class.new()
    end

    it "returns the correct required options" do
      required_options = @base.required_options
      expect(required_options).not_to be_nil
      expect(required_options.keys.count).to eq(1)
      expect(required_options.has_key?(:output)).to be_truthy
      expect(required_options.has_key?(:host)).to be_falsy
    end
  end
end
