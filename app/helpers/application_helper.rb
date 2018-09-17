# frozen_string_literal: true

module ApplicationHelper

  def javascript_manifest_file
    if Rails.application.config.action_view.javascript_manifest_resolver
      Rails.application.config.action_view.javascript_manifest_resolver.call(request)
    else
      "application"
    end
  end

  def stylesheet_manifest_file
    if Rails.application.config.action_view.stylesheet_manifest_resolver
      logger.debug('stylesheet_manifest_file')
      logger.debug(Rails.application.config.action_view.stylesheet_manifest_resolver.call(request))

      Rails.application.config.action_view.stylesheet_manifest_resolver.call(request)
    else
      "application"
    end
  end

  def resource_name
    :user
  end

  # ---------------------------------------------------------------------------
  def resource
    @resource ||= User.new
  end

  # ---------------------------------------------------------------------------
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # Determines whether or not the URL path passed matches with the full path (including
  # params) of the last URL requested. See
  # http://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-fullpath
  # for details
  def active_page?(path, exact_match = false)
    if exact_match
      request.fullpath == path
    else
      request.fullpath.include?(path)
    end
  end

  alias isActivePage active_page?

  deprecate :isActivePage, deprecator: Cleanup::Deprecators::PredicateDeprecator.new

  def fingerprinted_asset(name)
    Rails.env.production? ? "#{name}-#{ASSET_FINGERPRINT}" : name
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def unique_dom_id(record, prefix = nil)
    klass     = dom_class(record, prefix)
    record_id = record_key_for_dom_id(record) || record.object_id
    "#{klass}_#{record_id}"
  end

end
