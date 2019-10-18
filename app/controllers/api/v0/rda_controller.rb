# frozen_string_literal: true

class Api::V0::RdaController < Api::V0::BaseController

  before_action :authenticate

  def export_dmp
    @plan = Plan.find(params[:id])
    @plan_info = {}
    @plan_info[:ethical_issues] = "unknown"
    @plan_info[:language] = @plan.owner.language || Language.default
    @plan_info[:language] = @plan_info[:language].abbreviation
    @plan_info[:contact] = {}
    @plan_info[:contact][:name] = @plan.owner.name
    @plan_info[:contact][:mail] = @plan.owner.email
    @plan_info[:contact][:id_type] = "HTTP-ORCID"
    @plan_info[:contact][:id] = "http://orcid.org/0000-0000-0000-0000"
    @plan_info[:staff] = []
    @plan_info[:staff] = @plan.roles.editor.not_creator.map(&:user)
    @plan_info[:dataset] = {}
    data_desc = Theme.find_by(title: "Data description")
    @plan_info[:dataset][:desc] = @plan.answers.select { |a| a.question.themes.pluck(:id).include?(data_desc.id)}.map(&:text) || ""
  end

end
