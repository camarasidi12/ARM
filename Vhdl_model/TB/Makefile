#GHDL=/home/jeanlou/Outils/ghdl/bin/ghdl
GHDL=/usr/bin/ghdl
C_MOD_DIR = ../../C_model/
all : main_tb

ram.o : ram.vhdl
	${GHDL} -a -v ram.vhdl

icache.o : icache.vhdl ram.o
	${GHDL} -a -v icache.vhdl

dcache.o : dcache.vhdl ram.o
	${GHDL} -a -v dcache.vhdl

main_tb.o : main_tb.vhdl icache.o dcache.o ram.o 
	${GHDL} -a -v main_tb.vhdl

arm_core.o : ../CORE/arm_core.vhdl ifetch.o decod.o exec.o mem.o
	${GHDL} -a -v ../CORE/arm_core.vhdl
	
ifetch.o : ../IFETCH/ifetch.vhdl fifo_generic.o
	${GHDL} -a -v ../IFETCH/ifetch.vhdl

decod.o : ../DECOD/decod.vhdl fifo_generic.o reg.o
	${GHDL} -a -v ../DECOD/decod.vhdl

reg.o : ../DECOD/reg.vhdl 
	${GHDL} -a -v ../DECOD/reg.vhdl

exec.o : ../EXEC/exec.vhdl fifo_generic.o alu.o
	${GHDL} -a -v ../EXEC/exec.vhdl

alu.o : ../EXEC/alu.vhdl
	${GHDL} -a -v ../EXEC/alu.vhdl

mem.o : ../MEM/mem.vhdl
	${GHDL} -a -v ../MEM/mem.vhdl

fifo_generic.o : ../FIFO/fifo_generic.vhdl
	${GHDL} -a -v ../FIFO/fifo_generic.vhdl

main_tb : main_tb.o ram.o icache.o dcache.o arm_core.o
	${GHDL} -e -v -Wl,${C_MOD_DIR}/lib/mem.o -Wl,${C_MOD_DIR}/lib/arm_ghdl.o -Wl,${C_MOD_DIR}/ReadElf/lib/ElfObj.o main_tb

clean :
	rm *.o main_tb work-obj93.cf
