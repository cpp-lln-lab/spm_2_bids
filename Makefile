install_dev:
	git clone https://github.com/bids-standard/bids-matlab.git lib/bids-matlab
	cd lib/bids-matlab && git checkout dev

clean:
	rm -rf lib/bids-matlab