# frozen_string_literal: true

module Motor
  class Railtie < Rails::Railtie
    railtie_name :motor_admin

    rake_tasks do
      Dir[Motor::PATH.join('./motor/tasks/**/*.rake')].each { |f| load f }
    end
  end
end
