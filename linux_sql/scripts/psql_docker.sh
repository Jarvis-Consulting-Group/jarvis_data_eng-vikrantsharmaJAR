#! /bin/sh

# Capture CLI arguments (please do not copy comments)
cmd=$1
db_username=$2
db_password=$3

# Start docker
# Make sure you understand `||` cmd
sudo systemctl status docker || sudo systemctl start docker

# Check container status (try the following cmds on terminal)
docker container inspect jrvs-psql
container_status=$?

# User switch case to handle create|stop|start options
case $cmd in
  create)
    # Check if the container already exists
    if [ $container_status -eq 0 ]; then
      echo 'Container already exists'
      exit 1
    fi

    # Check the number of CLI arguments
    if [ $# -ne 3 ]; then
      echo 'Create requires username and password'
      exit 1
    fi

    # Create container
    docker volume create psql_volume

    # Start the container
    docker run -e POSTGRES_USER=$db_username -e POSTGRES_PASSWORD=$db_password -d --name jrvs-psql -p 5432:5432 -v psql_volume:/var/lib/postgresql/data postgres

    # Check the exit status
    exit $?
    ;;

  start|stop)
    # Check instance status; exit 1 if container has not been created
    if [ $container_status -ne 0 ]; then
      echo 'Container has not been created'
      exit 1
    fi

    # Start or stop the container
    docker container $cmd jrvs-psql

    # Check the exit status
    exit $?
    ;;

  *)
    echo 'Illegal command'
    echo 'Commands: start|stop|create'
    exit 1
    ;;
esac
