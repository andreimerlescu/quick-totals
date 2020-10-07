module QuickTotals::Sync
  def self.included base
    base.extend ClassMethods

    after_initialize :validate_concern
    after_save :update_quick_totals
  end #/def

  module ClassMethods
    def update_quick_totals
      klass_str = self.qt_get_klass_name
      

    end #/def

    # @name Get Klass Name
    # @desc Formats class name for concern usage
    def qt_get_klass_name
      n = underscore(self.class.name.to_s) if defined?(underscore)
      n, em = self.qt_underscore(self.class.name.to_s)
      raise StandardError, "QuickTotals::Sync concern cannot underscore(#{self.class.name.to_s}): #{em}" if n.nil?
    end #/def

    # @name Validate Concern
    # @desc Must define method within all Models that include this concern called :qt_relationships that returns an Array of camel_case strings (no spaces allowed)
    # @raises NoMethodError
    # @raises ArgumentError
    # @raises SyntaxError
    def validate_concern
      raise NoMethodError, "missing :qt_relationships method that returns an array of camel_case strings" unless defined?(self.qt_relationships)
      qt_relationships = self.qt_relationships
      raise ArgumentError, ":qt_relationships must return type Array" unless qt_relationships.instance_of?(Array)
      qt_relationships&.each do |qtr|
        raise SyntaxError, ":qt_relationships Array must only contain camel_case strings (no spaces allowed)" if qtr.match(/\s/)
      end #/each
    end #/def

    # @name QT Underscore
    # @desc Converts CamelCase to "camel_case"
    # @return tuple (string, nil) = success
    # @return tuple (nil, string) = failure
    # @rescue returns nil
    def qt_underscore(str)
      str.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase, nil
    rescue Exception => e
      nil, e&.message
    end #/def
  end #/module
end #/module