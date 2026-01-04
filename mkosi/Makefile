build: mkosi.cache mkosi.output
	mkosi --force build

vm:
	TERM=xterm-256color mkosi vm

mkosi.cache:
	mkdir -p $@

mkosi.output:
	mkdir -p $@

clean:
	mkosi -f clean
	rm -rf mkosi.output
	rm -rf mkosi.cache

.PHONY: build vm clean
