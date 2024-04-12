# Install development env

## Setup tools

### Install RVM and Ruby
```sh
# https://rvm.io/rvm/install

rvm install $(sed -n '1p' .ruby-version)
rvm use $(sed -n '1p' .ruby-version)

bundle install
```

### Install Node (optional)
```sh
nvm install $(sed -n '1p' .nvmrc)
nvm use $(sed -n '1p' .nvmrc)
node -v
npm install -g yarn
cd .. && cd kamal-blog
yarn install
```

### Autoload Ruby & Node versions
```sh
micro ~/.bashrc
#<append content bin/client/version_autoloader.sh>
```

## Setup env variables

Create and set all need credentials that are used in the `config/initializers/environment_loader.rb`:
```sh
# Create and fill ENV file for development
cp .default.env.development .env.development
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
