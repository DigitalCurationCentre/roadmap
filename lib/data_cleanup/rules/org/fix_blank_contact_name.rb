module DataCleanup
  module Rules
    module Org
      class FixBlankContactName < Rules::Base

        def description
          "Fix blank contact name on Org"
        end

        def call
          contactless = ::Org.where(contact_name: [nil, ""], feedback_enabled: true)
          contactless.update_all(contact_name: "RDM Info")
        end
      end
    end
  end
end
