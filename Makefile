TARGET=pc

CC = arm-cortex_a15-linux-gnueabihf-gcc
CXX = arm-cortex_a15-linux-gnueabihf-g++
STRIP = arm-cortex_a15-linux-gnueabihf-strip

PREFIX = /Volumes/linuxdisk/x-tools/arm-cortex_a15-linux-gnueabihf/arm-cortex_a15-linux-gnueabihf/sysroot/usr

CFLAGS = -I$(PREFIX)/include $(shell $(PREFIX)/bin/sdl2-config --cflags) -DTARGET_PC -DTARGET_OGA -DTARGET=$(TARGET) -DLOG_LEVEL=4 -Wall -Wundef -Wno-deprecated -Wno-unknown-pragmas -Wno-format -pg -O0 -g3
CXXFLAGS = $(CFLAGS)
LDFLAGS = -L$(PREFIX)/lib $(shell $(PREFIX)/bin/sdl2-config --libs) -lfreetype -lSDL2_image -lSDL2_ttf -lSDL2_gfx -ljpeg -lpng16 -lz #-lSDL_gfx

OBJDIR = objs/$(TARGET)
DISTDIR = dist/$(TARGET)/gmenu2x
APPNAME = $(OBJDIR)/gmenu2x

SOURCES := $(wildcard src/*.cpp)
OBJS := $(patsubst src/%.cpp, $(OBJDIR)/src/%.o, $(SOURCES))

# File types rules
$(OBJDIR)/src/%.o: src/%.cpp src/%.h
	$(CXX) $(CFLAGS) -o $@ -c $<

all: dir shared

dir:
	@if [ ! -d $(OBJDIR)/src ]; then mkdir -p $(OBJDIR)/src; fi

debug: $(OBJS)
	@echo "Linking gmenu2x-debug..."
	$(CXX) -o $(APPNAME)-debug $(LDFLAGS) $(OBJS)

shared: debug
	$(STRIP) $(APPNAME)-debug -o $(APPNAME)

clean:
	rm -rf $(OBJDIR) $(DISTDIR) *.gcda *.gcno $(APPNAME)

dist: dir shared
	install -m755 -D $(APPNAME)-debug $(DISTDIR)/gmenu2x
	install -m644 assets/$(TARGET)/input.conf $(DISTDIR)
	install -m755 -d $(DISTDIR)/sections/applications $(DISTDIR)/sections/emulators $(DISTDIR)/sections/games $(DISTDIR)/sections/settings
	install -m644 -D README.rst $(DISTDIR)/README.txt
	install -m644 -D COPYING $(DISTDIR)/COPYING
	install -m644 -D ChangeLog $(DISTDIR)/ChangeLog
	cp -RH assets/skins assets/translations $(DISTDIR)

-include $(patsubst src/%.cpp, $(OBJDIR)/src/%.d, $(SOURCES))

$(OBJDIR)/src/%.d: src/%.cpp
	@if [ ! -d $(OBJDIR)/src ]; then mkdir -p $(OBJDIR)/src; fi
	$(CXX) -M $(CXXFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
