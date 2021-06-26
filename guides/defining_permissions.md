# Defining permissions

Motor Admin uses [cancan](https://github.com/CanCanCommunity/cancancan) gem to set row-level and column-level permissions.

## Example

```ruby
module Motor
  class Ability
    include CanCan::Ability

    def initialize(user, _request)
      case user.role
      when 'admin'
        can :manage, :all
      when 'ops'
        resource_abilities
        motor_abilities

        can :manage, User, id: user.id
      when 'sales'
        resource_abilities
        motor_abilities
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
      can :read, ActiveStorage::Attachment
      can :read, Motor::Form, %i[name tags], tags: { name: %w[Orders Customers] }
      can :manage, Motor::Form, tags: { name: %w[Orders Customers] }
      can :manage, Motor::Query
      can :read, Motor::Dashboard, tags: { name: 'Customers' }
      can :read, Motor::Alert, tags: { name: 'Customers' }
    end
  end
end
```

## Avoid using `cannot`

CanCan recommends to avoid using `cannot` ([link](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Defining-Abilities:-Best-Practices.md#give-permissions-dont-take-them-away)) to make permissions clear and readable.

```ruby
# Bad

can :manage, Product
cannot :update, Product, [:name]

# Good

can %i[read create destroy], Product
can :update, Product, Product.column_names.map(&:to_sym) - [:name]
```

## How To's

### Load user-specific resources

```ruby
# Shows only orders from specific customer country
can :manage, Order, { customer: { country_code: current_user.country_code } }
```

### Remove certain columns for user

```ruby
# Allows to CRUD all columns except the `:name` column
can :manage, Product, Product.column_names.map(&:to_sym) - [:name]
```

### Allow custom action

```ruby
# Allows to mark as shipped only if the current status is `:pending`
can :mark_as_shipped, Order, { status: :pending }
```

### Allow to view dashboards with a specific tag

```ruby
# Only dashboards with specific tag will be accessiable by user with the role
can :read, Motor::Dashboard, { tags: { name: current_user.role.capitalize } }
```

# Query permissions

It's possible to filter data for specific user in SQL using `{{current_user_id}}` `{{current_user_email}}` variables.

```sql
SELECT * FROM orders as od
JOIN sales_reps as sr ON sr.id = od.sales_rep_id
WHERE sr.user_id = {{current_user_id}}
```
