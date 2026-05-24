#
# GNUmakefile - Bootstrap hmake for the host PC using GNU Make + FPC.
#
# Run from the repository root:
#   make -f tools/hmake/bootstrap/GNUmakefile          # build
#   make -f tools/hmake/bootstrap/GNUmakefile clean     # remove output
#   make -f tools/hmake/bootstrap/GNUmakefile rebuild   # clean then build
#
# CopyLeft (c) 1995-2024 by PopolonY2k.
# CopyLeft (c) since 2024 by Hinotori Team.

FPC    := fpc
OUTDIR := build
ENTRY  := tools/hmake/src/main/fpc/hmake.pas
TARGET := $(OUTDIR)/hmake

# Rebuild whenever any Pascal source in the hmake tree changes.
SOURCES := $(shell find tools/hmake/src -name '*.pas')

.PHONY: all clean rebuild

all: $(TARGET)

$(TARGET): $(SOURCES) | $(OUTDIR)
	$(FPC) -FE$(OUTDIR) -g -gw $(ENTRY)

$(OUTDIR):
	mkdir -p $(OUTDIR)

clean:
	rm -f $(OUTDIR)/hmake $(OUTDIR)/hmake.o $(OUTDIR)/link.res

rebuild: clean all
