.PHONY: build run icon test verify clean

icon:
	./scripts/make-icon.sh

build:
	./build-app.sh

run: build
	open build/SoundViz.app

test:
	swift test

verify: test build

clean:
	swift package clean
	rm -rf build
