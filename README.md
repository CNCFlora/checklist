# Checklist

CNCFlora app to handle the checklists, a simple list of species to work upon for the other apps.

## Deployment

Use docker:
  
  docker run -d -p 8181:8080 -t cncflora/checklist

You will need to have access to etcd, connect and datahub.

## Development

Use [vagrant](http://vagrantup.com) and [virtualbox](http://virtualbox.org):

  vagrant up
  vagrant ssh
  cd /vagrant


To start the test server, available at http://192.168.50.16:9292:

  rackup

Run tests:

  rspec tests/\*.rb

Build the container for deployment:


  docker build -t cncflora/checklist .
  docker push cncflora/checklist 


## License

Apache License 2.0

