GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
all : fifo_tb

fifo_generic.o : fifo_generic.vhdl
	${GHDL} -a -v fifo_generic.vhdl
#	${GHDL} -a -v --work=fifo_generic fifo_generic.vhdl

fifo_tb.o : fifo_tb.vhdl fifo_generic.o
	${GHDL} -a -v fifo_tb.vhdl 

fifo_tb : fifo_tb.o
	${GHDL} -e -v fifo_tb
#	${GHDL} -e -v -P/home/jeanlou/ARM/ARM_v3/Vhdl_model/FIFO/ fifo_tb

clean :
	rm *.o work-obj93.cf fifo_tb
