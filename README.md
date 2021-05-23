# ⚡ Motor Admin

Low-code Admin panel and Business intelligence Rails engine **(no DSL - configurable from the UI)**.

🤓 [Demo App](https://motor-admin-demo.herokuapp.com)

[![Admin Panel](https://user-images.githubusercontent.com/5418788/119258612-2351f780-bbd3-11eb-8264-2e044cde868d.png)](https://motor-admin-demo.herokuapp.com)

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
$ rails generate motor:install && rake db:migrate
```

## Features

* [Customizable CRUD](#customizable-crud)
* [Custom actions](#custom-actions)
* [Forms builder](#forms-builder)
* [SQL queries](#sql-queries)
* [Data visualization](#data-visualization)
* [Dashboards](#dashboards)
* [Email alerts](#email-alerts)
* [Intelligence search](#intelligence-search)
* [Optimized for mobile](#optimized-for-mobile)
* [Configurations sync between environments](#configurations-sync)

### Customizable CRUD

![Resource settings](https://user-images.githubusercontent.com/5418788/119262945-b136de00-bbe5-11eb-846a-6e01c8c42904.png)

![Settings UI](https://user-images.githubusercontent.com/5418788/119263883-90708780-bbe9-11eb-9f9f-f76fed0b7f27.png)

Everything in the admin panel can be configured using intuitive settings UI, which can be opened via the icon in the top right corner.

Data displayed on the resource page can be completely custimized via [SQL queries](#sql-queries) and [dashboards](#dashboards) attached to the resource as a tab. Usually, queries used to display resource data should contain `{{resource_name_id}}` [variable](#sql-queries).

### Custom Actions

![Custom actions](https://user-images.githubusercontent.com/5418788/119266132-3c1dd580-bbf2-11eb-9666-09e1640eaf7b.png)

Custom resource actions can be added via Active Record method call, API endpoint, or [custom forms](#forms-builder). Also, it's possible to override default create/update/delete actions.

### Forms Builder

![Custom form](https://user-images.githubusercontent.com/5418788/119264008-1391dd80-bbea-11eb-9f14-cb405e77fb60.png)

Values from the form fields can be used in API path via `{field_name}` syntax: `/api/some-endpoint/{field_name}/apply`

### SQL Queries

![SQL query](https://user-images.githubusercontent.com/5418788/119264127-84d19080-bbea-11eb-9903-ef465d1d2c97.png)

Queries can include embeded variables via `{{variable}}` syntax ([mustache](https://mustache.github.io)). `{{#variable}} ... {{/variable}}` syntax allows to decide if conditions inside the scope should be included in the query.

### Data Visualization

![motor-visualization](https://user-images.githubusercontent.com/5418788/119264625-a2075e80-bbec-11eb-986c-6106dd6e47ce.png)

Data from the SQL query can be represented as: [table](https://motor-admin-demo.herokuapp.com/queries/12), [number](https://motor-admin-demo.herokuapp.com/queries/6), [line chart](https://motor-admin-demo.herokuapp.com/queries/3), [bar chart](https://motor-admin-demo.herokuapp.com/queries/1), [pie chart](https://motor-admin-demo.herokuapp.com/queries/9), [funnel](https://motor-admin-demo.herokuapp.com/queries/7), [markdown](https://motor-admin-demo.herokuapp.com/queries/8)

### Dashboards

![Dashboard](https://user-images.githubusercontent.com/5418788/119264726-f579ac80-bbec-11eb-852e-8055f8aba200.png)

SQL queries can be organized into dashboards to create a convenient representation of the data.

### Email Alerts

![Email alert](https://user-images.githubusercontent.com/5418788/119265049-feb74900-bbed-11eb-8070-bcc8d6113b9b.png)

Query data can be sent via email periodically using the alerts feature. Interval of the alert email can be specified using natural language, e.g., `every day at midnight`, `every Monday at 8 PM`, `every weekday at 6AM and 6PM`, `every minute`.

The sender address can be specified using `MOTOR_ADMIN_FROM_ADDRESS` environment variable.

### Intelligence Search

![Intelligence search](https://user-images.githubusercontent.com/5418788/119266559-eea26800-bbf3-11eb-8cb3-d0538aa386a9.png)

Intelligence search can be opened via the top right corner button or using <kbd>Cmd</kbd> + <kbd>P</kbd> shortcut.


### Optimized for Mobile

![motor-mobile](https://user-images.githubusercontent.com/5418788/119269566-03392d00-bc01-11eb-9e9d-1f6a58fe0749.png)


### Configurations Sync

All admin panel configurations are automatically stored in the `config/motor.yml` file. It's recommended to include this file in the application git repository to always have the admin panel configurations in sync across different local and remote environments.

It's possible to sync local development admin panel configurations with remote production application via `rake motor:sync` task:

```bash
MOTOR_SYNC_REMOTE_URL=https://remote-app-url/ MOTOR_SYNC_API_KEY=secure-random-string rake motor:sync
```


## Authentication

Admin panel can be secured with 'Basic authentication' by specifying `MOTOR_AUTH_USERNAME` and `MOTOR_AUTH_PASSWORD` environment variables.

Alternatively, it can be secured with [devise](https://github.com/heartcombo/devise/wiki/How-To:-Define-resource-actions-that-require-authentication-using-routes.rb) or any other authentication library used by the application:

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

Start example application in development mode:

```bash
MOTOR_DEVELOPMENT=true rails s
```

## Comming Soon

* User groups
* Row-level permissions
* Multiple databases
* NoSQL data sources
* Pro Bussines intelligence features

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/omohokcoj/motor-admin/blob/master/LICENSE).
