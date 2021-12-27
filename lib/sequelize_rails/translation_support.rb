module SequelizeRails
  module TranslationSupport
    def i18n_scope
      :sequel
    end

    def lookup_ancestors
      # ActiveModel uses the name of ancestors. Exclude unnamed classes, like
      # those returned by Sequel::Model(...).
      super.reject { |x| x.name.nil? }
    end
  end
end
