require 'nokogiri'

module OpenscapParser
  # Represents a generic Xml node with parsed_xml
  class XmlNode
    attr_reader :namespaces

    # 節點(node)的具體表現就是該節點的 "xml文件對象",通過這個實例對象把這個節點封裝起來。
    # 如果有現成的 node 的xml文件對象, 就直接用來創建節點實例; 若沒有,那傳入該節點的文本內容,通過 parsed_xml 方法創建出來。
    # 所以,承上述,用現成的 "xml文件對象" 和 用文本文件來產生 "xml文件對象",這兩種表示節點的作法是不同的(傳入參數也不同),要分開處理。
    def initialize(parsed_xml: nil)
      @parsed_xml = parsed_xml
    end

    # 用節點的文本內容來創建節點的文件對象, 
    # 這裏的節點文本,不見得由一個單一節點所展開的樹,也有可能是多個節點各別展開。
    # 反正,它就是一段xml文本,用該文本創建出來的"xml文件對象",可以用來做該xml文本中節點的查詢和操作。
    def parsed_xml(report_contents = '')
      return @parsed_xml if @parsed_xml # 這裏有問題,這裏的 @parsed_xml 可以是任意值,只要不是 nil 就好,但是,它沒有去驗證 @parsed_xml 的正確性。
      # Creating Nokogiri::XML::Document is the main entry point for dealing with XML documents. 
      # The Nokogiri Document is created by parsing an XML document with ::Nokogiri::XML.parse method .    
      # Nokogiri::XML()、Nokogiri.xml() 和 Nokogiri::XML.parse 此三者都是等價的。
      #
      # *** Nokogiri::XML::ParseOptions.new.norecover ***
      # 表示创建一个新的解析选项对象，将其配置为在解析时不进行恢复，即在遇到错误时立即停止解析，不尝试修复错误。
      # 这对于在解析不规范的 XML 或包含错误的 XML 文档时是有用的，因为它允许解析器尽早停止，以避免在错误的输入上浪费时间。
      @parsed_xml = ::Nokogiri::XML.parse(report_contents, nil, nil, Nokogiri::XML::ParseOptions.new.norecover)       
      @namespaces = @parsed_xml.namespaces.clone  # 使用 clone 创建一个副本，确保 @namespaces 和 @parsed_xml.namespaces 是独立分開的，防止因为对其中一个对象的修改而影响另一个对象。
      # 从解析后的文档对象中移除命名空间，这是因为后续代码可能更容易处理不带命名空间的 XML 结构。      
      # remove_namespaces! 方法会修改调用者对象（在这里是 @parsed_xml),并且它是有返回值的,所以不必再多重複一行 @parsed_xml 做為返回值。
      # 通常，Ruby 中方法名末尾带有 ! 的表示该方法是“危险”的，它可能会直接修改调用者对象的状态。
      # 在这里，remove_namespaces! 方法的名字中的 ! 表示这个方法会直接修改调用者对象，而不是返回一个新的修改过的对象。
      @parsed_xml.remove_namespaces!  
      #======================================================================================================
      # 上述的代碼,等價於下面的代碼
      # @parsed_xml ||= begin
      #   xml = ::Nokogiri::XML.parse(report_contents, nil, nil, Nokogiri::XML::ParseOptions.new.norecover) 
      #   @namespaces ||= xml.namespaces.clone  
      #   xml.remove_namespaces!
      #   xml
      # end
      #======================================================================================================
    end

    def text
      @parsed_xml.text  # 返回 XML 节点的文本内容。
    end

    def xpath_node(xpath)
      # 如果 parsed_xml = nil, nil.at_xpath(xpath) 會出錯。
      # 可以寫成 parsed_xml&.at_xpath(xpath)  
      parsed_xml && parsed_xml.at_xpath(xpath)  # 查询并返回滿足匹配的第一个节点的方法。
    end
    alias :at_xpath :xpath_node  # 将 at_xpath 作为 xpath_node 的别名。

    def xpath_nodes(xpath)
      parsed_xml && parsed_xml.xpath(xpath) || []
    end
    alias :xpath :xpath_nodes
  end
end