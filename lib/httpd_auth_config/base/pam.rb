module HttpdAuthConfig
  class Base
    def configure_pam
      cp_template(PAM_CONFIG, template_directory)
    end
  end
end
