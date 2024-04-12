# Install development env

## Setup tools

Install RVM and Ruby:
```sh
https://rvm.io/rvm/install

rvm install $(sed -n '1p' .ruby-version)
rvm use $(sed -n '1p' .ruby-version)

bundle install
```

## Setup env variables

Create and set all need credentials that are used in the `config/initializers/environment_loader.rb`:
```sh
# .env.development

################################################# DB Postgres
DB_NAME=kamal_blog_development
DB_HOST=localhost
DB_USER=postgres
POSTGRES_PASSWORD=postgres

################################################# DB Redis
REDIS_URL=redis://localhost:6379/0
```

## Setup Database

Check and fix DB config `config/database.yml`, then run:

```sh
rails db:create
rails db:migrate
```

## Run app
```sh
# Tab 1
rails s

# Tab 2
rails resque:work QUEUES=*
```

Go to http://localhost:3000
