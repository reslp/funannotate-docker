funannotate docker
======

This is a docker image for the [funannotate](https://github.com/nextgenusfs/funannotate) genome annotation pipeline.

```
docker pull reslp/funannotate:1.7.2
docker pull reslp/funannotate:1.7.4
docker pull reslp/funannotate:experimental # removes phylogenetic reconstruction and heatmaps from funannotate compare
docker pull reslp/funannotate:git_clone # based on latest commit on build date: June 22, 2020
```


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
singularity pull docker://reslp/funannotate:1.7.2

```
Singularity however does a few things differently compared to Docker. One important difference is, that Singularity images are read only. Only bound user directories are writable. This is important to remember when using the container. It is therefore important (even more as for Docker) to use the pre defined bind points for the database and external programs.



## Installed software

**The funannotate container includes (version numbers refer to the latest build tag and the latest version):**

funannotate 1.7.4 or funannotate 1.7.2\
CodingQuarry 2.0\
Trinity 2.8.6\
Augustus 3.3.2\
BLAT v. latest\
FASTA36 36.3.8\
diamond 0.9.29\
GMAP 2019-09-12\
GlimmerHMM-3.0.4\
minimap2 2.17\
kallisto 0.46.1\
Proteinortho 6.0.12\
pslCDnaFilter v. latest\
salmon 1.1.0\
snap v. github commit daf76badb477d22c08f2628117c00e057bf95ccf\
stringtie 2.0.6\
tRNA-Scan SE 2.0.5\
Infernal 1.1.3\
trimmomatic 0.39\
tantan 22\
trimal 1.4.1\
PASA 2.4.1\
EvidenceModeler 1.1.1\
ete3 3.0.0b35\
RECON 1.08\
RepeatScout 1.0.6\
TRF 409\
rmblast 2.9.0+\
RepeatMasker 4.0.7\
RepeatModeler 2.0.1\
tabl2asn v. latest\

**Python modules:**

python 2.7.17\
asn1crypto 0.24.0\
atomicwrites 1.3.0\
attrs 19.3.0\
backports.functools-lru-cache 1.6.1\
biopython 1.76\
certifi 2019.11.28\
chardet 3.0.4\
configparser 4.0.2\
contextlib2 0.6.0.post1\
coverage 5.0.3\
cryptography 2.6.1\
cycler 0.10.0\
dbus-python 1.2.12\
docopt 0.6.2\
entrypoints 0.3\
enum34 1.1.6\
ete3 3.0.0b35\
funannotate 1.7.2\
funcsigs 1.0.2\
goatools 0.9.9\
idna 2.8\
importlib-metadata 1.4.0\
ipaddress 1.0.17\
keyring 18.0.1\
keyrings.alt 3.1.1\
kiwisolver 1.1.0\
lxml 4.4.1\
matplotlib 2.2.4\
more-itertools 5.0.0\
natsort 6.2.0\
nose 1.3.7\
numpy 1.16.2\
packaging 20.1\
pandas 0.24.2\
pathlib2 2.3.5\
patsy 0.5.1\
pip 18.1\
pluggy 0.13.1\
psutil 5.6.7\
py 1.8.1\
pycrypto 2.6.1\
pydot 1.4.1\
PyGObject 3.34.0\
pyparsing 2.4.6\
pytest 4.6.9\
pytest-cov 2.8.1\
python-dateutil 2.8.1\
pytz 2019.3\
pyxdg 0.25\
requests 2.22.0\
scandir 1.10.0\
scikit-learn 0.20.4\
scipy 1.2.3\
seaborn 0.9.1\
SecretStorage 2.3.1\
setuptools 41.1.0\
sip 4.19.18\
six 1.12.0\
statsmodels 0.11.0\
subprocess32 3.5.4\
urllib3 1.25.8\
wcwidth 0.1.8\
wget 3.2\
wheel 0.32.3\
xlrd 1.2.0\
XlsxWriter 1.2.7\
zipp 1.1.0
