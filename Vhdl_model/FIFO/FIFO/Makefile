#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
all : fifo_tb

fifo_generic.o : fifo_generic.vhdl
	${GHDL} -a -v fifo_generic.vhdl

fifo_tb.o : fifo_tb.vhdl fifo_generic.o
	${GHDL} -a -v fifo_tb.vhdl 

fifo_tb : fifo_tb.o
	${GHDL} -e -v fifo_tb

clean :
	rm *.o work-obj93.cf fifo_tb
