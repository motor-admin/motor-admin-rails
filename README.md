<div align="center">

[![Motor Admin Rails](https://user-images.githubusercontent.com/5418788/140520844-a947845d-b579-4b3f-9b49-c539ad3cf580.png)](https://www.getmotoradmin.com/ruby-on-rails)

# Motor Admin Rails

Low-code Admin panel and Business intelligence Rails engine **(no DSL - configurable from the UI)**.

🤓 [Demo App](https://app.getmotoradmin.com/demo/) | 👀 [Features overview](https://www.youtube.com/watch?v=ngVoci8Hll4&list=PLu7llEMh0KcOkR3Uy_RJT0cXPZQKAYVsq&index=1) | ⭐ [Pro](https://www.getmotoradmin.com/ruby-on-rails)
</div>

[![Admin Panel](https://user-images.githubusercontent.com/5418788/119318538-1f30e300-bc82-11eb-94a4-107c31c93b13.png)](https://app.getmotoradmin.com/demo/)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'motor-admin'
```

And then execute:
```bash
$ bundle install
```

Create and run migration:
```bash
$ rails motor:install && rake db:migrate
```

## Features

* [Customizable CRUD](#customizable-crud)
* [Custom actions](#custom-actions)
* [Virtual attributes](#virtual-attributes)
* [Forms builder](#forms-builder)
* [SQL queries](#sql-queries)
* [Data visualization](#data-visualization)
* [Dashboards](#dashboards)
* [Email alerts](#email-alerts)
* [Authorization](#authorization)
* [Active Storage](#active-storage)
* [Intelligence search](#intelligence-search)
* [I18n](#i18n)
* [Optimized for mobile](#optimized-for-mobile)
* [Configurations sync between environments](#configurations-sync)
* [Authentication](#authentication)
* Multiple databases support
* Audit log
* Live collaboration notes
* Personalized report alerts via Slack

## [Pro](https://www.getmotoradmin.com/ruby-on-rails)

* Custom styling and logo (white label)
* Multi-factor authentication
* SSO/SAML
* [learn more](https://www.getmotoradmin.com/ruby-on-rails)

### Customizable CRUD

![Resource settings](https://user-images.githubusercontent.com/5418788/119318569-2a840e80-bc82-11eb-9ba3-f3964eb6f997.png)

![Settings UI](https://user-images.githubusercontent.com/5418788/119263883-90708780-bbe9-11eb-9f9f-f76fed0b7f27.png)

Everything in the admin panel can be configured using the intuitive settings UI, which can be opened via the icon in the top right corner.

Data displayed on the resource page can be completely customized via [SQL queries](#sql-queries) and [dashboards](#dashboards) attached to the resource as a tab. Usually, queries used to display resource data should contain `{{resource_name_id}}` [variable](#sql-queries).

[Learn more about resource customizations](https://github.com/motor-admin/motor-admin-rails/blob/master/guides/customizing_resource_table.md)

### Custom Actions

![Custom actions](https://user-images.githubusercontent.com/5418788/119266132-3c1dd580-bbf2-11eb-9666-09e1640eaf7b.png)

Custom resource actions can be added via Active Record method call, API endpoint, or [custom forms](#forms-builder). Also, it's possible to override default create/update/delete actions.

### Virtual attributes

Any ActiveRecord model method or attribute can be exposed to the admin panel by adding a new column with the name that matches the method name from the resource model:

```ruby
class Customer < ApplicationRecord
  has_many :orders

  def lifetime_value
    orders.sum(&:total_price)
  end
end
```

![Virtual attribute](https://user-images.githubusercontent.com/5418788/123373683-76321c80-d58e-11eb-914d-675444b7eb2a.png)

### Forms Builder

![Custom form](https://user-images.githubusercontent.com/5418788/119264008-1391dd80-bbea-11eb-9f14-cb405e77fb60.png)

Values from the form fields can be used in API path via `{field_name}` syntax: `/api/some-endpoint/{resource_id}/apply`.

[Learn more about custom forms builder](https://github.com/motor-admin/motor-admin-rails/blob/master/guides/building_custom_forms.md)

### SQL Queries

![SQL query](https://user-images.githubusercontent.com/5418788/119264127-84d19080-bbea-11eb-9903-ef465d1d2c97.png)

Queries can include embedded variables via `{{variable}}` syntax ([mustache](https://mustache.github.io)). `{{#variable}} ... {{/variable}}` syntax allows to decide if conditions inside the scope should be included in the query.

### Data Visualization

![motor-visualization](https://user-images.githubusercontent.com/5418788/119264625-a2075e80-bbec-11eb-986c-6106dd6e47ce.png)

Data from the SQL query can be represented as: table, number, line chart, bar chart, pie chart, funnel, markdown.

### Dashboards

![Dashboard](https://user-images.githubusercontent.com/5418788/119264726-f579ac80-bbec-11eb-852e-8055f8aba200.png)

SQL queries can be organized into dashboards to create a convenient representation of the data.

### Email Alerts

![Email alert](https://user-images.githubusercontent.com/5418788/119265049-feb74900-bbed-11eb-8070-bcc8d6113b9b.png)

Query data can be sent via email periodically using the alerts feature. Interval of the alert email can be specified using natural language, e.g., `every day at midnight`, `every Monday at 8 PM`, `every weekday at 6AM and 6PM`, `every minute`.

Sender address can be specified using `MOTOR_ALERTS_FROM_ADDRESS` environment variable.

### Intelligence Search

![Intelligence search](https://user-images.githubusercontent.com/5418788/119266559-eea26800-bbf3-11eb-8cb3-d0538aa386a9.png)

Intelligence search can be opened via the top right corner button or using <kbd>Cmd</kbd> + <kbd>K</kbd> shortcut.

### Authorization

Motor Admin allows to set row-level and column-level permissions via [cancan](https://github.com/CanCanCommunity/cancancan) gem. Admin UI permissions should be defined in `app/models/motor/ability.rb` file in `Motor::Ability` class. See [Motor Admin guide](https://github.com/motor-admin/motor-admin-rails/blob/master/guides/defining_permissions.md) and [CanCan documentation](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Defining-Abilities.md) to learn how to define user permissions.

### Active Storage

Motor Admin is configured by default to perform uploads to the provider you configured in your `storage.yml` file for Active Storage. If you are using large uploads within Motor Admin you will need to enable direct uploads by setting the following ENV variable. 

```sh
MOTOR_ACTIVE_STORAGE_DIRECT_UPLOADS_ENABLED=true
```

_Note: At the moment, this will enable direct uploads globally_

### I18n

Motor Admin can use Rails ActiveRecord i18n keys to render resource translations:

```yml
es:
  activerecord:
    models:
      customer:
        one: Cliente
        other: Clientes
    attributes:
      customer:
        name: Nombre
    scopes:
      customer:
        enabled: Activado
```

### Optimized for Mobile

![motor-mobile](https://user-images.githubusercontent.com/5418788/119269566-03392d00-bc01-11eb-9e9d-1f6a58fe0749.png)


### Configurations Sync

All admin panel configurations are automatically stored in the `config/motor.yml` file. It's recommended to include this file in the application git repository to always have the admin panel configurations in sync across different local and remote environments.

It's possible to sync local development admin panel configurations with remote production application via `rake motor:sync` task:

```bash
MOTOR_SYNC_REMOTE_URL=https://remote-app-url/ MOTOR_SYNC_API_KEY=secure-random-string rake motor:sync
```


## Authentication

Admin panel can be secured with 'Basic authentication' by specifying `MOTOR_AUTH_USERNAME` and `MOTOR_AUTH_PASSWORD` environment variables. Alternatively, the username and password can be added to the credentials file:

```yaml
motor:
  username: <username>
  password: <password>
```

The admin panel can also be secured using [devise](https://github.com/heartcombo/devise/wiki/How-To:-Define-resource-actions-that-require-authentication-using-routes.rb) or any other authentication library used by the application:

```ruby
authenticate :admin_user do
  mount Motor::Admin => '/admin'
end
```

## Development

Start webpack dev server:

```bash
yarn install && yarn serve
```

Setup development database:

```bash
rake app:db:create && rake app:db:setup
```

Start example application in development mode:

```bash
MOTOR_DEVELOPMENT=true rails s
```

## License

Motor Admin is licensed under the MIT license.
