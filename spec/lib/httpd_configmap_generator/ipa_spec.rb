require "httpd_configmap_generator/ipa"
require "httpd_configmap_generator/base/config_map"

describe HttpdConfigmapGenerator::Ipa do
  describe "#configure" do
    describe "#get_canonical_hostname" do
      before do
        @ipa = described_class.new()
        allow(@ipa).to receive(:update_hostname)
        allow(@ipa).to receive(:realm)
        allow(@ipa).to receive(:domain)
        allow(@ipa).to receive(:command_run!)
        allow(@ipa).to receive(:configure_ipa_http_service)
        allow(@ipa).to receive(:configure_pam)
        allow(@ipa).to receive(:configure_sssd)
        allow(@ipa).to receive(:enable_kerberos_dns_lookups)
        allow(HttpdConfigmapGenerator::ConfigMap).to receive(:new).and_return(double(:generate => nil, :save => nil))
      end

      it "returns the canonical hostname when found" do
        @initial_opts = {:host => "host-alias"}
        expect(Socket).to receive(:gethostbyname).with("host-alias").and_return(["canonical-host"])
        @ipa.configure(@initial_opts)
        expect(@initial_opts[:host]).to eq("canonical-host")
      end

      it "returns the input hostname when it is the canonical hostname" do
        @initial_opts = {:host => "canonical-host"}
        expect(Socket).to receive(:gethostbyname).with("canonical-host").and_return(["canonical-host"])
        @ipa.configure(@initial_opts)
        expect(@initial_opts[:host]).to eq("canonical-host")
      end

      it "returns the input hostname when hostname is not found" do
        @initial_opts = {:host => "host-name"}
        expect(Socket).to receive(:gethostbyname).and_raise(SocketError)
        @ipa.configure(@initial_opts)
        expect(@initial_opts[:host]).to eq("host-name")
      end
    end
  end
end
