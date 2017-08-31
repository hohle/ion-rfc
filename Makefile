LANG=en

MKOBJDIRS=auto
OBJDIR= obj
SCRDIR = ./

DICT=dict
OUTPUT_DICT=aspell-dict

SOURCES = \
	  ion-rfc.nroff \
	  ion-rfc-00-preamble.nroff \
	  ion-rfc-00-toc.nroff \
	  ion-rfc-01-introduction.nroff \
	  ion-rfc-02-data-model.nroff \
	  ion-rfc-03-text-encoding.nroff \
	  ion-rfc-04-binary-encoding.nroff \
	  ion-rfc-05-symbols.nroff \
	  ion-rfc-06-compression.nroff \
	  ion-rfc-07-security-considerations.nroff \
	  ion-rfc-08-iana-considerations.nroff \
	  ion-rfc-appendix.nroff \
	  ion-rfc-references.nroff

SPELL_OUTPUT = \
	  ion-rfc.sc \
	  ion-rfc-00-preamble.sc \
	  ion-rfc-00-toc.sc \
	  ion-rfc-01-introduction.sc \
	  ion-rfc-02-data-model.sc \
	  ion-rfc-03-text-encoding.sc \
	  ion-rfc-04-binary-encoding.sc \
	  ion-rfc-05-symbols.sc \
	  ion-rfc-06-compression.sc \
	  ion-rfc-07-security-considerations.sc \
	  ion-rfc-08-iana-considerations.sc \
	  ion-rfc-appendix.sc \
	  ion-rfc-references.sc

OUTPUT = ion-rfc.txt

#
# Macros
#
print_target = \
	@printf "\033[0;32m$@\033[0m\n" ;

.PHONY: all
all: $(OUTPUT) verify
	$(call print_target)

verify: check-spelling
	$(call print_target)

$(OUTPUT): $(SOURCES)
	$(call print_target)
	echo `pwd`
	nroff -ms $(SOURCES) > $@

check-spelling: $(SPELL_OUTPUT)
	$(call print_target)

.SUFFIXES: .sc
$(SPELL_OUTPUT): $(.PREFIX).nroff $(OUTPUT_DICT)
	$(call print_target)

	cat $(.PREFIX).nroff | \
	    aspell list \
	    --mode nroff \
	    --lang="$(LANG)" \
	    --extra-dicts="./$(OUTPUT_DICT)" \
	    -a | \
	    sort -u > $@

$(OUTPUT_DICT): $(DICT)
	$(call print_target)

	aspell --lang="$(LANG)" create master "./$@" < $(.ALLSRC)

clean:
	$(call print_target)
	echo `pwd`
	rm -f $(OUTPUT)
	rm -f $(OUTPUT_DICT)
	rm -f $(SPELL_OUTPUT)
