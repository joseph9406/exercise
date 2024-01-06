require 'plugin_aaa/version'

module Plugin_aaa
  class Plugin < ::Proxy::Plugin
    # General smart proxy configuration parameters:
    plugin(:aaa, Plugin_aaa::VERSION)

    uses_provider

    # static capability
    capability :TYPE_A
    capability :TYPE_AAAA
    capability :TYPE_CNAME
    # dyanamic capability can return a single symbol/string or an array
    #capability(proc{ "FOO" + "BAR" }) #a single capability 'FOOBAR'
    #capability(lambda{ ["FOO", "BAR" ] }) #two capabilities 'FOO' and 'Bar'

    expose_setting :expose1
    expose_setting :expose2

    load_classes ::Proxy::Aaa::ConfigurationLoader
    load_programmable_settings ::Proxy::Aaa::ConfigurationLoader
    #load_dependency_injection_wirings ::Proxy::Aaa::PluginConfiguration

    # __FILE__ 表示当前脚本文件的路径。这个路径是相对于执行时的当前工作目录的。
    # 若當前文件路徑為 "/aaa/bbb/ccc/myfile", File.expand_path("../", __FILE__) 結果為 '/aaa/bbb/ccc"
    # File.expand_path("http_config.ru", File.expand_path("../", __FILE__)) 結果為 '/aaa/bbb/ccc/http_config.ru'
    http_rackup_path  File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
    https_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))

    default_settings :spooldir => '/var/spool/foreman-proxy/openscap',
                     :openscap_send_log_file => File.join(APP_ROOT, 'logs/openscap-send.log'),
                     :contentdir => File.join(APP_ROOT, 'openscap/content'),
                     :reportsdir => File.join(APP_ROOT, 'openscap/reports'),
                     :failed_dir => File.join(APP_ROOT, 'openscap/failed'),
                     :tailoring_dir => File.join(APP_ROOT, 'openscap/tailoring'),
                     :oval_content_dir => File.join(APP_ROOT, 'openscap/oval_content')

    #requires :plugin_bbb, ::Proxy::VERSION
    
    #start_services :service_a, :service_b
  end
end
