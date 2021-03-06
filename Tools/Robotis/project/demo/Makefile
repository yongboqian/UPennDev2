##################################################
# PROJECT: Thor Action Play tutorial Makefile
# AUTHOR : ROBOTIS Inc.
##################################################

#---------------------------------------------------------------------
# Makefile template for Thor projects
#
# Please make sure to follow these instructions when setting up your
# own copy of this file:
#
#   1- Enter the name of the target (the TARGET variable)
#   2- Add additional source files to the SOURCES variable
#   3- Add additional static library objects to the OBJECTS variable
#      if necessary
#   4- Ensure that compiler flags, INCLUDES, and LIBRARIES are
#      appropriate to your needs
#
#
# This makefile will link against several libraries, not all of which
# are necessarily needed for your project.  Please feel free to
# remove libaries you do not need.
#---------------------------------------------------------------------

# *** ENTER THE TARGET NAME HERE ***
TARGET      = demo

# important directories used by assorted rules and other variables
DIR_THOR    = /thor-motion
DIR_OBJS    = .objects
# DIR_QT      = /usr/include/qt4

# compiler options
CC          = gcc
CX          = g++
CCFLAGS     = -O2 -O3 -DLINUX -D_GNU_SOURCE -Wall $(INCLUDES) -g
CXFLAGS     = -O2 -O3 -DLINUX -D_GNU_SOURCE -Wall $(INCLUDES) -g
LNKCC       = $(CX)
LNKFLAGS    = $(CXFLAGS) #-Wl,-rpath,$(DIR_THOR)/lib

#---------------------------------------------------------------------
# Core components (all of these are likely going to be needed)
#---------------------------------------------------------------------
INCLUDES   += -I$(DIR_THOR)/include
INCLUDES   += -I$(DIR_THOR)/include/framework 
INCLUDES   += -I$(DIR_THOR)/include/linux 
#INCLUDES   += -I$(DIR_THOR)/include/motionlibrary

LIBRARIES  += -lthor
LIBRARIES  += -ljpeg
LIBRARIES  += -lpthread 
LIBRARIES  += -ldl
LIBRARIES  += -lncurses 
LIBRARIES  += -lrt

#---------------------------------------------------------------------
# Qt components (not always needed)
#---------------------------------------------------------------------
#INCLUDES   += -I$(DIR_QT)/QtCore 
#INCLUDES   += -I$(DIR_QT)/QtGui 
#INCLUDES   += -I$(DIR_QT)/QtXml 
#INCLUDES   += -I$(DIR_QT)

#LIBRARIES  += -lQtXml 
#LIBRARIES  += -lQtGui 
#LIBRARIES  += -lQtCore



#---------------------------------------------------------------------
# Files
#---------------------------------------------------------------------
SOURCES = streamer/httpd.cpp\
          streamer/jpeg_utils.cpp\
          streamer/mjpg_streamer.cpp\
          main.cpp \
          
    # *** OTHER SOURCES GO HERE ***

OBJECTS  = $(addsuffix .o,$(addprefix $(DIR_OBJS)/,$(basename $(notdir $(SOURCES)))))
#OBJETCS += *** ADDITIONAL STATIC LIBRARIES GO HERE ***


#---------------------------------------------------------------------
# Compiling Rules
#---------------------------------------------------------------------
$(TARGET): make_directory $(OBJECTS)
	$(LNKCC) $(LNKFLAGS) $(OBJECTS) $(LIBRARIES) -o $(TARGET)

all: $(TARGET)

clean:
	rm -rf $(TARGET) $(DIR_OBJS) core *~ *.a *.so *.lo

make_directory:
	mkdir -p $(DIR_OBJS)/

$(DIR_OBJS)/%.o: %.c
	$(CC) $(CCFLAGS) -c $? -o $@

$(DIR_OBJS)/%.o: %.cpp
	$(CX) $(CXFLAGS) -c $? -o $@

$(DIR_OBJS)/%.o: streamer/%.c
	$(CC) $(CCFLAGS) -c $? -o $@

$(DIR_OBJS)/%.o: streamer/%.cpp
	$(CX) $(CXFLAGS) -c $? -o $@

# useful to make a backup "make tgz"
tgz: clean
	mkdir -p backups
	tar czvf ./backups/Thor_$(TARGET)_`date +"%Y_%m_%d_%H.%M.%S"`.tgz --exclude backups *

archive: tgz

#---------------------------------------------------------------------
# End of Makefile
#---------------------------------------------------------------------
