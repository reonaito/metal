LIB = sieve.metallib
TARGET = sieve
XC = xcrun -sdk macosx

all: $(LIB) $(TARGET)

%.metallib: %.metal
	# Metal intermediate representation (.air)
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/$<.air $^
	# Metal library (.metallib)
	$(XC) metallib -o $@ /tmp/$<.air

%: %.swift
	$(XC) swiftc -o $@ $<

clean:
	rm -f *.metallib $(TARGET)
