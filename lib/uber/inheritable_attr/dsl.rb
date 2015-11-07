module Uber::InheritableAttr::DSL
  include Uber::InheritableAttr

  def inheritable_attr(name, options={})
    super
    instance_eval %Q{
      def #{name}(value = :__undefined)
        return self.#{name} = value if value != :__undefined
        return @#{name} if instance_variable_defined?(:@#{name})
        @#{name} = InheritableAttribute.inherit_for(self, :#{name}, #{options})
      end
    }
  end
end
