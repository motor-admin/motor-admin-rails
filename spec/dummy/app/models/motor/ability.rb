# frozen_string_literal: true

module Motor
  class Ability
    include CanCan::Ability

    def initialize(user, _request = nil)
      if user
        case user.role
        when 'admin'
          can :manage, :all
        when 'ops'
          resource_abilities
          motor_abilities

          cannot :destroy, Order
          can :manage, User, id: user.id
          cannot :destroy, User
        when 'sales'
          resource_abilities
          motor_abilities
        end
      else
        can :manage, :all
      end
    end

    def resource_abilities
      can :read, Product, Product.column_names.map(&:to_sym) - [:price]
      can :update, Product, [:name]
      can :manage, Customer
      can :read, Order, { customer: { country_code: 'US' } }
      can :update, Order,
          Order.column_names.map(&:to_sym) - [:customer_id],
          { customer: { country_code: 'US' }, status: 'pending' }
      can :mark_as_shipped, Order, { status: 'pending' }
      can :manage, Country
      can :manage, Note
    end

    def motor_abilities
      can :read, Motor::Tag
      can :read, Motor::NoteTag
      can :manage, Motor::Reminder
      can :manage, Motor::Notification
      can :read, ActiveStorage::Attachment
      can :read, Motor::Form, %i[name tags], tags: { name: %w[Orders Customers] }
      can :manage, Motor::Form, tags: { name: %w[Orders Customers] }
      cannot %i[create update], Motor::Form
      can :manage, Motor::Query
      can :read, Motor::Dashboard, tags: { name: 'Customers' }
      can :read, Motor::Alert, tags: { name: 'Customers' }
    end
  end
end
