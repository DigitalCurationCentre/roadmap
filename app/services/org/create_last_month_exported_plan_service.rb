# frozen_string_literal: true

#import statements fix Circular dependancy errors
import OrgDateRangeable
import StatExportedPlan
import StatExportedPlan::CreateOrUpdate
import Role
import User
import ExportedPlan

class Org

  class CreateLastMonthExportedPlanService

    class << self

      def call(org = nil)
        orgs = org.nil? ? Org.all : [org]

        Parallel.each(orgs, in_threads: 2) do |org|
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            StatExportedPlan::CreateOrUpdate.do(
              start_date: last[:start_date],
              end_date: last[:end_date],
              org: org
            )
          end
        end
      end

    end

  end

end
