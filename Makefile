#
#   Makefile - build three LinuxRT-based bzImages and root file systems:
#                  buildroot-2016.11.1 for x86_64 (64-bit)
#                  buildroot-2019.08   for x86_64 (64-bit)
#                  buildroot-2019.08   for i686   (32-bit)
#

BUILDROOT-ORG-DIR = buildroot.org
BUILDRESULTS-DIR  = BuildResults
DEPENDENCIES-DIR  = Dependencies
TOOLS-DIR = tools

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
#   Create all the required directories in advance
#

REQUIRED_DIRS = $(DEPENDENCIES-DIR) $(BR-2016-64-DIR) $(BR-2019-64-DIR) $(BR-2019-32-DIR) \
		$(BUILDROOT-2016-BUILD-DIR)/download $(BUILDROOT-2016-BUILD-DIR)/host     \
		$(BUILDROOT-2019-BUILD-DIR)/download $(BUILDROOT-2019-BUILD-DIR)/host

__MKDIRS := $(shell for d in $(REQUIRED_DIRS);               \
		do                                           \
		  [[ -d $$d ]] || mkdir -p $$d 2>/dev/null ; \
		done )

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

__GIT_WRAPPER_DIR=$(shell pwd)/$(TOOLS-DIR)
__GIT_WRAPPER_PATH=${__GIT_WRAPPER_DIR}:${PATH}


.PHONY: all
all: $(DEPENDENCIES-ITEMS) br-2016 br-2019
	@echo "### Building all ###"

$(DEPENDENCIES-ITEMS):
	@echo "### Setting up dependencies"
	git clone $(BUILDROOT-SITE-URL) --branch $(BUILDROOT-SITE-2016-BRANCH) $(BUILDROOT-SITE-2016)
	git clone $(BUILDROOT-SITE-URL) --branch $(BUILDROOT-SITE-2019-BRANCH) $(BUILDROOT-SITE-2019)

.PHONY: dependencies
dependencies:
	$(MAKE) $(DEPENDENCIES-ITEMS)

br-2016: $(BR-2016-64-ITEMS) $(DEPENDENCIES-ITEMS)
	@echo "### Building $@ ###"
	@echo ">>> \$PATH=\'${PATH}\'"
	@echo ">>> __GIT_WRAPPER_PATH=\'${__GIT_WRAPPER_PATH}\'"

br-2019: br-2019-64 br-2019-32
	@echo "### Building $@ ###"

br-2019-64: $(BR-2019-64-ITEMS) $(DEPENDENCIES-ITEMS)
	@echo "### Building $@ ###"

br-2019-32: $(BR-2019-32-ITEMS) $(DEPENDENCIES-ITEMS)
	@echo "### Building $@ ###"

#
#   Each of these make targets modify the PATH environment variable to avoid the
#   git 'version detection' issue described above.
#

$(BR-2016-64-ITEMS): $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	@echo "### Building $@"
	PATH=$(__GIT_WRAPPER_PATH) time $(MAKE) -C $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	@cp $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/output/images/bzImage $(BR-2016-64-DIR)/bzImage
	@cp $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/output/images/rootfs.ext2.gz $(BR-2016-64-DIR)/rootfs.ext2.gz

$(BR-2019-64-ITEMS): $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	@echo "### Building $@"
	PATH=$(__GIT_WRAPPER_PATH) time $(MAKE) -C $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/output/images/bzImage $(BR-2019-64-DIR)/bzImage
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/output/images/rootfs.ext2.gz $(BR-2019-64-DIR)/rootfs.ext2.gz

$(BR-2019-32-ITEMS): $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	@echo "### Building $@"
	PATH=$(__GIT_WRAPPER_PATH) time $(MAKE) -C $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/output/images/bzImage $(BR-2019-32-DIR)/bzImage
	@cp $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/output/images/rootfs.ext2.gz $(BR-2019-32-DIR)/rootfs.ext2.gz


#
#   Top-level build directories for the 2016 and 2019 buildroots, with "download" and "host" directories.
#   Each build directory gets a link to the git checkout of the corresponding "buildroot-site" branch.
#

$(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES): $(BUILDROOT-SITE-2016)
	@echo "### Creating $@"
	@tar xzf $(BUILDROOT-ORG-DIR)/$(BUILDROOT-2016-TARBALL) -C $(BUILDROOT-2016-BUILD-DIR)
	@mv $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016) $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)
	ln -s ../../../$(BUILDROOT-SITE-2016) $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)/site
	cd $(BUILDROOT-2016-BUILD-DIR)/$(BUILDROOT-2016-64-SOURCES)  &&  PATH=$(__GIT_WRAPPER_PATH) ./site/scripts/br-installconf.sh -a x86_64

$(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES): $(BUILDROOT-SITE-2019)
	@echo "### Creating $@"
	@tar xzf $(BUILDROOT-ORG-DIR)/$(BUILDROOT-2019-TARBALL) -C $(BUILDROOT-2019-BUILD-DIR)
	@mv $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)
	ln -s ../../../$(BUILDROOT-SITE-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)/site
	cd $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-64-SOURCES)  &&  PATH=$(__GIT_WRAPPER_PATH) ./site/scripts/br-installconf.sh -a x86_64
	@tar xzf $(BUILDROOT-ORG-DIR)/$(BUILDROOT-2019-TARBALL) -C $(BUILDROOT-2019-BUILD-DIR)
	@mv $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)
	ln -s ../../../$(BUILDROOT-SITE-2019) $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)/site
	cd $(BUILDROOT-2019-BUILD-DIR)/$(BUILDROOT-2019-32-SOURCES)  &&  PATH=$(__GIT_WRAPPER_PATH) ./site/scripts/br-installconf.sh -a i686

#
#   Various useful additional targets
#

.PHONY: clean
clean:
	@echo "### Removing $(BUILDRESULTS-DIR)"
	@rm -rf $(BUILDRESULTS-DIR)

.PHONY: distclean
distclean:
	@echo "### Removing $(BUILDRESULTS-DIR)"
	@rm -rf $(BUILDRESULTS-DIR)
	@echo "### Removing $(DEPENDENCIES-DIR)"
	@rm -rf $(DEPENDENCIES-DIR)

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
	
.PHONY: help
help:
	@echo ""
	@echo "buildroot1 make targets:"
	@echo ""
	@echo "    all               # 2016-64, 2019-64 & -32 buildroots (default)"
	@echo ""
	@echo "    br-2016           # 2016 buildroot  (64 bit)"
	@echo "    br-2019           # 2019 buildroots (64 & 32 bit)"
	@echo "    br-2019-32        # 2019 buildroot  (32 bit)"
	@echo "    br-2019-64        # 2019 buildroot  (64 bit)"
	@echo ""
	@echo "    clean             # delete BuildResults directory"
	@echo "    distclean         # delete BuildResults and Dependencies directories"
	@echo "    clean-br-2016     # delete 2016 buildroot-related directories"
	@echo "    clean-br-2019     # delete 2019 buildroot-related directories"
	@echo "    dev-environment   # clones 'buildroot-site' branches for development"
	@echo ""
	
.PHONY: help2
help2:
	@$(MAKE) --print-data-base --question no-such-target | \
		grep -v -e '^no-such-target' -e '^makefile'  | \
		awk '/^[^.%][-A-Za-z0-9_]*:/                   \
			{ print substr($$1, 1, length($$1)-1) }' | \
		sort                                         | \
		pr --omit-pagination --width=80 --columns=4

