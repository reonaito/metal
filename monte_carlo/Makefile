LIB = monte_carlo.metallib
TARGET = monte_carlo
XC = xcrun -sdk macosx

all: $(LIB) $(TARGET)

%.metallib: %.metal
	# Metal intermediate representation (.air)
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/$<.air $^
	# Metal library (.metallib)
	$(XC) metallib -o $@ /tmp/$<.air

monte_carlo.metallib: Loki/Loki/*.metal monte_carlo.metal
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/loki.air Loki/Loki/loki.metal
	$(XC) metal -c -Wall -Wextra -std=osx-metal2.0 -o /tmp/monte_carlo.air monte_carlo.metal
	$(XC) metallib -o $@ /tmp/loki.air /tmp/monte_carlo.air

%: %.swift
	$(XC) swiftc -o $@ $<

clean:
	rm -f *.metallib $(TARGET)
