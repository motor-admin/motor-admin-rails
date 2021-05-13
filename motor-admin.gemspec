# frozen_string_literal: true

require_relative 'lib/motor/version'

Gem::Specification.new do |spec|
  spec.name        = 'motor-admin'
  spec.version     = Motor::VERSION
  spec.authors     = ['Pete Matsyburka']
  spec.email       = ['pete.matsy@gmail.com']
  spec.summary     = 'Admin UI and Business Analytics'
  spec.description = 'Admin UI and Business Analytics.'
  spec.license     = 'MIT'

  spec.files = Dir[
    '{app,config,db,lib}/**/*',
    'ui/dist/**/*.{gz,woff2,json}',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'activerecord-filter', '>= 5.2'
  spec.add_dependency 'ar_lazy_preload', '~> 0.6.0'
  spec.add_dependency 'audited', '~> 4.9'
  spec.add_dependency 'cancancan', '~> 3.0'
  spec.add_dependency 'fugit', '~> 1.0'
  spec.add_dependency 'js_regex', '~> 3.0'
  spec.add_dependency 'rails', '>= 5.2'
  spec.add_development_dependency 'rubocop', '~> 1.3.1'
  spec.add_development_dependency 'yard', '~> 0.9.0'
end
