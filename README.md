funannotate 1.7.2 docker
======

This is a docker image for the [funannotate](https://github.com/nextgenusfs/funannotate) genome annotation pipeline.

It is still in testing phase!

## Table of Contents
[Status of Container](#current-status-of-container)
[Installation](#installation)
[Example command](#an-example-command-for-the-funannotate-docker-container)
[Installed software](#installed-software)


## Current status of container

Funannotate provides lots of different functions which depend on many different programs. This list provides on overview of funannotate's basic functionality by using different symbols:

:x: feature currently not working
:eight_pointed_black_star: feature and dependencies installed but not yet tested
:white_check_mark: feature and dependencies installed and tested


**funannotate clean** :white_check_mark:
**funannotate sort** :white_check_mark:
**funannotate mask**:
	tantan :x:
	repeatmasker :white_check_mark:
	repeatmodeler :eight_pointed_black_star:

**funannotate train** :eight_pointed_black_star:
**funannotate predict**:
	AUGUSTUS :white_check_mark:
	Genemark :white_check_mark:
	Snap :white_check_mark:
	GlimmerHMM :x:
	BUSCO :white_check_mark:
	Evidence Modeler :white_check_mark:
	tbl2asn :white_check_mark:
	tRNAScan-SE :white_check_mark:
	Exonerate :white_check_mark:
	minimap :white_check_mark:
**funannotate fix** :eight_pointed_black_star:
**funannotate update** :eight_pointed_black_star:
**funannotate remote** :eight_pointed_black_star:
**funannotate iprscan** :x:
**funannotate annotate**  :white_check_mark:
**funannotate compare**  :x:

**funannotate util** :eight_pointed_black_star:
**funannotate setup** :white_check_mark:
**funannotate test** :white_check_mark:
**funannotate check** :white_check_mark:
**funannotate species** :eight_pointed_black_star:
**funannotate database** :white_check_mark:


## Installation

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


## An example command for the funannotate docker container

This command mount external dependencies and a database folder:

	docker run --rm -it -v $(pwd)/external:/root -v $(pwd)/database:/root/database -v $(pwd):/data reslp/funannotate check


## Installed software

**The funannotate container includes:**

funannotate 1.7.2
CodingQuarry 2.0
Trinity 2.8.6
Augustus 3.3.2
BLAT v. latest
FASTA36 36.3.8
diamond 0.9.29
GMAP 2019-09-12
minimap2 2.17
kallisto 0.46.1
Proteinortho 6.0.12
pslCDnaFilter v. latest
salmon 1.1.0
snap v. latest github
stringtie 2.0.6
tRNA-Scan SE 2.0.5
Infernal 1.1.3
trimmomatic 0.39
tantan 22
trimal 1.2rev59
PASA 2.4.1
EvidenceModeler 1.1.1
ete3 3.0.0b35
RECON 1.08
RepeatScout 1.0.6
TRF 409
rmblast 2.10.0+
RepeatMasker 4.0.7
RepeatModeler 1.0.10
tabl2asn v. latest

**Python and Python modules:**

python 2.7.17
asn1crypto 0.24.0
atomicwrites 1.3.0
attrs 19.3.0
backports.functools-lru-cache 1.6.1
biopython 1.76
certifi 2019.11.28
chardet 3.0.4
configparser 4.0.2
contextlib2 0.6.0.post1
coverage 5.0.3
cryptography 2.6.1
cycler 0.10.0
dbus-python 1.2.12
docopt 0.6.2
entrypoints 0.3
enum34 1.1.6
ete3 3.0.0b35
funannotate 1.7.2
funcsigs 1.0.2
goatools 0.9.9
idna 2.8
importlib-metadata 1.4.0
ipaddress 1.0.17
keyring 18.0.1
keyrings.alt 3.1.1
kiwisolver 1.1.0
lxml 4.4.1
matplotlib 2.2.4
more-itertools 5.0.0
natsort 6.2.0
nose 1.3.7
numpy 1.16.2
packaging 20.1
pandas 0.24.2
pathlib2 2.3.5
patsy 0.5.1
pip 18.1
pluggy 0.13.1
psutil 5.6.7
py 1.8.1
pycrypto 2.6.1
pydot 1.4.1
PyGObject 3.34.0
pyparsing 2.4.6
pytest 4.6.9
pytest-cov 2.8.1
python-dateutil 2.8.1
pytz 2019.3
pyxdg 0.25
requests 2.22.0
scandir 1.10.0
scikit-learn 0.20.4
scipy 1.2.3
seaborn 0.9.1
SecretStorage 2.3.1
setuptools 41.1.0
sip 4.19.18
six 1.12.0
statsmodels 0.11.0
subprocess32 3.5.4
urllib3 1.25.8
wcwidth 0.1.8
wget 3.2
wheel 0.32.3
xlrd 1.2.0
XlsxWriter 1.2.7
zipp 1.1.0 