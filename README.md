shellprovisioner
================

A zero dependency shell provisioner for bash.

Usage
-----

To add a new task, create a new directory in ./tasks. Inside this directory, create a file `./do.sh` that will be executed when the server is provisioned. Optinally place a file `./undo.sh` that rolls back any changes if an error occurs.

To add a new configuration, simply put a file that contains one task per line into the ./configs directory. See section Samples for usage examples.

Samples
-------

* Hello World: `./provision.sh samples/helloworld`
* Failing Task: `./provision.sh samples/failingtask`
* Nested Provisioning: `./provision.sh samples/nested_provisioning`
