PREFIX:=/usr/local

install:
	ln -s $(realpath cumulus.sh) ${PREFIX}/bin/cumulus
	chmod +x ${PREFIX}/bin/cumulus
