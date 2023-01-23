FROM rocker/tidyverse:4.2.2

# setup workdir
WORKDIR /home/rstudio

# set the MRAN date to retrieve packages from this daily snapshot
ENV MRAN_BUILD_DATE=2023-01-23
ENV ROOT=true
# disable authentication
ENV DISABLE_AUTH=true

# install dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \ 
    libssl-dev \ 
	libxt6 \
	curl \
	gdebi-core


ARG QUARTO_VERSION="1.3.56"
RUN curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb

# Set user to rstudio to install packages as 'rstudio' user
USER rstudio
# Install R package dependencies
RUN install2.r -r https://cran.microsoft.com/snapshot/${MRAN_BUILD_DATE} \
	--error \
	bookdown \
	markdown \
	pacman \
	kableExtra \
	tinytex 

# Install Tinytex via quarto
# As we run this command as rstudio user, TinyTex binaries will be located at:
# /home/rstudio/.TinyTeX/bin/x86_64-linux/
RUN quarto install tool tinytex
# Add the tinytex binaries to PATH
ENV PATH="${PATH}:/home/rstudio/.TinyTeX/bin/x86_64-linux/"

# Set user to root to enable clean start of r-server
USER root
