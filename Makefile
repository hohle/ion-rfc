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
	  ion-rfc-06-stringclob.nroff \
	  ion-rfc-07-compression.nroff \
	  ion-rfc-08-security-considerations.nroff \
	  ion-rfc-09-iana-considerations.nroff \
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
	  ion-rfc-06-stringclob.sc \
	  ion-rfc-07-compression.sc \
	  ion-rfc-08-security-considerations.sc \
	  ion-rfc-09-iana-considerations.sc \
	  ion-rfc-appendix.sc \
	  ion-rfc-references.sc

OUTPUT = ion-rfc.txt
TOC = toc.input

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

$(OUTPUT): $(SOURCES) toc.input
	$(call print_target)
	nroff -ms $(SOURCES) | \
	    sed 's/FORMFEED\(\[Page[ ]*[0-9]*\]\)[ ]*/        \1\
\
/' \
	    > $@

toc.input: $(SOURCES)
	$(call print_target)
	@touch toc.input
	# run once to generate a placeholder TOC
	# which will block correctly, but include
	# wrong page numbers
	@nroff -ms $(SOURCES) 2>&1 >/dev/null | \
	    sed 's/^_/ /' | \
	    grep -v ': warning: ' | \
	    sed 's/^/   /' | \
	    tee $@
	# do it again with correct line numbers
	nroff -ms $(SOURCES) 2>&1 >/dev/null | \
	    sed 's/^_/ /' | \
	    grep -v ': warning: ' | \
	    sed 's/^/   /' | \
	    tee $@

check-spelling: $(SPELL_OUTPUT)
	$(call print_target)

.SUFFIXES: .sc
%.sc: %.nroff $(OUTPUT_DICT)
	$(call print_target)

	cat $< | \
	    aspell list \
	    --mode nroff \
	    --lang="$(LANG)" \
	    --extra-dicts="./$(OUTPUT_DICT)" \
	    -a | \
	    sort -u | \
	    tee $@ | \
	    xargs -n 1 printf "\\033[0;31m$< >>>\033[0m %s\n"

$(OUTPUT_DICT): $(DICT)
	$(call print_target)

	aspell --lang="$(LANG)" create master "./$@" < $^

ion-rfc.pdf: $(OUTPUT)
	    cat $(OUTPUT) | \
		awk ' \
				{ gsub(/\r/, ""); } \
				{ gsub(/[ \t]+$$/, ""); } \
/\[?[Pp]age [0-9ivx]+\]?[ \t]*$$/{ pageend=1; print; next; } \
/^[ \t]*\f/			{ formfeed=1; print; next; } \
/^ *Internet.Draft.+[0-9]+ *$$/	{ newpage=1; } \
/^ *INTERNET.DRAFT.+[0-9]+ *$$/	{ newpage=1; } \
/^RFC.+[0-9]+$$/		{ newpage=1; } \
/^draft-[-a-z0-9_.]+.*[0-9][0-9][0-9][0-9]$$/ { \
				  newpage=1; \
				} \
/^[ \t]*$$/			{ \
				  if (pageend && !newpage) next; \
				} \
				{ \
				  if ( pageend && newpage && !formfeed ) { print "\f"; } \
				  pageend=0; formfeed=0; newpage=0; \
				  print \
				} \
' | \
		enscript --margins 76::76: -B -q -p - | \
		ps2pdf - $@

pdf: ion-rfc.pdf

clean:
	$(call print_target)
	echo `pwd`
	rm -f toc.input
	rm -f $(OUTPUT)
	rm -f $(OUTPUT_DICT)
	rm -f $(SPELL_OUTPUT)
	rm -f ion-rfc.pdf
