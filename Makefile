myblog:
	stack build
	stack exec myblog clean
	stack exec myblog build

clean:
	stack clean

watch: myblog
	stack exec myblog watch
