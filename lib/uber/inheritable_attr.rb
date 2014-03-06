module Uber
  module InheritableAttr
    def inheritable_attr(name)
      instance_eval %Q{
        def #{name}=(v)
          @#{name} = v
        end

        def #{name}
          @#{name} ||= InheritableAttribute.inherit_for(self, :#{name})
        end
      }
    end

    def self.inherit_for(klass, name)
      return unless klass.superclass.respond_to?(name) and value = klass.superclass.send(name)
      value.clone # only do this once.
    end
  end

  InheritableAttribute = InheritableAttr
end
