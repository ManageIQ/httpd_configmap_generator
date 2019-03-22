describe "bin/httpd_configmap_generator" do
  describe "--help" do
    it "displays the expected info about the command" do
      binfile   = File.expand_path("../../bin/httpd_configmap_generator", __dir__)
      version   = HttpdConfigmapGenerator::VERSION
      help_text = <<-HELP.gsub(/^ {8}/, "")
        httpd_configmap_generator #{version} - External Authentication Configuration script

        Usage: httpd_configmap_generator auth_type | update | export [--help | options]

        supported auth_type: active-directory, ipa, ldap, oidc, saml

        httpd_configmap_generator options are:
          -V, --version    Version of the httpd_configmap_generator command
          -h, --help       Show this message
      HELP

      expect(`#{binfile} --help`).to eq(help_text)
    end
  end
end
