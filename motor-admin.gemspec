# frozen_string_literal: true

require_relative 'lib/motor/version'

Gem::Specification.new do |spec|
  spec.name        = 'motor-admin'
  spec.version     = Motor::VERSION
  spec.authors     = ['Pete Matsyburka']
  spec.email       = ['pete.matsy@gmail.com']
  spec.summary     = 'Low-code Admin panel and Business intelligence'
  spec.license     = 'MIT'

  spec.files = Dir[
    '{app,config,lib}/**/*',
    'ui/dist/icons/*.gz',
    'ui/dist/fonts/*.woff2',
    'ui/dist/*.{gz,json}',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'activerecord-filter', '>= 5.2'
  spec.add_dependency 'ar_lazy_preload', '~> 0.6'
  spec.add_dependency 'audited', '~> 5.0'
  spec.add_dependency 'cancancan', '~> 3.0'
  spec.add_dependency 'fugit', '~> 1.0'
  spec.add_dependency 'rails', '>= 5.2'

  spec.post_install_message = "
    ==================
    Run `rails g motor:upgrade && rake db:migrate`
    to perform data migration and enable the latest features'
    ==================
  "

  spec.description = <<~TEXT
    Motor Admin allows to create a flexible admin panel with writing less code.
    All customizations to the admin panel can be made directly in the UI without
    the need of writing any configurations code.
  TEXT
end
