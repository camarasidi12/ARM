AS_ARM = /usr/bin/arm-linux-gnu-as
LD_ARM = /usr/bin/arm-linux-gnu-ld
#AS_ARM = /usr/bin/arm-linux-gnueabi-as
#LD_ARM = /usr/bin/arm-linux-gnueabi-ld
CFLAGS = -march=armv2a -mno-thumb-interwork -Wall -O1
LD_FLAGS = -Bstatic -fix-v4bx

fic = test_b test_mov

all : $(fic)

$(fic) : % : %.o
	${LD_ARM} ${LD_FLAGS} -T sections.lds -o $@ $<

%.o : %.s
	${AS_ARM} -c $< -o $@

clean :
	rm -f $(fic) *.o
