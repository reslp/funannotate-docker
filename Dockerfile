FROM ubuntu:19.10 as build

MAINTAINER <philipp.resl@uni-graz.at>

WORKDIR /software
ARG DEBIAN_FRONTEND=noninteractive

#these two layers should take care of all the python and perl dependencies:
#removed python-numpy from apt-get
RUN apt-get update && \
	apt-get -y install wget python3 python3-pip && \
	apt-get install -y bioperl cpanminus && \ 
	apt-get install -y --no-install-recommends cmake git libboost-iostreams-dev zlib1g-dev libgsl-dev libboost-graph-dev libboost-all-dev libsuitesparse-dev liblpsolve55-dev libsqlite3-dev libgsl-dev libboost-graph-dev libboost-all-dev libsuitesparse-dev liblpsolve55-dev libmysql++-dev libbamtools-dev libboost-all-dev bamtools default-jre hisat2 mysql-server mysql-client libdbd-mysql-perl python-qt4 python3-lxml python3-six trimmomatic tantan && \
	apt-get install -y locales-all && \
	apt-get install -y elfutils libdw1 libdw-dev && \
	cpanm File::Which Hash::Merge JSON Logger::Simple Parallel::ForkManager Scalar::Util::Numeric Text::Soundex DBI && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*
	

#Software dependencies:
#CodingQuarry
RUN wget -O CodingQuarry_v2.0.tar.gz https://sourceforge.net/projects/codingquarry/files/CodingQuarry_v2.0.tar.gz/download?use_mirror=svwh#z && \ 
	tar xvfz CodingQuarry_v2.0.tar.gz && \
	cd CodingQuarry_v2.0 && \
	make

#Trinity
RUN wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.8.6/trinityrnaseq-v2.8.6.FULL.tar.gz && \
	tar xvfz trinityrnaseq-v2.8.6.FULL.tar.gz && \
	cd trinityrnaseq-v2.8.6 && \
	make


#Augustus
# for some reason it does not work with ubuntus augustus package. also bam2wig compilation does not work.
# this is to remove it before make:
RUN wget https://github.com/Gaius-Augustus/Augustus/archive/3.3.2.tar.gz && \
	tar xvfz 3.3.2.tar.gz && cd Augustus-3.3.2/auxprogs && \
	sed -i 's/cd bam2wig; make;/#cd bam2wig; make;/g' Makefile && \
	sed -i 's/cd bam2wig; make clean;/#cd bam2wig; make clean;/g' Makefile && \
	cd .. && \
	make


#BLAT
RUN mkdir blat && \
 	cd blat && \
 	wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat && \
 	chmod 755 ./blat


#FASTA36
RUN wget http://faculty.virginia.edu/wrpearson/fasta/fasta36/fasta-36.3.8g.tar.gz && \
	tar xvfz fasta-36.3.8g.tar.gz && cd fasta-36.3.8g/src && \
	make -f ../make/Makefile.linux_sse2 all && \
	cp ../bin/fasta36 /usr/local/bin/fasta

#diamond
RUN wget https://github.com/bbuchfink/diamond/releases/download/v2.0.4/diamond-linux64.tar.gz && \
	tar xvfz diamond-linux64.tar.gz && \
	mv diamond /usr/local/bin

#glimmerhmm
# this is currently commented out, it seems to halt the predict step of funannotate for some strange reason
#RUN wget https://ccb.jhu.edu/software/glimmerhmm/dl/GlimmerHMM-3.0.4.tar.gz && \
#	 tar xvfz GlimmerHMM-3.0.4.tar.gz && \
#	 cd GlimmerHMM/bin && \
#	 cp glimmerhmm_linux_x86_64 glimmerhmm
#ENV PATH="/software/GlimmerHMM/bin:$PATH"
#ENV PATH="/software/GlimmerHMM/train:$PATH"

#GMAP
RUN wget http://research-pub.gene.com/gmap/src/gmap-gsnap-2019-09-12.tar.gz && \
	tar xvfz gmap-gsnap-2019-09-12.tar.gz && \
	cd gmap-2019-09-12/ && ./configure && \
	make



#minimap2
RUN wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2 && \
	tar -jxvf minimap2-2.17_x64-linux.tar.bz2


#kallisto
RUN wget https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz && \
	tar xvfz kallisto_linux-v0.46.1.tar.gz


