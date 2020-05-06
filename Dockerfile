FROM abeaude/seurat-v3:3.6.3
ENV PATH /opt/conda/bin:$PATH

## And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -y -q --no-install-recommends install \
  bzip2 \
  mercurial \
  subversion \
  && apt-get clean 

  # Python/Anaconda part
  # For the momen uses py3.6
  # Environment detection is hardcoded in reticulate package, I will use one of this path to
  # be detected by reticulate
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /miniconda && \
    rm ~/miniconda.sh && \
    ln -s /miniconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /miniconda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /miniconda/ -follow -type f -name '*.js.map' -delete && \
    /miniconda/bin/conda clean -a -y

# R part
RUN R -e "BiocManager::install(c('made4','SingleR', 'BUSpaRse', 'DropletUtils', 'scater', 'scran', 'scDblFinder', 'scds','scBFA', 'celda', 'fgsea'),ask=FALSE, quiet = TRUE)" \
  && install2.r --error -s --deps TRUE --ncpus 5 \
	tensorflow \
	clustree \
	UpSetR \
	furrr \
	doParallel \
	entropy 

	
# Setup Tensorflow
RUN R -e "tensorflow::install_tensorflow(method = 'conda', extra_packages='tensorflow-probability', version = '2.1.0',envname = 'r-tensorflow')"

RUN installGithub.r rnabioco/clustifyR Irrationone/cellassign
  
