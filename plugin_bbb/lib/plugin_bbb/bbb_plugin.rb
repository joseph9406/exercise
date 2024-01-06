
module Plugin_bbb
  class Plugin < ::Proxy::Plugin
    # General smart proxy configuration parameters:
    plugin :bbb, Plugin_bbb::VERSION

    # __FILE__ 表示當前文件的路徑
    # 若當前文件路徑為 "/aaa/bbb/ccc/myfile", File.expand_path("../", __FILE__) 結果為 '/aaa/bbb/ccc"
    # File.expand_path("http_config.ru", File.expand_path("../", __FILE__)) 結果為 '/aaa/bbb/ccc/http_config.ru'
    http_rackup_path  File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
    https_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))

  end
end