#Proteinortho
RUN wget https://gitlab.com/paulklemm_PHD/proteinortho/-/archive/v6.0.12/proteinortho-v6.0.12.tar.gz && \
	tar xvfz proteinortho-v6.0.12.tar.gz


#pslCDnaFilter
# this does currently not select a specific version!! It uses always the latest version
RUN wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/pslCDnaFilter && \
	chmod 755 pslCDnaFilter && \
	mv pslCDnaFilter /usr/local/bin

#salmon
RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v1.1.0/salmon-1.1.0_linux_x86_64.tar.gz && \
	tar xvfz salmon-1.1.0_linux_x86_64.tar.gz


#snap
RUN git clone https://github.com/KorfLab/SNAP.git && \
	cd SNAP && \
	git reset --soft daf76badb477d22c08f2628117c00e057bf95ccf && \
	make


#stringtie
RUN wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.0.6.Linux_x86_64.tar.gz && \
	tar xvfz stringtie-2.0.6.Linux_x86_64.tar.gz


#tRNA-Scan
RUN wget http://trna.ucsc.edu/software/trnascan-se-2.0.5.tar.gz && \
	tar xvfz trnascan-se-2.0.5.tar.gz && \
	cd tRNAscan-SE-2.0 && \
	./configure && \
	make && \
	make install 
	
#Infernal
RUN wget http://eddylab.org/infernal/infernal-1.1.3-linux-intel-gcc.tar.gz && \
	tar xvfz infernal-1.1.3-linux-intel-gcc.tar.gz && \
	cd infernal-1.1.3-linux-intel-gcc/binaries && \
	cp * /usr/local/bin

#tantan
#RUN apt-get update -y && apt-get install -y tantan

#trimal
RUN wget https://github.com/scapella/trimal/archive/v1.4.1.tar.gz && \
	tar xvfz v1.4.1.tar.gz && \
	cd trimal-1.4.1/source && \
	make


#trimmomatic
# trimmomatic needs an executable called trimmomatic in the PATH. This is to set it up.
RUN touch trimmomatic && \
	echo '#!/bin/bash' >> trimmomatic && \
	echo 'java -jar /usr/share/java/trimmomatic-0.39.jar "$@"' >> trimmomatic && \
	chmod 755 trimmomatic && \
	mv trimmomatic /usr/local/bin

#PASA Pipeline
#I am not sure of this contains everything. this will have to be tested when funannotate is run
RUN wget https://github.com/PASApipeline/PASApipeline/releases/download/pasa-v2.4.1/PASApipeline.v2.4.1.FULL.tar.gz && \
	tar xvfz PASApipeline.v2.4.1.FULL.tar.gz && \
	cd PASApipeline.v2.4.1 && \
	make


#Evidence Modeler
RUN wget https://github.com/EVidenceModeler/EVidenceModeler/archive/v1.1.1.tar.gz && \
	tar xvfz v1.1.1.tar.gz




####RepeatModeler - several dependcies needed for that
# RECON
RUN wget http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz && \
	tar xvfz RECON-1.08.tar.gz && \
	cd RECON-1.08/src && \
	make && make install && \
	sed -i -e 's#\$path = \"\";#\$path = \"/software/RECON-1.08/bin\";#' /software/RECON-1.08/scripts/recon.pl
# RepeatScout
RUN wget http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz && \
	tar xvfz RepeatScout-1.0.6.tar.gz && \
	cd RepeatScout-1.0.6 && \
	make && \
	cp RepeatScout build_lmer_table /usr/local/bin
# TRF
RUN wget http://tandem.bu.edu/trf/downloads/trf409.linux64 && \
	chmod +x trf409.linux64 && \
	mv trf409.linux64 /usr/local/bin/trf
# rmblast
RUN wget http://www.repeatmasker.org/rmblast-2.9.0+-p2-x64-linux.tar.gz && \
	tar xvfz rmblast-2.9.0+-p2-x64-linux.tar.gz
