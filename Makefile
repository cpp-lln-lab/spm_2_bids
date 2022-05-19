.PHONY: clean

install_dev_octave: install_dev
	cd lib/JSONio && mkoctfile --mex jsonread.c jsmn.c -DJSMN_PARENT_LINKS
install_dev: lib/bids-matlab lib/JSONio

lib/bids-matlab:
	git clone https://github.com/bids-standard/bids-matlab.git --branch dev lib/bids-matlab

lib/JSONio:
	git clone https://github.com/gllmflndn/JSONio.git --depth 1 lib/JSONio
clean: clean_doc clean_tests
	rm -rf lib/bids-matlab
	rm -rf lib/JSONio
	rm -rf version.txt

clean_doc:
	cd docs && make clean


clean_tests:
	rm -rf coverage_html
	rm -f coverage.xml
	rm -f *.log

version.txt: CITATION.cff
	grep -w "^version" CITATION.cff | sed "s/version: /v/g" > version.txt

validate_cff: CITATION.cff
	cffconvert --validate
