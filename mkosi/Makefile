build:
	mkdir -p build
	mkosi --force build

vm:
	TERM=xterm-256color mkosi vm

clean:
	mkosi -f clean
	rm -f build/

.PHONY: build vm clean