#Repeatmasker
# fixing the perl paths is from: https://github.com/chrishah/maker-docker/blob/master/repeatmasker/Dockerfile
RUN wget http://www.repeatmasker.org/RepeatMasker-open-4-0-7.tar.gz && \
	tar xvfz RepeatMasker-open-4-0-7.tar.gz && \
	sed -i -e 's#TRF_PRGM = ""#TRF_PRGM = \"/usr/local/bin/trf\"#g' RepeatMasker/RepeatMaskerConfig.tmpl && \
	sed -i -e 's#DEFAULT_SEARCH_ENGINE = \"crossmatch\"#DEFAULT_SEARCH_ENGINE = \"ncbi\"#g' RepeatMasker/RepeatMaskerConfig.tmpl && \
	sed -i -e 's#RMBLAST_DIR   = \"/usr/local/rmblast\"#RMBLAST_DIR   = \"/software/rmblast-2.9.0-p2/bin\"#g' RepeatMasker/RepeatMaskerConfig.tmpl && \
	sed -i -e 's#REPEATMASKER_DIR          = \"\$FindBin::RealBin\"#REPEATMASKER_DIR          = \"/software/RepeatMasker\"#g' RepeatMasker/RepeatMaskerConfig.tmpl && \
	cp RepeatMasker/RepeatMaskerConfig.tmpl RepeatMasker/RepeatMaskerConfig.pm && \
	perl -i -0pe 's/^#\!.*perl.*/#\!\/usr\/bin\/env perl/g' \
	RepeatMasker/RepeatMasker \
	RepeatMasker/DateRepeats \
	RepeatMasker/ProcessRepeats \
	RepeatMasker/RepeatProteinMask \
	RepeatMasker/DupMasker \
	RepeatMasker/util/queryRepeatDatabase.pl \
	RepeatMasker/util/queryTaxonomyDatabase.pl \
	RepeatMasker/util/rmOutToGFF3.pl \
	RepeatMasker/util/rmToUCSCTables.pl
	
# uses the method by chrishah (https://github.com/chrishah/maker-docker/tree/master/repeatmasker) to build repeatmasker librariers without interactive config.
ADD rebuild /software/RepeatMasker
RUN perl /software/RepeatMasker/rebuild
	
#Repeatmodeler
# fixing the perl paths is from: https://github.com/chrishah/maker-docker/blob/master/repeatmasker/Dockerfile
RUN wget http://www.repeatmasker.org/RepeatModeler/RepeatModeler-open-1.0.11.tar.gz && \
	tar xvfz RepeatModeler-open-1.0.11.tar.gz && \
	cd RepeatModeler-open-1.0.11 && \
	perl -i -0pe 's/^#\!.*/#\!\/usr\/bin\/env perl/g' \
	configure \
	BuildDatabase \
	Refiner \
	RepeatClassifier \
	RepeatModeler \
	TRFMask \
	util/dfamConsensusTool.pl \
	util/renameIds.pl \
	util/viewMSA.pl && \
	sed -i -e 's#RECON_DIR = \"/usr/local/bin\"#RECON_DIR = \"/software/RECON-1.08/bin\"#g' RepModelConfig.pm.tmpl && \
	sed -i -e 's#RSCOUT_DIR = \"/usr/local/bin/\"#RSCOUT_DIR = \"/software/RepeatScout-1.0.6\"#g' RepModelConfig.pm.tmpl && \
	sed -i -e 's#RMBLAST_DIR      = \"/usr/local/rmblast\"#RMBLAST_DIR      = \"/software/rmblast-2.9.0-p2/bin\"#g' RepModelConfig.pm.tmpl && \
	sed -i -e 's#REPEATMASKER_DIR = \"/usr/local/RepeatMasker\"#REPEATMASKER_DIR = \"/software/RepeatMasker\"#g' RepModelConfig.pm.tmpl && \
	cp RepModelConfig.pm.tmpl RepModelConfig.pm
		

# code for repeatmodeler 2 can be used when funannotate supports it.
#RUN wget http://www.repeatmasker.org/RepeatModeler/RepeatModeler-2.0.1.tar.gz && \
# 	tar xvfz RepeatModeler-2.0.1.tar.gz && \
# 	cd RepeatModeler-2.0.1 && \
# 	perl -i -0pe 's/^#\!.*/#\!\/usr\/bin\/env perl/g' \
# 	configure \
# 	BuildDatabase \
# 	Refiner \
# 	RepeatClassifier \
# 	RepeatModeler \
# 	TRFMask \
# 	util/dfamConsensusTool.pl \
# 	util/renameIds.pl \
# 	util/viewMSA.pl && \
# 	sed -i -e 's#/usr/local/RECON#/software/RECON-1.08/bin#g' RepModelConfig.pm && \
# 	sed -i -e 's#/usr/local/RepeatScout-1.0.6#/software/RepeatScout-1.0.6#g' RepModelConfig.pm && \
# 	sed -i -e 's#/usr/local/rmblast/bin#/software/rmblast-2.9.0-p2/bin#g' RepModelConfig.pm && \
# 	sed -i -e 's#/usr/local/RepeatMasker#/software/RepeatMasker#g' RepModelConfig.pm && \
# 	sed -i -e 's#/usr/local/bin/trf409.linux64#/usr/local/bin/trf#g' RepModelConfig.pm
# 	#cp RepModelConfig.pm.tmpl RepModelConfig.pm
		

