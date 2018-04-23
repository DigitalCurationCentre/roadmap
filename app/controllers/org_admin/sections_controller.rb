module OrgAdmin
  class SectionsController < ApplicationController
    include Versionable
    
    respond_to :html
    after_action :verify_authorized

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections
    def index
      authorize Section.new
      phase = Phase.includes(:template, :sections).find(params[:phase_id])
      edit = (current_user.can_modify_templates?  &&  (phase.template.org_id == current_user.org_id))
      render partial: 'index', 
        locals: { 
          template: phase.template, 
          phase: phase, 
          sections: phase.sections, 
          current_section: phase.sections.first,
          current_tab: params[:r] || 'all-templates',
          edit: edit 
        }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def show
      section = Section.includes(questions: [:annotations, :question_options]).find(params[:id])
      authorize section
      render partial: 'show', locals: { section: section }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]/edit
    def edit
      section = Section.includes({phase: :template}, questions: [:annotations, :question_options]).find(params[:id])
      authorize section
      render partial: 'edit', 
        locals: { 
          template: section.phase.template, 
          phase: section.phase, 
          section: section ,
          current_tab: params[:r] || 'all-templates',
          edit: true
        }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/new
    def new
      phase = Phase.includes(:template, :sections).find(params[:phase_id])
      section = Section.new(phase: phase, number: (phase.sections.length > 0 ? phase.sections.max{ |a, b| a.number <=> b.number }.number+1 : 1))
      authorize section
      render partial: 'new', 
        locals: { 
          template: phase.template,
          phase: phase,
          section: section,
          current_tab: params[:r] || 'all-templates'
        }
    end

    # POST /org_admin/templates/[:template_id]/phases/[:phase_id]/sections
    def create
      phase = Phase.includes(:template, :sections).find(params[:phase_id])
      section = Section.new(section_params.merge({ phase_id: phase.id }))
      authorize section
      begin
        section = get_new(section)
      
# TODO: update UI so that this comes in as part of the `section:` part of the params
        section.description = params["section-desc"]
        phase = section.phase
        current_tab = params[:r] || 'all-templates'

# TODO: Consider calling this via AJAX and returning the `edit` partial instead of rerendering the entire page
        if section.save!
          flash[:notice] = success_message(_('section'), _('created'))
        else
          flash[:alert] = failed_create_error(section, _('section'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      
      if flash[:alert].present?
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, r: current_tab)
      else
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: section.phase_id, r: current_tab,
          section_id: section.id)
      end
    end

    # PUT /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def update
      section = Section.includes(phase: :template).find(params[:id])
      authorize section
      begin
        section = get_modifiable(section)
        section.description = params["section-desc"]
        phase = section.phase
        current_tab = params[:r] || 'all-templates'

# TODO: Consider calling this via AJAX and returning the `edit` partial instead of rerendering the entire page
        if section.update!(section_params)
          flash[:notice] = success_message(_('section'), _('saved'))
        else
          flash[:alert] = failed_update_error(section, _('section'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      
      if flash[:alert].present?
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, section_id: section.id, r: current_tab)
      else
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, section_id: section.id, r: current_tab)
      end
    end

    # DELETE /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def destroy
      section = Section.includes(phase: :template).find(params[:id])
      authorize section
      begin
        section = get_modifiable(section)
        phase = section.phase
        current_tab = params[:r] || 'all-templates'
      
# TODO: Consider calling this via AJAX and removing that portion of the DOM if successful
        if section.destroy!
          flash[:notice] = success_message(_('section'), _('deleted'))
        else
          flash[:alert] = failed_destroy_error(section, _('section'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      
      if flash[:alert].present?
        redirect_to(org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, r: current_tab))
      else
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, r: current_tab)
      end
    end
    
    private
      def section_params
        params.require(:section).permit(:title, :description, :number, :phase_id)
      end
  end
end