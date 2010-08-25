
OPTS ?= --bash
RUNS ?= 10000
GHC = ghc --make -outputdir

test/echo: test/Echo.hs
	mkdir -p test/build
	${GHC} test/build -O2 test/Echo.hs -o test/echo

prof/echo: test/Echo.hs
	mkdir -p prof/build
	${GHC} prof/build test/Echo.hs -o prof/echo -prof -auto-all

clean:
	rm -rf */build */echo test/lengths* test/chars*


.PHONY: prof
prof: prof/echo
	cd prof && ./echo ${RUNS} +RTS -hb -RTS && hp2ps echo.hp


test: test/chars.histogram test/lengths.histogram

.PHONY: test_run
test_run: test/echo
	rm -f test/chars test/lengths
	cd test && ./echo ${OPTS} ${RUNS}

test/chars: test_run
test/chars.histogram: test/chars
	sort < $< | uniq -c > $@

test/lengths: test_run
test/lengths.histogram: test/lengths
	sort -n < $< | uniq -c > $@