#tbl2asn
RUN wget ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux64.tbl2asn.gz && \
	gunzip linux64.tbl2asn.gz && \
	mv linux64.tbl2asn /usr/local/bin/tbl2asn && \
	chmod 755 /usr/local/bin/tbl2asn

RUN rm *.gz

#export variables:
# to correct signalps path
# sed -i -e 's#$ENV{SIGNALP} = *+#$ENV{SIGNALP} = \/root\/signalp-4.1#g' /root/signalp-4.1/signalp

#glimmerhmm
# this uses basically the same fix as in the bioconda recipe for glimmerhmm:
# https://github.com/bioconda/bioconda-recipes/blob/master/recipes/glimmerhmm/build.sh

RUN wget --no-check-certificate https://ccb.jhu.edu/software/glimmerhmm/dl/GlimmerHMM-3.0.4.tar.gz && \
	tar xvfz GlimmerHMM-3.0.4.tar.gz && \
	cd GlimmerHMM && \
	sed -i.bak "s|^escoreSTOP2:|scoreSTOP2:|g" train/makefile && \
	sed -i.bak "s|^rfapp:|erfapp:|g" train/makefile && \
	sed -i.bak "s| trainGlimmerHMM||g" train/makefile && \
	sed -i.bak "s|all:    build-icm|all:    misc.o build-icm.o build-icm-noframe.o build-icm|g" train/makefile && \
	sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' train/trainGlimmerHMM && \
	sed -i.bak 's|$FindBin::Bin;|"/software/glimmerhmm/glimmerhmm/train";|g' train/trainGlimmerHMM && \
	sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/glimmhmm.pl && \
	mkdir -p /software/glimmerhmm && \
	mkdir -p /software/glimmerhmm/bin && \
	mkdir -p /software/glimmerhmm/glimmerhmm && \
	mkdir -p /software/glimmerhmm/glimmerhmm/train && \
	make -C sources && \
	make -C train clean && make -C train all && \
	cp bin/glimmhmm.pl /software/glimmerhmm/bin/ && \
	cp sources/glimmerhmm /software/glimmerhmm/bin/ && \
	cp train/trainGlimmerHMM /software/glimmerhmm/bin/ && \
	cp train/build-icm /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/build-icm-noframe /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/build1 /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/build2 /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/erfapp /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/falsecomp /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/findsites /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/karlin /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/score /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/score2 /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/scoreATG /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/scoreATG2 /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/scoreSTOP /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/scoreSTOP2 /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/splicescore /software/glimmerhmm/glimmerhmm/train/ && \
	cp train/*.pm /software/glimmerhmm/glimmerhmm/train/  && \
	cp -R trained_dir /software/glimmerhmm/glimmerhmm/ && \
	chmod a+x /software/glimmerhmm/bin/* && \
	chmod a+r /software/glimmerhmm/bin/* && \
	chmod a+r /software/glimmerhmm/glimmerhmm/trained_dir && \
	chmod a+x /software/glimmerhmm/glimmerhmm/trained_dir && \
	chmod a+r /software/glimmerhmm/glimmerhmm/train/* && \
	chmod a+x /software/glimmerhmm/glimmerhmm/train/* && \
	chmod a+x /software/glimmerhmm/glimmerhmm/trained_dir/* && \
	chmod a+w /software/glimmerhmm/glimmerhmm/trained_dir/*/* && \
	chmod a+r /software/glimmerhmm/glimmerhmm/trained_dir/*/*
# the permission changes are necessary for singularity, otherwise all files can only be accessed by root

#install iqtree

RUN apt-get update && \
	apt-get install -y iqtree && \
	apt-get autoremove -y && \
	apt-get clean -y


#ete3
# this installs a slightly older version, but the pyqt issue does not occur with it.
RUN pip3 install --upgrade ete3

