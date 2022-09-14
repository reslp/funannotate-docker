funannotate docker
======
![Docker Pulls](https://img.shields.io/docker/pulls/reslp/funannotate?style=flat-square)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/reslp/funannotate?style=flat-square)

This is a docker image for the [funannotate](https://github.com/nextgenusfs/funannotate) genome annotation pipeline.

```
docker pull reslp/funannotate:1.7.2
docker pull reslp/funannotate:1.7.4
docker pull reslp/funannotate:1.8.1
docker pull reslp/funannotate:1.8.3
docker pull reslp/funannotate:1.8.3_antismashV6 # this version contains a fix to correctly parse Antismash V6 results
docker pull reslp/funannotate:1.8.7
docker pull reslp/funannotate:1.8.11 (currently broken due to broken augustus in bioconda!)
docker pull reslp/funannotate:1.8.13
docker pull reslp/funannotate:experimental # removes phylogenetic reconstruction and heatmaps from funannotate compare (based on 1.7.4)
docker pull reslp/funannotate:git_clone # based on latest commit on build date: June 22, 2020 (based on 1.7.4)
```

**Note:** As of funannotate version 1.8.3 the container is based on a conda installation of funannotate. This lead to major changes in the Dockerfile. The basis for container versions pre 1.8.3 as the second Dockerfile: `Dockerfile_pre_1.8.3`
 

## Table of Contents
[Status of Container](#current-status-of-container)\
[Installation](#installation)\
[Example command](#an-example-command-for-the-funannotate-docker-container)\
[Singularity](#singularity)\
[Installed software](#installed-software)



## Current status of container

Funannotate provides lots of different functions which depend on many different programs. This list provides on overview of funannotate's basic functionality by using different symbols:

:x: feature currently not working\
:eight_pointed_black_star: feature and dependencies installed but not yet tested\
:white_check_mark: feature and dependencies installed and tested


**funannotate clean** :white_check_mark:\
**funannotate sort** :white_check_mark:\
**funannotate mask**:
- tantan :white_check_mark:
- repeatmasker :white_check_mark:
- repeatmodeler :white_check_mark:


**funannotate train** :eight_pointed_black_star:\
**funannotate predict**:
- AUGUSTUS :white_check_mark:
- Genemark :white_check_mark:
- Snap :white_check_mark:
- GlimmerHMM :white_check_mark:
- BUSCO :white_check_mark:
- Evidence Modeler :white_check_mark:
- tbl2asn :white_check_mark:
- tRNAScan-SE :white_check_mark:
- Exonerate :white_check_mark:
- minimap :white_check_mark:
- CodingQuarry :eight_pointed_black_star:
	
	
**funannotate fix** :eight_pointed_black_star:\
**funannotate update** :eight_pointed_black_star:\
**funannotate remote** :white_check_mark:\
**funannotate iprscan** :white_check_mark:\
**funannotate annotate**  :white_check_mark:\
**funannotate compare**  :eight_pointed_black_star: (works with experimental image `reslp/funannotate:experimental`, this contains stripped down version of compare without phylogenetic reconstruction)


**funannotate util** :white_check_mark:\
**funannotate setup** :white_check_mark:\
**funannotate test** :white_check_mark:\
**funannotate check** :white_check_mark:\
**funannotate species** :white_check_mark:\
**funannotate database** :white_check_mark:


## Installation

### Install the Container

With a working Docker installation simple run:

```
docker pull reslp/funannotate:latest
docker run --rm -it reslp/funannotate:latest check
```

to download and run the latest version of the container.

If you wish to go inside the container you can do:

```
docker run --rm -it --entrypoint /bin/bash reslp/funannotate:latest
```


### External dependencies:

A few programs are not included in the container. They need to be kept externally due to license incompatibility or large size:

1. Signal-P 4.1: [www.cbs.dtu.dk/services/SignalP/](http://www.cbs.dtu.dk/services/SignalP/) 
2. GeneMark-ES: [exon.gatech.edu/GeneMark/](http://exon.gatech.edu/GeneMark/)
3. Repeatmasker libraries from RepBase
4. InterproScan: [https://www.ebi.ac.uk/interpro/download/](https://www.ebi.ac.uk/interpro/download/)

The way to get these programs into the container is to place them into a folder and then mount this folder to a specific point in the container by adding a certain flag to the docker run command:

	-v /local/location_of_programs:/data/external

The docker container is set up in such a way as that it searches for specific folders in the root directory and adds them to the path. This way, funannotate running inside the container finds the desired programs. Currently the container is setup to add the following folders o the PATH hence the version names:

	/data/external/signalp-4.1
	/data/external/gm_et_linux_64

In Docker the container expects the GeneMark license key file in /data/.
In Sinularity it depends on how you run your container. Typically the license file needs to be in your home directory.

**A Note on SignalP:**

You need to change the `signalp` script to point to the correct directory (inside the container) otherwise signalp will fail to run. It should look like this:

```
###############################################################################
#               GENERAL SETTINGS: CUSTOMIZE TO YOUR SITE
###############################################################################

# full path to the signalp-4.1 directory on your system (mandatory)
BEGIN {
    $ENV{SIGNALP} = '/data/external/signalp-4.1';
}

# determine where to store temporary files (must be writable to all users)
my $outputDir = "/tmp";

# max number of sequences per run (any number can be handled)
my $MAX_ALLOWED_ENTRIES=100000;
```





### Setting up the funannotate database:

Funannotate relies on a larger dataset of different kinds which it uses to add functional annotations, train gene finders etc. This database needs to be created with 

	funannotate setup

The docker container has the location folder for the database hardcoded (by setting the FUNANNOTATE_DB environment variable) to /data/database/. This folder needs to be overwritten with the local location of the database when funannotate is run. This is again done when docker run is invoked:

	-v /local/location/of/database:/data/database

### Where is my data?

Data will be stored in /data which can be mounted from an external folder as well like so:

	-v $(pwd):/data


## Example commands for the funannotate docker container

The commands presented here assume that the current working directory contains the folders database and external:

```
$ ls
database
external
genome.fas
```

The external directory contains Signal-P, interproscan and genemark:

```
$ ls external
signalp-4.1
gm_et_linux_64
interproscan-5.39-77.0
```

With a directory structure like this it is possible to add all external dependencies and the database with a single mount command to the container.

This command mounts external dependencies and a database folder:

	docker run --rm -it -v $(pwd):/data reslp/funannotate check
	
These commands perform clean, sort, mask and predict using the container:

```
docker run --rm -it -v $(pwd):/data reslp/funannotate clean -i /data/genome.fas -o /data/genome_cleaned.fas 

docker run --rm -it -v $(pwd):/data reslp/funannotate sort -i /data/genome_cleaned.fas -o /data/genome_sorted.fas 

docker run --rm -it -v $(pwd):/data reslp/funannotate mask -i /data/genome_sorted.fas -o /data/genome_masked.fas -m repeatmasker --cpus 8

docker run --rm -it -v $(pwd):/data reslp/funannotate predict -i /data/genome_masked.fas -s "sample_species" -o /data/sample_species_preds --cpus 8

```

## Singularity

The idea is to make this container also work with Singularity. This is important because most big clusters don't allow Docker due to the high user privileges it requires. In such environments Singularity offers an alternative to Docker. With singularity it is possible to build Singularity containers directly from Dockerhub. This of course also works with the funannotate container:

```
singularity pull docker://reslp/funannotate:1.8.1

```
Singularity however does a few things differently compared to Docker. One important difference is, that Singularity images are read only. Only bound user directories are writable. This is important to remember when using the container. It is therefore important (even more as for Docker) to use the pre defined bind points for the database and external programs.



## Installed software

**The funannotate container includes (version numbers refer to the latest build tag and the latest version):**

funannotate 1.8.11\
CodingQuarry 2.0\
Trinity 2.8.5\
Augustus 3.3.3\
BLAT 2.2.31+\
FASTA36 36.3.8\
diamond 2.0.15\ 
GMAP 2021-08-25\
GlimmerHMM-3.0.4\
minimap2 2.24-r1122\
kallisto 0.46.1\
Proteinortho 6.0.33\
pslCDnaFilter v. latest\
salmon 0.14.1\
snap 2006-07-28\
stringtie 2.2.1\
tRNA-Scan SE 2.0.9 (July 2021)\
Infernal 1.1.3\
trimmomatic 0.39\
tantan 22\
trimal 1.4.1\
PASA 2.5.2\
EvidenceModeler 1.1.1\
ete3 3.0.0b35\
RECON 1.08\
RepeatScout 1.0.6\
TRF 409\
rmblast 2.9.0+\
RepeatMasker 4.0.7\
RepeatModeler 2.0.1\

**Python modules:**

python 3.8.12\
biopython: 1.77\
goatools: 1.2.3\
matplotlib: 3.4.3\
natsort: 8.1.0\
numpy: 1.23.1\
pandas: 1.4.3\
psutil: 5.9.1\
requests: 2.28.1\
scikit-learn: 1.1.2\
scipy: 1.8.0\
seaborn: 0.11.2\
