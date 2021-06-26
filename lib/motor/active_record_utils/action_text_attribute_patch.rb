# frozen_string_literal: true

if defined?(ActionText::Attribute)
  ActionText::Attribute::ClassMethods.prepend(Module.new do
    # rubocop:disable Naming/PredicateName
    def has_rich_text(*args)
      super

      name = args.first

      alias_method :"#{name}_body=", :"#{name}="

      define_method(:"#{name}_body") do
        send(name).body&.to_trix_html
      end
    end
    # rubocop:enable Naming/PredicateName
  end)
end
