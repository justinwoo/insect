Here is a fork of insect which does the following:

* Remove the need for bower, pushing deps to psc-package or npm
* Introduce a nix shell that can install psc-package dependencies in the format needed by psc-package and pulp
* Has pulp run using psc-package

You should be able to get everything running doing

> nix-shell --run 'npm install'

> npm start
