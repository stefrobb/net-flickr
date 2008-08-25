module CommonThread
  module XML
    # Credit to Jim Weirich at http://onestepback.org/index.cgi/Tech/Ruby/BlankSlate.rdoc
    class BlankSlate
      instance_methods.each {|m| undef_method m unless m =~ /^__/ }
    end    
    
    # Class that makes accessing xml objects more like any other ruby object
    # thanks to the magic of method missing
    class XmlMagicLibXML < BlankSlate
      
      def initialize(xml, namespace="")
        if xml.class == LibXML::XML::Node or xml.class == Array
          @element = xml
        else
          @xml = LibXML::XML::Parser.string(xml).parse
          @element = @xml.root
        end
        @namespace = namespace
      end

      def each
        @element.each {|e| yield CommonThread::XML::XmlMagicLibXML.new(e, @namespace)}
      end

      def method_missing(method, selection=nil)
        evaluate(method.to_s, selection)
      end

      def namespace=(namespace)
        if namespace and namespace.length > 0
          @namespace = namespace + ":"
        else
          @namespace = ""
        end
      end
      
      def to_s
        if @element.class == Array
          @element.collect{|e| e.content}.join
        else
          @element.content
        end
      end

      def [](index, count = nil)
        if index.is_a?(Fixnum) or index.is_a?(Bignum) or index.is_a?(Integer) or index.is_a?(Range) 
          if @element.is_a?(Array)
            if count
              CommonThread::XML::XmlMagicLibXML.new(@element[index, count], @namespace)
            else
              CommonThread::XML::XmlMagicLibXML.new(@element[index], @namespace)
            end
          else
            nil
          end
        elsif index.is_a?(Symbol)
          if @element.is_a?(Array)
            if @element.empty?
              nil
            else
              @element[0].attributes[index.to_s]
            end
          else
            @element.attributes[index.to_s]
          end
        end
      end

      private
      def evaluate(name, selection)
        # This may be a nasty hack, might be worth revisiting
        begin 
          if @element.is_a?(Array)
            elements = @element[0].find(@namespace + name).to_a
          else
            elements = @element.find(@namespace + name).to_a
          end
        rescue => e
          elements = []
        end
        
        if elements.empty?
          nil
        else
          if selection == :count
            elements.length
          else
            CommonThread::XML::XmlMagicLibXML.new(elements, @namespace)
          end
        end
      end
    end
  end
end
