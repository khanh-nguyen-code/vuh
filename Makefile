# declaration
UNAME = $(shell uname)

COMMON_FLAGS = -g -std=c++17 -I include -L lib

ifeq ($(UNAME), Linux)
	# specific for Linux
	CC = gcc
	CFLAGS = $(COMMON_FLAGS) -Wall -fPIC 
	LDFLAGS = -l stdc++
endif
ifeq ($(UNAME), Darwin)
	# specific for MacOS
	CC = clang
	CFLAGS = $(COMMON_FLAGS) -Wall -fPIC
	CFLAGS += -I /opt/homebrew/include -L /opt/homebrew/lib
	CFLAGS += -I /opt/homebrew/Cellar/molten-vk/1.2.0/libexec/include/
	LDFLAGS = -l stdc++
	LDFLAGS += -l MoltenVK

endif


# compile object
OBJECT_SRC_LIST = $(shell find src -name "*.cpp") # recursive wildcard
OBJECT_OUT_LIST = $(patsubst src/%.cpp,obj/%.o,$(OBJECT_SRC_LIST))
obj/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

# link library
LIBRARY_SRC_LIST = $(wildcard src/*)
LIBRARY_OUT_LIST = $(patsubst src/%,lib/lib%.so,$(LIBRARY_SRC_LIST))
lib/lib%.so: # not sure how to put in the dependencies here
	@mkdir -p lib
	$(CC) $(CFLAGS) -shared -o $@ obj/$*/*.o $(LDFLAGS)

# compile and link target
TARGET_SRC_LIST = $(wildcard target/*)
TARGET_OUT_LIST = $(patsubst target/%,bin/%,$(TARGET_SRC_LIST))
THIS_LDFLAGS = $(patsubst src/%,-l %,$(LIBRARY_SRC_LIST))
bin/%: target/%
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $</*.cpp $(LDFLAGS) $(THIS_LDFLAGS)

all: echo $(OBJECT_OUT_LIST) $(LIBRARY_OUT_LIST) $(TARGET_OUT_LIST)

echo: 
	@echo "Compiling on $(UNAME)"

clean:
	rm -rf obj lib bin

.PHONY: all echo clean
