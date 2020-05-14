# frozen_string_literal: true

class OrgsController < ApplicationController

  after_action :verify_authorized, except: ["shibboleth_ds", "shibboleth_ds_passthru"]
  respond_to :html

  ##
  # GET /organisations/1/edit
  def admin_edit
    org = Org.find(params[:id])
    authorize org
    languages = Language.all.order("name")
    org.links = { "org": [] } unless org.links.present?
    render "admin_edit", locals: { org: org, languages: languages, method: "PUT",
                                   url: admin_update_org_path(org) }
  end

  ##
  # PUT /organisations/1
  def admin_update
    attrs = org_params
    @org = Org.find(params[:id])
    authorize @org
    @org.logo = attrs[:logo] if attrs[:logo]
    tab = (attrs[:feedback_enabled].present? ? "feedback" : "profile")
    if params[:org_links].present?
      @org.links = JSON.parse(params[:org_links])
    end

    # Only allow super admins to change the org types and shib info
    if current_user.can_super_admin?
      # Handle Shibboleth identifiers if that is enabled
      if Rails.application.config.shibboleth_use_filtered_discovery_service
        shib = IdentifierScheme.find_by(name: "shibboleth")
        shib_settings = @org.org_identifiers.select do |ids|
          ids.identifier_scheme == shib
        end.first

        if params[:shib_id].blank? && shib_settings.present?
          # The user cleared the shib values so delete the object
          shib_settings.destroy
        else
          unless shib_settings.present?
            shib_settings = OrgIdentifier.new(org: @org, identifier_scheme: shib)
          end
          shib_settings.identifier = params[:shib_id]
          shib_settings.attrs = { domain: params[:shib_domain] }
          shib_settings.save
        end
      end
    end

    if @org.update_attributes(attrs)
      redirect_to "#{admin_edit_org_path(@org)}\##{tab}",
                  notice: success_message(@org, _("saved"))
    else
      failure = failure_message(@org, _("save")) if failure.blank?
      redirect_to "#{admin_edit_org_path(@org)}\##{tab}", alert: failure
    end
  end

  # GET /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds
    redirect_to root_path unless current_user.nil?

    @user = User.new
    # Display the custom Shibboleth discovery service page.
    @orgs = Org.joins(:identifier_schemes)
               .where("identifier_schemes.name = ?", "shibboleth").sort do |x, y|
                  x.name <=> y.name
                end

    if @orgs.empty?
      flash.now[:alert] = _("No organisations are currently registered.")
      redirect_to user_shibboleth_omniauth_authorize_path
    end
  end

  # POST /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds_passthru
    if !params["shib-ds"][:org_name].blank?
      session["org_id"] = params["shib-ds"][:org_name]

      scheme = IdentifierScheme.find_by(name: "shibboleth")
      shib_entity = OrgIdentifier.where(org_id: params["shib-ds"][:org_id],
                                        identifier_scheme: scheme)

      if !shib_entity.empty?
        # Force SSL
        shib_login = Rails.application.config.shibboleth_login
        url = "#{request.base_url.gsub("http:", "https:")}#{shib_login}"
        target = "#{user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')}"

        # initiate shibboleth login sequence
        redirect_to "#{url}?target=#{target}&entityID=#{shib_entity.first.identifier}"
      else
        failure = _("Your organisation does not seem to be properly configured.")
        redirect_to shibboleth_ds_path, alert: failure
      end

    else
      redirect_to shibboleth_ds_path, notice: _("Please choose an organisation")
    end
  end

  private
  def org_params
    params.require(:org)
          .permit(:name, :abbreviation, :logo, :contact_email, :contact_name,
                  :remove_logo, :org_type, :managed, :feedback_enabled,
                  :feedback_email_msg, :org_id, :org_name, :org_crosswalk,
                  identifiers_attributes: [:identifier_scheme_id, :value],
                  tracker_attributes: [:code])
  end

  def search_params
    params.require(:org).permit(:name, :type)
  end

  # Destroy the identifier if it exists and was blanked out, replace the
  # identifier if it was updated, create the identifier if its new, or
  # ignore it
  def process_identifier_change(org:, identifier:)
    return org unless identifier.is_a?(Identifier)

    if !identifier.new_record? && identifier.value.blank?
      # Remove the identifier if it has been blanked out
      identifier.destroy
    elsif identifier.value.present?
      # If the identifier already exists then remove it
      current = org.identifier_for_scheme(scheme: identifier.identifier_scheme)
      current.destroy if current.present? && current.value != identifier.value

      identifier.identifiable = org
      org.identifiers << identifier
    end

    org
  end

end
