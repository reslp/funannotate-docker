funannotate 1.7.2 docker
======

This is a docker image for the [funannotate](https://github.com/nextgenusfs/funannotate) genome annotation pipeline.

It is still in testing phase!

### External dependencies:

Things not included in the Container, which need to be installed manually due to licensing incompatibility:

1. Signal-P 4.1: [www.cbs.dtu.dk/services/SignalP/](http://www.cbs.dtu.dk/services/SignalP/) 
2. GeneMark-ES: [exon.gatech.edu/GeneMark/](http://exon.gatech.edu/GeneMark/)
3. Repeatmasker libraries from RepBase

The way to get these programs into the container is to place them into a folder and then mount this folder to a specific point in the container by adding a certain flag to the docker run command:

	-v /local/location_of_programs:/root/

The docker container is set up in such a way as that it searches for specific folders in the root directory and adds them to the path. This way, funannotate running inside the container finds the desired programs. Currently the container is etup to add the following folders o the PATH hence the version names:

	/root/signalp-4.1
	/root/gm_et_linux_64

Also it expects the GeneMark license key file in /root/.




### Setting up the funannotate database:

Funannotate relies on a larger dataset of different kinds which it uses to add functional annotations, train gene finders etc. This database needs to be created with 

	funannotate setup

The docker container has the location folder for the database hardcoded (by setting the FUNANNOTATE_DB environment variable) to /root/database/. This folder needs to be overwritten with the local location of the database when funannotate is run. This is again done when docker run is invoked:

	-v /local/location/of/database:/root/database



### Where is my data?

Data will be stored in /data which can be mounted from an external folder as well like so:

	-v $(pwd):/data




### An example command for the funannotate docker container:

This command mount external dependencies and a database folder:

	docker run --rm -it -v $(pwd)/external:/root -v $(pwd)/database:/root/database -v $(pwd):/data reslp/funannotate check






