#
#   Makefile - build three LinuxRT-based bzImages and root file systems:
#                  buildroot-2016.11.1 for x86_64 (64-bit)
#                  buildroot-2019.08   for x86_64 (64-bit)
#                  buildroot-2019.08   for i686   (32-bit)
#

MKDIR = mkdir -p

ASSETS-DIR = Assets
BUILDRESULTS-DIR = BuildResults
DEPENDENCIES-DIR = Dependencies

BUILDROOT-SITE-REPO-NAME   = buildroot-site
BUILDROOT-SITE-URL         = https://github.com/slaclab/buildroot-site.git
BUILDROOT-SITE-2016-BRANCH = br-2016.11-dev
BUILDROOT-SITE-2019-BRANCH = br-2019.08-dev
BUILDROOT-SITE-2016        = $(DEPENDENCIES-DIR)/buildroot-site-2016
BUILDROOT-SITE-2019        = $(DEPENDENCIES-DIR)/buildroot-site-2019

DEPENDENCIES-ITEMS = $(BUILDROOT-SITE-2016) $(BUILDROOT-SITE-2019)

BUILDROOT-2016 = buildroot-2016.11.1
BUILDROOT-2019 = buildroot-2019.08

BUILDROOT-2016-TARBALL = $(BUILDROOT-2016).tar.gz
BUILDROOT-2019-TARBALL = $(BUILDROOT-2019).tar.gz

BUILDROOT-2016-BUILD-DIR = $(BUILDRESULTS-DIR)/buildroot-2016
BUILDROOT-2019-BUILD-DIR = $(BUILDRESULTS-DIR)/buildroot-2019

BUILDROOT-2016-64-SOURCES = $(BUILDROOT-2016)-x86_64

BUILDROOT-2019-64-SOURCES = $(BUILDROOT-2019)-x86_64
BUILDROOT-2019-32-SOURCES = $(BUILDROOT-2019)-i686

BR-2016-64-DIR   = $(BUILDRESULTS-DIR)/BR-2016-64
BR-2019-64-DIR   = $(BUILDRESULTS-DIR)/BR-2019-64
BR-2019-32-DIR   = $(BUILDRESULTS-DIR)/BR-2019-32

BR-2016-64-ITEMS = $(BR-2016-64-DIR)/bzImage $(BR-2016-64-DIR)/rootfs.ext2.gz
BR-2019-64-ITEMS = $(BR-2019-64-DIR)/bzImage $(BR-2019-64-DIR)/rootfs.ext2.gz
BR-2019-32-ITEMS = $(BR-2019-32-DIR)/bzImage $(BR-2019-32-DIR)/rootfs.ext2.gz

#
#   The buildroot build process uses git to try and determine version information
#   based on information in the git repository.  However, if the buildroot-site
#   branch doesn't have a corresponding git repo, git keeps working its way up
#   the file system hierarchy - until it mistaken gets a response from the git
#   repo information for the *buildroot1* repository.  This causes the buildroot-site
#   scripts to run unnecessary 'make menuconfig' operations and derail the build
#   process.
#
#   To avoid this, the PATH variable is redefined to point to a local git-wrapper
#   that will be run in place of the system's git binary.  This prevents the
#   unnecessary/mistaken 'make menuconfig' from being run.
#

__ORIGINAL_PATH=${PATH}
__GIT_WRAPPER_DIR=$(shell pwd)/$(ASSETS-DIR)


.PHONY: all
all: $(DEPENDENCIES-ITEMS) br-2016 br-2019
	@echo "### Building all ###"

$(DEPENDENCIES-ITEMS):
	@echo "### Setting up dependencies"
	@$(MKDIR) $(DEPENDENCIES-DIR) 2>/dev/null
	@git clone $(BUILDROOT-SITE-URL) --branch $(BUILDROOT-SITE-2016-BRANCH) $(BUILDROOT-SITE-2016)
	@git clone $(BUILDROOT-SITE-URL) --branch $(BUILDROOT-SITE-2019-BRANCH) $(BUILDROOT-SITE-2019)

.PHONY: dependencies
dependencies:
	$(MAKE) $(DEPENDENCIES-ITEMS)

br-2016: $(BR-2016-64-ITEMS)
	@echo "### Building $@ ###"
	@echo ">>> __ORIGINAL_PATH=\'${ORIGINAL_PATH}\'"
	@echo ">>> __GIT_WRAPPER_DIR=\'${GIT_WRAPPER_DIR}\'"

br-2019: br-2019-64 br-2019-32
	@echo "### Building $@ ###"

br-2019-64: $(BR-2019-64-ITEMS)
	@echo "### Building $@ ###"

br-2019-32: $(BR-2019-32-ITEMS)
	@echo "### Building $@ ###"

#
#   Each of these make targets modify the PATH environment variable to avoid the
#   git 'version detection' issue described above.
#

$(BR-2016-64-ITEMS): $(BUILDROOT-2016-BUILD-DIR)
	@echo "### Building $@"
	@$(MKDIR) $(BR-2016-64-DIR)
	export PATH=${__GIT_WRAPPER_DIR}:${PATH}
	time $(MAKE) -C $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	export PATH=${__ORIGINAL_PATH}
	@cp $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/output/images/bzImage $(BR-2016-64-DIR)/bzImage
	@cp $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/output/images/rootfs.ext2.gz $(BR-2016-64-DIR)/rootfs.ext2.gz

