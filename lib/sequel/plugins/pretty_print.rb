module Sequel::Plugins::PrettyPrint
  module InstanceMethods
    # Modeled after the implementation within ActiveRecord
    def pretty_print(pp)
      return super if method(:inspect).owner != Sequel::Model.instance_method(:inspect).owner

      pp.object_address_group(self) do
        keys = self.class.columns.select { |name| @values.key?(name) || new? }
        keys = (keys + @values.keys).uniq

        pp.seplist(keys, proc { pp.text(",") }) do |key|
          pp.breakable " "

          pp.group(1) do
            pp.text key.to_s
            pp.text ":"
            pp.breakable
            pp.pp self[key]
          end
        end
      end
    end
  end
end
