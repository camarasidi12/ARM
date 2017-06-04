#CC = /usr/bin/arm-linux-gnu-gcc
#AS_ARM = /usr/bin/arm-linux-gnu-as
#LD_ARM = /usr/bin/arm-linux-gnu-ld
CC = /usr/bin/arm-linux-gnueabi-gcc-4.6
AS_ARM = /usr/bin/arm-linux-gnueabi-as
LD_ARM = /usr/bin/arm-linux-gnueabi-ld
CFLAGS = -march=armv2a -mno-thumb-interwork -Wall -O1
LD_FLAGS = -Bstatic -fix-v4bx

fic = test_str test_tri

all : $(fic)

start.o : start.s
	${AS_ARM} -c start.s -o start.o

$(fic): % : %.o start.o 
	${LD_ARM} ${LD_FLAGS} -T sections.lds -o $@ start.o $<

clean :
	rm -f $(fic) *.o
