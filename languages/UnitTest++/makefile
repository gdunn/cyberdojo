UNITTEST_INCLUDE = UnitTest++/src
UNITTEST_LIB = UnitTest++/libUnitTest++.a
COMPILE = g++ -std=c++11 -Wall -Werror

run.tests.output : run.tests
	./run.tests

run.tests : *.cpp
	$(COMPILE) -I $(UNITTEST_INCLUDE) -O *.cpp -o run.tests $(UNITTEST_LIB)


