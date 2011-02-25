require "activerecord"

module ActiveRecord
  module Serialization
    class Serializer
      def serializable_attribute_names_with_serializable_data
        attribute_names = serializable_attribute_names_without_serializable_data
        if @record.class.include?(SerializableData)
          attribute_names.delete(@record.class._data_column.to_s)
          only = Array.wrap(options[:only]).map(&:to_s)
          except = Array.wrap(options[:except]).map(&:to_s)
          serialized_data_attributes = @record.class._data_attributes.map(&:to_s)
          attribute_names |= if only.any?
                               serialized_data_attributes & only
                             elsif except.any?
                               serialized_data_attributes - except
                             end
        end
        attribute_names
      end
      alias_method :serializable_attribute_names_without_serializable_data, :serializable_attribute_names
      alias_method :serializable_attribute_names, :serializable_attribute_names_with_serializable_data
    end
  end
end

module SerializableData

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      class_inheritable_accessor :_data_attributes
      class_inheritable_accessor :_data_column
      alias_method_chain :initialize, :serialized_data
    end
  end

  def initialize_with_serialized_data(attrs = {})
    attrs ||= {}
    serialized_attrs = {}
    super_attrs = {}
    attrs.each_pair do |key, value|
      if self.class._data_attributes.include?(key.to_sym)
        serialized_attrs[key] = value
      else
        super_attrs[key] = value
      end
    end
    initialize_without_serialized_data(super_attrs)
    self.send("#{self.class._data_column}=", {})
    serialized_attrs.each_pair do |key, value|
      self.send("#{key}=", value)
    end
  end

  # This should work in rails 3
  #def serializable_hash(options = nil)
  #  options ||= {}
  #  options[:except] ||= []
  #  options[:except] << self.class._data_column
  #  super(options).merge(get_serialized_data(options))
  #end

  private

  def get_serialized_data(options = {})
    attribute_names = self.class._data_attributes.map(&:to_s)
    if options[:only].any?
      attribute_names &= options[:only]
    elsif options[:except].any?
      attribute_names -= options[:except]
    end
    Hash[attribute_names.map { |key| [key, send(key)] }]
  end

  module ClassMethods

    def serialized_data(data_column, attributes)
      serialize data_column
      self._data_column = data_column
      self._data_attributes = []
      attributes.each do |name, type|
        self._data_attributes << name
        # setter
        define_method("#{name}=") do |value|
          current_value = self.send(data_column)
          value = self.class.to_bool(value) if type == :boolean
          new_value = current_value.merge(name => value)
          self.send("#{data_column}=", new_value)
        end
        # getters
        if type == :array
          define_method(name) {
            data = self.send(data_column)
            data && data[name] || []
          }
        else
          define_method(name) {
            data = self.send(data_column)
            data ? data[name] : nil
          }
        end
        alias_method("#{name}?", name) if type == :boolean
      end
    end

    def to_bool value
      return false if [0, "0", "false", false, nil].include?(value)
      true if [1, "1", "true", true].include?(value)
    end

  end

end
