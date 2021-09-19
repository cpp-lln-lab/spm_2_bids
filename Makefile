install_dev:
	git clone https://github.com/bids-standard/bids-matlab.git lib/bids-matlab
	cd lib/bids-matlab && git checkout dev
	git clone git://github.com/gllmflndn/JSONio.git --depth 1 lib/JSONio

install_dev_octave:
	git clone https://github.com/bids-standard/bids-matlab.git lib/bids-matlab
	cd lib/bids-matlab && git checkout dev
	git clone git://github.com/gllmflndn/JSONio.git --depth 1 lib/JSONio
	cd lib/JSONio && mkoctfile --mex jsonread.c jsmn.c -DJSMN_PARENT_LINKS

clean:
	rm -rf lib/bids-matlab
	rm -rf lib/JSONio