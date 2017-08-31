LANG=en

DICT=dict
OUTPUT_DICT=aspell-dict

SOURCES = \
	  ion-rfc.nroff \
	  ion-rfc-00-preamble.nroff
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
	nroff -ms $(SOURCES) > $@

check-spelling: $(SOURCES) $(OUTPUT_DICT)
	$(call print_target)

	cat $(SOURCES) | \
	    aspell list \
	    --mode nroff \
	    --lang="$(LANG)" \
	    --extra-dicts="./aspell-dict" \
	    -a | \
	    sort -u

$(OUTPUT_DICT): $(DICT)
	$(call print_target)

	aspell --lang="$(LANG)" create master "./$@" < $(.ALLSRC)

clean:
	$(call print_target)
	rm -f $(OUTPUT_DICT)
	rm -f $(OUTPUT)
