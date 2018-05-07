class Paginable::TemplatesController < ApplicationController
  include Paginable
  include TemplateFilter
      
  # GET /paginable/templates/:page  (AJAX)
  # -----------------------------------------------------
  def index
    raise Pundit::NotAuthorizedError unless Paginable::TemplatePolicy.new(current_user).all?
    case params[:f]
    when 'published'
      templates = Template.latest_version.published
    when 'unpublished'
      templates = Template.latest_version.where(published: false)
    else
      templates = Template.latest_version
    end
    paginable_renderise partial: 'index', scope: templates, locals: { action: 'index' }
  end
  
  # GET /paginable/templates/organisational/:page  (AJAX)
  # -----------------------------------------------------
  def organisational
    raise Pundit::NotAuthorizedError unless Paginable::TemplatePolicy.new(current_user).funders?
    case params[:f]
    when 'published'
      templates = Template.latest_version_for_org(current_user.org.id).where(customization_of: nil).published
    when 'unpublished'
      templates = Template.latest_version_for_org(current_user.org.id).where(customization_of: nil).where(published: false)
    else
      templates = Template.latest_version_for_org(current_user.org.id).where(customization_of: nil)
    end
    paginable_renderise partial: 'organisational', scope: templates, locals: { action: 'index' }
  end
  
  # GET /paginable/templates/customisable/:page  (AJAX)
  # -----------------------------------------------------
  def customisable
    raise Pundit::NotAuthorizedError unless Paginable::TemplatePolicy.new(current_user).orgs?
    customizations = Template.latest_customized_version_for_org(current_user.org.id)
    case params[:f]
    when 'customised'
      templates = Template.latest_customizable.where(family_id: customizations.collect(&:customization_of))
    when 'not-customised'
      templates = Template.latest_customizable.where.not(family_id: customizations.collect(&:customization_of))
    else
      templates = Template.latest_customizable
    end
    paginable_renderise partial: 'customisable', scope: templates, locals: { action: 'index', customizations: customizations }
  end

  # GET /paginable/templates/publicly_visible/:page  (AJAX)
  # -----------------------------------------------------
  def publicly_visible
    templates = Template.live(Template.families(Org.funder.pluck(:id)).pluck(:family_id)).publicly_visible.pluck(:id) <<
    Template.where(is_default: true).unarchived.published.pluck(:id)
    paginable_renderise(
      partial: 'publicly_visible',
      scope: Template.includes(:org).where(id: templates.uniq.flatten).valid.published)
  end

  # GET /paginable/templates/:id/history/:page  (AJAX)
  # -----------------------------------------------------
  def history
    @template = Template.find(params[:id])
    authorize @template
    @templates = Template.where(family_id: @template.family_id)
    @current = Template.current(@template.family_id)
    paginable_renderise(
      partial: 'history',
      scope: @templates,
      locals: { current: templates.maximum(:version) })
  end
end
