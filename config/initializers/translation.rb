TranslationIO.configure do |config|
  #config.api_key        = '5ad9324b8bb1426290c5509f1753285e'
  #config.source_locale  = 'en'
  #config.target_locales = ['de', 'en-GB', 'en-US', 'es', 'fr-FR', 'fi', 'sv-FI']

  # Uncomment this if you don't want to use gettext
  # config.disable_gettext = true

  # Uncomment this if you already use gettext or fast_gettext
   config.locales_path = Rails.root.join('config', 'locale')

  # Find other useful usage information here:
  # https://github.com/translation/rails#readme

  # Additional keys for multi-domain
  config.domains = [{
      name: 'app',
      api_key: ENV['TRANSLATION_API_ROADMAP'],
      source_locale: 'en',
      target_locales: ['de', 'en-GB', 'en-US', 'es', 'fr-FR', 'fi', 'sv-FI', 'pt-BR'],
      folders: []
    },
    {
      name: 'dmptuuli',
      api_key: ENV['TRANSLATION_API_TUULI'],
      source_locale: 'en',
      target_locales: ['fi', 'sv-FI'],
      folders: ['app/views/branded/']
    }
  ]
end

if Language.table_exists?
  def default_locale
    Language.default.try(:abbreviation) || "en-GB"
  end

  def available_locales
    LocaleSet.new(
      Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
    )
  end
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || "en-GB"
  end

  def available_locales
    Rails.application.config.i18n.available_locales = LocaleSet.new(["en-GB", "en"])
  end
end


I18n.available_locales = Language.all.pluck(:abbreviation)

I18n.default_locale        = Language.default.try(:abbreviation) || "en-GB"
