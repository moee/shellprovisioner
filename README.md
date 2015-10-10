# zdsp: Zero Dependcy Shell Provisioner

The zero dependency shell provisioner for bash.

## Features

* Inheritance
* Rollback
* Task Isolation
* Task Reuse
* Initalizer Tasks

## Usage

### Tasks

To add a new task, create a new directory in `./tasks.` Inside this directory, create a file `./do.sh` that will be executed when the server is provisioned. Optionally place a file `./undo.sh` that rolls back any changes if an error occurs. If you do not need rollback functionality, just create a plain file with the task name instead of a directory.

### Configs
To add a new configuration, simply put a file that contains one task per line into the `./configs` directory. See section Samples for usage examples.

### Variables

Inside the tasks scripts the following variables can be used:

* `$ZDSP_BASE_DIR` Points to the directory of `./provision.sh`
* `$ZDSP_TASK_DIR` Points to the directory where the tasks are located
* `$ZDSP_CONFIG_DIR` Points to the configuration directory

## Samples

* Hello World: `./zdsp samples/helloworld`
* Failing Task: `./zdsp samples/failingtask`
* Nested Provisioning: `./zdsp samples/nested_provisioning`
