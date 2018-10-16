module DataCleanup
  module Rules
    module Org
      class FixGenericBlankAbbreviation < Rules::Base

        def description
          "Fix blank abbreviation on Org Generically (Take Caps)"
        end

        def call
          invalids = ::Org.where(abbreviation: [nil, ""])
          invalids.each do |invalid|
            invalid.update(abbreviation: extract_upper_case_letters(invalid.name))
          end
        end

        private

        def extract_upper_case_letters(str)
          str.scan(/\p{Upper}/u).join("")
        end
      end
    end
  end
end
