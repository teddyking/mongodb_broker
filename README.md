# About
A Cloud Foundry v2.0 Service Broker for MongoDB. The broker is intended to be deployed as a Cloud Foundry app using ```cf push```. Provision/bind requests will create a new database/user in an existing MongoDB setup. Much of the work in this repo is based on work from [github-service-broker-ruby](https://github.com/cloudfoundry-samples/github-service-broker-ruby).

# Requirements
* cf version 6 (see [here](http://docs.gopivotal.com/pivotalcf/devguide/installcf/install-go-cli.html)).
* Admin access to a Cloud Foundry instance.
* Admin access to a MongoDB instance.
* The MongoDB instance must be accessible to the broker (access is currently unauthenticated).

# Setup and Deployment
1. Clone this repository and cd into the repo directory.
2. Run ```bundle install``` and ```bundle exec rspec -c``` to test.
3. Edit the basic_auth and mongodb_service settings in config/mongodb_broker.yml file.
4. Deploy the app to Cloud Foundry using ```cf push <name>```.
5. Register the broker (see [here](http://docs.cloudfoundry.org/services/managing-service-brokers.html#register-broker) for info).
6. Make the service plan public (see [here](http://docs.cloudfoundry.org/services/access-control.html#make-plans-public) for info).

# Binding and Example App
You can grab the service credentials as follows:
```ruby
vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
uri = vcap_services['mongodb'].first['credentials']['uri']
```
An example app using this service broker can be found [here](https://github.com/teddyking/cakes).
