require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jtw
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.i18n.default_locale = :ja

    # バリデーション時のエラー表示
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      if instance.kind_of?(ActionView::Helpers::Tags::Label)
        html_tag.html_safe
      else
        Nokogiri::HTML.fragment(html_tag).search('input', 'textarea', 'select').add_class('is-error').to_html.html_safe
      end
    end

    config.time_zone = 'Tokyo'

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # ajaxを使用する場合の設定
    config.action_view.embed_authenticity_token_in_remote_forms = true

    #送信メール内でlink_toを使うため
    config.action_mailer.default_url_options = { host: 'localhost:3000' }

  end
end