RUN pip3 install biopython==1.77

# with a small modification to handle the log file move problem in remote in singularity
RUN pip3 install funannotate==1.8.1

#sed -i -e 's/os.rename/#os.rename/g' /usr/local/lib/python2.7/dist-packages/funannotate/remote.py && \
#awk 'NR==301{print "\tshutil.copy(log_name, os.path.join(outputdir, '\''logfiles'\'', log_name))"}NR==301{print "\tos.remove(log_name)"}1' /usr/local/lib/python2.7/dist-packages/funannotate/remote.py > /usr/local/lib/python2.7/dist-packages/funannotate/tmp && mv /usr/local/lib/python2.7/dist-packages/funannotate/tmp /usr/local/lib/python2.7/dist-packages/funannotate/remote.py && \
#sed -i '1405d' /usr/local/lib/python2.7/dist-packages/funannotate/annotate.py && \
#sed -i '1404d' /usr/local/lib/python2.7/dist-packages/funannotate/annotate.py && \
#awk 'NR==1404{print "\tshutil.copy(log_name, os.path.join(outputdir, '\''logfiles'\'', '\''funannotate-annotate.log'\''))"}NR==1404{print "\tos.remove(log_name)"}1' /usr/local/lib/python2.7/dist-packages/funannotate/annotate.py > /usr/local/lib/python2.7/dist-packages/funannotate/tmp && mv /usr/local/lib/python2.7/dist-packages/funannotate/tmp /usr/local/lib/python2.7/dist-packages/funannotate/annotate.py && \
#pip uninstall -y matplotlib numpy seaborn pandas statsmodels && \
#pip install matplotlib==2.0.2 numpy==1.16.5 seaborn==0.9.0 pandas==0.24.2 statsmodels==0.10.2
#apt-get update && apt-get install -y python-matplotlib python-numpy
# the lines above uninstalling and installing matplotlib are experimental in an attempt to fix a problem with funannotate compare, originally they are not present	




FROM scratch 

MAINTAINER <philipp.resl@uni-graz.at>

COPY --from=build / /

ENV RMBLAST_DIR=/software/rmblast-2.9.0-p2/bin
ENV RECON_DIR=/software/RECON-1.08/bin
ENV PATH="/software/RepeatMasker:$PATH"
ENV PATH="/software/RepeatModeler-open-1.0.11:$PATH"
ENV REPEATMASKER_DIR="/software/RepeatMasker"

ENV PATH="/software/glimmerhmm/bin:$PATH"
#ENV PATH="/software/glimmerhmm/train:$PATH"

ENV QUARRY_PATH="/software/CodingQuarry_v2.0/QuarryFiles"
ENV PATH="/software/CodingQuarry_v2.0:$PATH"
ENV TRINITY_HOME="/software/trinityrnaseq-v2.8.6"
ENV PATH="/software/trinityrnaseq-v2.8.6:$PATH"
ENV PATH="/software/gmap-2019-09-12/src:$PATH"
ENV PATH="/software/minimap2-2.17_x64-linux:$PATH"
ENV PATH="/software/kallisto:$PATH"
ENV PATH="/software/proteinortho-v6.0.12:$PATH"
ENV PATH="/software/salmon-latest_linux_x86_64/bin:$PATH"
ENV ZOE="/software/SNAP/Zoe"
ENV PATH="/software/SNAP:$PATH"
ENV PATH="/software/stringtie-2.0.6.Linux_x86_64:$PATH"
ENV PATH="/software/trimal-1.4.1/source:$PATH"
ENV PASAHOME="/software/PASApipeline.v2.4.1"
ENV EVM_HOME="/software/EVidenceModeler-1.1.1"
ENV AUGUSTUS_CONFIG_PATH="/software/Augustus-3.3.2/config"
ENV PATH="/software/Augustus-3.3.2/bin:$PATH"
ENV PATH="/software/blat/:$PATH"

# set workdir and set paths to external dependencies
WORKDIR /data
ENV PATH="/data/external/gm_et_linux_64:$PATH"
ENV GENEMARK_PATH="/data/external/gm_et_linux_64"
ENV PATH="/data/external/signalp-4.1:$PATH"
ENV FUNANNOTATE_DB="/data/database"
ENV HOME="/data"

ENTRYPOINT ["funannotate"]
CMD ["-v"]


