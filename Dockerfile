FROM reslp/mamba:0.5.3

RUN conda config --add channels defaults && \
	conda config --add channels bioconda && \
	conda config --add channels conda-forge && \
	mamba install -y funannotate=1.8.3 "python>=3.6,<3.9" "augustus=3.3" "trinity==2.8.5" "evidencemodeler==1.1.1" "pasa==2.4.1" "codingquarry==2.0"


WORKDIR /software

RUN apt-get update && apt-get install -y build-essential
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

#tRNA-Scan
RUN wget http://trna.ucsc.edu/software/trnascan-se-2.0.5.tar.gz && \
	tar xvfz trnascan-se-2.0.5.tar.gz && \
	cd tRNAscan-SE-2.0 && \
	./configure && \
	make && \
	make install 

# set paths specific to funannotate installation
ENV EVM_HOME="/opt/conda/opt/evidencemodeler-1.1.1"
ENV TRINITYHOME="/opt/conda/opt/trinity-2.8.5"
ENV QUARRY_PATH="/opt/conda/opt/codingquarry-2.0/QuarryFiles"
ENV ZOE="/opt/conda/bin/snap"
ENV PASAHOME="/opt/conda/opt/pasa-2.4.1"
ENV AUGUSTUS_CONFIG_PATH="/opt/conda/config"

# set path specific to repeatmasker and repeatmodeler
ENV RMBLAST_DIR=/software/rmblast-2.9.0-p2/bin
ENV RECON_DIR=/software/RECON-1.08/bin
ENV PATH="/software/RepeatMasker:$PATH"
ENV PATH="/software/RepeatModeler-open-1.0.11:$PATH"
ENV REPEATMASKER_DIR="/software/RepeatMasker"

# set workdir and set paths to external dependencies which can be used with bindpoints
WORKDIR /data
ENV PATH="/data/external/gm_et_linux_64:$PATH"
ENV GENEMARK_PATH="/data/external/gm_et_linux_64"
ENV PATH="/data/external/signalp-4.1:$PATH"
ENV FUNANNOTATE_DB="/data/database"
ENV HOME="/data"