$(BR-2019-64-ITEMS): $(BUILDROOT-2019-BUILD-DIR)
	@echo "### Building $@"
	@$(MKDIR) $(BR-2019-64-DIR)
	export PATH=${__GIT_WRAPPER_DIR}:${PATH}
	time $(MAKE) -C $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	export PATH=${__ORIGINAL_PATH}
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/output/images/bzImage $(BR-2019-64-DIR)/bzImage
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/output/images/rootfs.ext2.gz $(BR-2019-64-DIR)/rootfs.ext2.gz

$(BR-2019-32-ITEMS): $(BUILDROOT-2019-BUILD-DIR)
	@echo "### Building $@"
	@$(MKDIR) $(BR-2019-32-DIR)
	export PATH=${__GIT_WRAPPER_DIR}:${PATH}
	time $(MAKE) -C $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	export PATH=${__ORIGINAL_PATH}
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/output/images/bzImage $(BR-2019-32-DIR)/bzImage
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/output/images/rootfs.ext2.gz $(BR-2019-32-DIR)/rootfs.ext2.gz


#
#   Top-level build directories for the 2016 and 2019 buildroots, with "download" and "host" directories.
#   Each build directory gets a link to the git checkout of the corresponding "buildroot-site" branch.
#

$(BUILDROOT-2016-BUILD-DIR): $(BUILDROOT-SITE-2016)
	@echo "### Creating $@"
	@$(MKDIR) $(BUILDROOT-2016-BUILD-DIR)          2>/dev/null
	@$(MKDIR) $(BUILDROOT-2016-BUILD-DIR)/download 2>/dev/null
	@$(MKDIR) $(BUILDROOT-2016-BUILD-DIR)/host     2>/dev/null
	@tar xzf $(ASSETS-DIR)/$(BUILDROOT-2016-TARBALL) -C $(BUILDROOT-2016-BUILD-DIR)
	@mv $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016) $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	ln -s ../../../$(BUILDROOT-SITE-2016) $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/site
	pushd $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES) && \
	./site/scripts/br-installconf.sh -a x86_64                     && \
	popd

$(BUILDROOT-2019-BUILD-DIR): $(BUILDROOT-SITE-2019)
	@echo "### Creating $@"
	@$(MKDIR) $(BUILDROOT-2019-BUILD-DIR)          2>/dev/null
	@$(MKDIR) $(BUILDROOT-2019-BUILD-DIR)/download 2>/dev/null
	@$(MKDIR) $(BUILDROOT-2019-BUILD-DIR)/host     2>/dev/null
	@tar xzf $(ASSETS-DIR)/$(BUILDROOT-2019-TARBALL) -C $(BUILDROOT-2019-BUILD-DIR)
	@mv $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	ln -s ../../../$(BUILDROOT-SITE-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/site
	pushd $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES) && \
	./site/scripts/br-installconf.sh -a x86_64                     && \
	popd
	@tar xzf $(ASSETS-DIR)/$(BUILDROOT-2019-TARBALL) -C $(BUILDROOT-2019-BUILD-DIR)
	@mv $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	ln -s ../../../$(BUILDROOT-SITE-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/site
	pushd $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES) && \
	./site/scripts/br-installconf.sh -a i686                       && \
	popd


#
#   Fetch buildroot.org tarballs from the Asseti/Artifact depot (TBD)
#

###$(ASSETS-DIR)/$(BUILDROOT-2016-TARBALL):
###	@echo "### Fetching $@"
###	@$(MKDIR) $(ASSETS-DIR) 2>/dev/null
###	#bs fetch_asset $(BUILDROOT-2016-TARBALL) $(ASSETS-DIR)
###	cp /scratch/katzung/assets/$(BUILDROOT-2016-TARBALL) $(ASSETS-DIR)

###$(ASSETS-DIR)/$(BUILDROOT-2019-TARBALL):
###	@echo "### Fetching $@"
###	@$(MKDIR) $(ASSETS-DIR) 2>/dev/null
###	#bs fetch_asset $(BUILDROOT-2019-TARBALL) $(ASSETS-DIR)
###	cp /scratch/katzung/assets/$(BUILDROOT-2019-TARBALL) $(ASSETS-DIR)

#
#   Various useful additional targets
#

.PHONY: clean
clean:
	@echo "### Removing $(BUILDRESULTS-DIR)"
	@###@rm -rf $(ASSETS-DIR)
	@rm -rf $(BUILDRESULTS-DIR)

.PHONY: distclean
distclean:
	@echo "### Removing $(BUILDRESULTS-DIR)"
	@rm -rf $(BUILDRESULTS-DIR)
	### Don't want to accidentally nuke this directory...
	###@echo "### Removing $(DEPENDENCIES-DIR)"
	###@rm -rf $(DEPENDENCIES-DIR)

.PHONY: clean-br-2016
clean-br-2016:
	@rm -rf $(BR-2016-64-DIR) $(BUILDROOT-2016-BUILD-DIR)

.PHONY: clean-br-2019
clean-br-2019:
	@rm -rf $(BR-2019-64-DIR) $(BR-2019-32-DIR) $(BUILDROOT-2019-BUILD-DIR)
	
.PHONY: dev-environment
dev-environment:
	@echo "### Setting up development environment"
	@$(MAKE) dependencies
	
