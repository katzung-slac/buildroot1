#
#
#

ASSETS = Assets
BUILDRESULTS = BuildResults

BUILDROOT-SITE-REPO-NAME   = buildroot-site
BUILDROOT-SITE-URL         = https://github.com/slaclab/buildroot-site.git
BUILDROOT-SITE-2016-BRANCH = br-2016.11-dev
BUILDROOT-SITE-2019-BRANCH = br-2019.08-dev

BUILDROOT-2016 = buildroot-2016.11.1
BUILDROOT-2019 = buildroot-2019.08

BUILDROOT-2016-TARBALL = $(BUILDROOT-2016).tar.gz
BUILDROOT-2019-TARBALL = $(BUILDROOT-2019).tar.gz

BUILDROOT-2016-BUILD-DIR = $(BUILDRESULTS)/buildroot-2016
BUILDROOT-2019-BUILD-DIR = $(BUILDRESULTS)/buildroot-2019

BUILDROOT-2016-64-SOURCES = $(BUILDROOT-2016)-x86_64

BUILDROOT-2019-64-SOURCES = $(BUILDROOT-2019)-x86_64
BUILDROOT-2019-32-SOURCES = $(BUILDROOT-2019)-i686

BR-2016-64-ITEMS = $(BUILDRESULTS)/
BR-2019-64-ITEMS = 
BR-2019-32-ITEMS = 

all: $(BUILDRESULTS)/BZIMAGE_2016_64 $(BUILDRESULTS)/BZIMAGE_2019_64 $(BUILDRESULTS)/BZIMAGE_2019_32
	@echo "### Building all ###"


$(BUILDRESULTS)/BZIMAGE_2016_64: $(BUILDROOT-2016-BUILD-DIR)
	@echo "### Building $@"
	time make -C $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	@touch $@

$(BUILDRESULTS)/BZIMAGE_2019_64: $(BUILDROOT-2019-BUILD-DIR)
	@echo "### Building $@"
	time make -C $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	@touch $@

$(BUILDRESULTS)/BZIMAGE_2019_32: $(BUILDROOT-2019-BUILD-DIR)
	@echo "### Building $@"
	time make -C $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	@touch $@



#
#   Top-level build directories for the 2016 and 2019 buildroots, with "download" and "host" directories.
#   In addition, a git checkout of "buildroot-site" with the corresponding branches are performed as well.
#

$(BUILDROOT-2016-BUILD-DIR):
	@echo "### Creating $@"
	@mkdir -p $(BUILDROOT-2016-BUILD-DIR)          2>/dev/null
	@mkdir -p $(BUILDROOT-2016-BUILD-DIR)/download 2>/dev/null
	@mkdir -p $(BUILDROOT-2016-BUILD-DIR)/host     2>/dev/null
	@git clone $(BUILDROOT-SITE-URL) --branch $(BUILDROOT-SITE-2016-BRANCH) $(BUILDROOT-2016-BUILD-DIR)/site-top-2016
	@tar xzf $(ASSETS)/$(BUILDROOT-2016-TARBALL) -C $(BUILDROOT-2016-BUILD-DIR)
	@mv $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016) $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	ln -s ../$(BUILDROOT-SITE-REPO-NAME) $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/site
	pushd $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES) ; \
	./site/scripts/br-installconf.sh -a x86_64                     ; \
	popd

$(BUILDROOT-2019-BUILD-DIR):
	@echo "### Creating $@"
	@mkdir -p $(BUILDROOT-2019-BUILD-DIR)          2>/dev/null
	@mkdir -p $(BUILDROOT-2019-BUILD-DIR)/download 2>/dev/null
	@mkdir -p $(BUILDROOT-2019-BUILD-DIR)/host     2>/dev/null
	@git clone $(BUILDROOT-SITE-URL) --branch $(BUILDROOT-SITE-2019-BRANCH) $(BUILDROOT-2019-BUILD-DIR)/site-top-2019
	@tar xzf $(ASSETS)/$(BUILDROOT-2019-TARBALL) -C $(BUILDROOT-2019-BUILD-DIR)
	@mv $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	ln -s ../$(BUILDROOT-SITE-REPO-NAME) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/site
	pushd $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES) ; \
	./site/scripts/br-installconf.sh -a x86_64                     ; \
	popd
	@tar xzf $(ASSETS)/$(BUILDROOT-2019-TARBALL) -C $(BUILDROOT-2019-BUILD-DIR)
	@mv $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	ln -s ../$(BUILDROOT-SITE-REPO-NAME) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/site
	pushd $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES) ; \
	./site/scripts/br-installconf.sh -a i686                       ; \
	popd


#
#   Fetch buildroot.org tarballs from the Asset depot
#

###$(ASSETS)/$(BUILDROOT-2016-TARBALL): $(ASSETS)
###	@echo "### Fetching $@"
###	#bs fetch_asset $(BUILDROOT-2016-TARBALL) $(ASSETS)
###	cp /scratch/katzung/assets/$(BUILDROOT-2016-TARBALL) $(ASSETS)

###$(ASSETS)/$(BUILDROOT-2019-TARBALL): $(ASSETS)
###	@echo "### Fetching $@"
###	#bs fetch_asset $(BUILDROOT-2019-TARBALL) $(ASSETS)
###	cp /scratch/katzung/assets/$(BUILDROOT-2019-TARBALL) $(ASSETS)

#
#   Create necessary directory paths
#

###$(ASSETS):
###	@echo "### Creating $@ directory"
###	mkdir $(ASSETS) 2>/dev/null

###$(BUILDRESULTS):
###	@echo "### Creating $@ directory"
###	@mkdir $(BUILDRESULTS) 2>/dev/null

#
#   Various useful additional targets
#

.PHONY: clean
clean:
	@echo "### Removing $(BUILDRESULTS)"
	@###@rm -rf $(ASSETS)
	@rm -rf $(BUILDRESULTS)

