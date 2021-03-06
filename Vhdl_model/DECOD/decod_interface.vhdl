library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;

			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic;
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_add		: out Std_Logic;
			dec_alu_and		: out Std_Logic;
			dec_alu_or		: out Std_Logic;
			dec_alu_xor		: out Std_Logic;

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c				: in Std_Logic;
			exe_v				: in Std_Logic;
			exe_n				: in Std_Logic;
			exe_z				: in Std_Logic;

			exe_dest			: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir				: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest			: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component reg
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv		: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end component;

component fifo
	generic(WIDTH: positive);
	port(
		din		: in std_logic_vector(WIDTH-1 downto 0);
		dout		: out std_logic_vector(WIDTH-1 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;



signal cond		: Std_Logic;
signal condv	: Std_Logic;
signal operv	: Std_Logic;

signal regop_t  : Std_Logic;
signal mult_t   : Std_Logic;
signal swap_t   : Std_Logic;
signal trans_t  : Std_Logic;
signal mtrans_t : Std_Logic;
signal branch_t : Std_Logic;

-- regop instructions
signal and_i  : Std_Logic;
signal eor_i  : Std_Logic;
signal sub_i  : Std_Logic;
signal rsb_i  : Std_Logic;
signal add_i  : Std_Logic;
signal adc_i  : Std_Logic;
signal sbc_i  : Std_Logic;
signal rsc_i  : Std_Logic;
signal tst_i  : Std_Logic;
signal teq_i  : Std_Logic;
signal cmp_i  : Std_Logic;
signal cmn_i  : Std_Logic;
signal orr_i  : Std_Logic;
signal mov_i  : Std_Logic;
signal bic_i  : Std_Logic;
signal mvn_i  : Std_Logic;

-- mult instruction
signal mul_i  : Std_Logic;
signal mla_i  : Std_Logic;

-- trans instruction
signal ldr_i  : Std_Logic;
signal str_i  : Std_Logic;
signal ldrb_i : Std_Logic;
signal strb_i : Std_Logic;

-- mtrans instruction
signal ldm_i  : Std_Logic;
signal stm_i  : Std_Logic;

-- branch instruction
signal b_i    : Std_Logic;
signal bl_i   : Std_Logic;

-- link
signal blink    : Std_Logic;

-- Multiple transferts
signal mtrans_shift : Std_Logic;

signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0);
signal mtrans_mask : Std_Logic_Vector(15 downto 0);
signal mtrans_list : Std_Logic_Vector(15 downto 0);
signal mtrans_rd : Std_Logic_Vector(3 downto 0);

-- RF read ports
signal radr1 : Std_Logic_Vector(3 downto 0);
signal rdata1 : Std_Logic_Vector(31 downto 0);
signal rvalid1 : Std_Logic;

signal radr2 : Std_Logic_Vector(3 downto 0);
signal rdata2 : Std_Logic_Vector(31 downto 0);
signal rvalid2 : Std_Logic;

signal radr3 : Std_Logic_Vector(3 downto 0);
signal rdata3 : Std_Logic_Vector(31 downto 0);
signal rvalid3 : Std_Logic;

-- RF inval ports
signal inval_exe_adr : Std_Logic_Vector(3 downto 0);
signal inval_exe : Std_Logic;

signal inval_mem_adr : Std_Logic_Vector(3 downto 0);
signal inval_mem : Std_Logic;

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

signal reg_cznv : Std_Logic;
signal reg_vv : Std_Logic;

signal inval_czn : Std_Logic;
signal inval_ovr : Std_Logic;

-- PC
signal reg_pc : Std_Logic_Vector(31 downto 0);
signal reg_pcv : Std_Logic;
signal inc_pc : Std_Logic;

-- FIFOs
signal dec2if_full : Std_Logic;
signal dec2if_push : Std_Logic;

signal dec2exe_full : Std_Logic;
signal dec2exe_push : Std_Logic;

-- Exec  operands
signal op1			: Std_Logic_Vector(31 downto 0);
signal op2			: Std_Logic_Vector(31 downto 0);
signal alu_dest	: Std_Logic_Vector(3 downto 0);
signal alu_wb		: Std_Logic;
signal flag_wb		: Std_Logic;

signal offset32	: Std_Logic_Vector(31 downto 0);

-- Decod to mem via exec
signal mem_data	: Std_Logic_Vector(31 downto 0);
signal ld_dest		: Std_Logic_Vector(3 downto 0);
signal pre_index 	: Std_logic;

signal mem_lw		: Std_Logic;
signal mem_lb		: Std_Logic;
signal mem_sw		: Std_Logic;
signal mem_sb		: Std_Logic;

-- Shifter command
signal shift_lsl	: Std_Logic;
signal shift_lsr	: Std_Logic;
signal shift_asr	: Std_Logic;
signal shift_ror	: Std_Logic;
signal shift_rrx	: Std_Logic;
signal shift_val	: Std_Logic_Vector(4 downto 0);
signal cy			: Std_Logic;

-- Alu operand selection
signal comp_op1	: Std_Logic;
signal comp_op2	: Std_Logic;
signal alu_cy 		: Std_Logic;

-- Alu command
signal alu_add		: Std_Logic;
signal alu_and		: Std_Logic;
signal alu_or		: Std_Logic;
signal alu_xor		: Std_Logic;

-- DECOD FSM

type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
signal cur_state, next_state : state_type;

begin

	dec2exec : fifo
	generic map (WIDTH => 129)
	port map (
					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

		dec2if : fifo
	generic map (WIDTH => 32)
	port map (	dout		=> reg_pc,

					push		 => dec2if_push,
					
					full		 => dec2if_full,

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

	reg_inst  : reg
	port map(	wdata1		=> exe_res,
					wadr1			=> exe_dest,
					wen1			=> exe_wb,
                                          
					wdata2		=> mem_res,
					wadr2			=> mem_dest,
					wen2			=> mem_wb,
                                          
					wcry			=> exe_c,
					wzero			=> exe_z,
					wneg			=> exe_n,
					wovr			=> exe_v,
					cspr_wb		=> exe_flag_wb,
					               
					reg_rd1		=> rdata1,
					radr1			=> radr1,
					reg_v1		=> rvalid1,
                                          
					reg_rd2		=> rdata2,
					radr2			=> radr2,
					reg_v2		=> rvalid2,
                                          
					reg_rd3		=> rdata3,
					radr3			=> radr3,
					reg_v3		=> rvalid3,
                                          
					reg_cry		=> cry,
					reg_zero		=> zero,
					reg_neg		=> neg,
					reg_ovr		=> ovr,
					               
					reg_cznv		=> reg_cznv,
					reg_vv		=> reg_vv,
                                          
					inval_adr1	=> inval_exe_adr,
					inval1		=> inval_exe,
                                          
					inval_adr2	=> inval_mem_adr,
					inval2		=> inval_mem,
                                          
					inval_czn	=> inval_czn,
					inval_ovr	=> inval_ovr,
                                          
					reg_pc		=> reg_pc,
					reg_pcv		=> reg_pcv,
					inc_pc		=> inc_pc,
				                              
					ck				=> ck,
					reset_n		=> reset_n,
					vdd			=> vdd,
					vss			=> vss);
					


-- Execution condition


-- FSM

process (ck)
begin

if (rising_edge(ck)) then
	if (reset_n = '0') then
		cur_state <= Run;
	else
		cur_state <= next_state;
	end if;
end if;

end process;

--state machine process.
process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full, if2dec_empty, reg_pcv, bl_i,
			branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
			mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, mtrans_rd, mtrans_mask_shift)
begin
	case cur_state is

	when FETCH =>
		dec_pop <= '0';
		dec2exe_push <= '0';
		blink <= '0';
		mtrans_shift <= '0';

		if dec2if_full = '0' and reg_pcv = '1' then
			next_state <= RUN;
			dec2if_push	<= '1';
			inc_pc <= '1';
		else
		end if;
		when RUN =>
			if if2dec_empty='1' and dec2exe_full='1' then
			   if reg_pcv='1' and dec2if_full='0' then 
				--dec_pc<=reg_pc; 
			    inc_pc <= '1';
			    dec2if_push<='1';
				end if;
			end if;
		     if if2dec_empty='0' then
				
				
			end if;
			
	    when  BRANCH=>
	    when  LINK=>
	    when  MTRANS=>
	    
	    	

	end case;
end process;

dec_pc<=reg_pc; 

--process(if_ir(25),if_ir(4),if_ir(27 downto 26),if_ir(24 downto 21) )
process(if_ir)
begin
--initialisation 
mul_i<='0';
mla_i <='0';
ldr_i<='0';
str_i<='0';
ldrb_i<='0';
strb_i<='0';
b_i<='0';
bl_i<='0';  
--traitm donn
if if_ir(27 downto 26)="00" then

dec_flag_wb<= if_ir(20);
dec_exe_dest<=if_ir(15 downto 12);
radr1<=if_ir(19 downto 16);


if if_ir(24 downto 21)="0000" then and_i <='1' ; else and_i <='0';end if;
if if_ir(24 downto 21)="0001" then eor_i  <='1' ;   else eor_i  <='0';end if;
if if_ir(24 downto 21)="0010" then sub_i  <='1' ; else sub_i<='0';end if;
if if_ir(24 downto 21)="0011" then rsb_i  <='1' ; else rsb_i  <='0';end if ;
if if_ir(24 downto 21)="0100"  then add_i   <='1' ;else add_i   <='0';end if ;
if if_ir(24 downto 21)="0101"  then adc_i  <='1' ;else  adc_i  <='0';end if ;
if if_ir(24 downto 21)="0110" then sbc_i <='1' ; else  sbc_i <='0';end if ;
if if_ir(24 downto 21)="0111" then rsc_i   <='1' ; else rsc_i   <='0';end if ;
if if_ir(24 downto 21)="1000" then tst_i  <='1'; else tst_i  <='0';end if ;
if if_ir(24 downto 21)="1001"  then teq_i   <='1' ;else teq_i   <='0';end if ;
if if_ir(24 downto 21)="1010" then cmp_i <='1'; else  cmp_i <='0';end if ;
if if_ir(24 downto 21)="1011" then cmn_i   <='1'; else cmn_i   <='0';end if ;
if if_ir(24 downto 21)="1100" then orr_i   <='1'; else orr_i   <='0';end if ;
if if_ir(24 downto 21)="1101" then mov_i   <='1' ; else mov_i   <='0';end if;
if if_ir(24 downto 21)="1110" then bic_i   <='1'; else bic_i   <='0';end if;
if if_ir(24 downto 21)="1111" then mvn_i  <='1'; else  mvn_i  <='0';end if;

if if_ir(25)='0' then 
radr2<=if_ir(3 downto 0); --Rm


if if_ir(6 downto 5)="00" then  shift_lsl <= '1'  ; else shift_lsl <='0'; end if ;
if if_ir(6 downto 5)="01" then  shift_lsr <= '1'; else shift_lsr <='0'; end if;
if if_ir(6 downto 5)="10" then  shift_asr <= '1'; else  shift_asr <='0'; end if;
if if_ir(6 downto 5)="11" then  shift_ror <= '1'; else  shift_ror <='0'; end if;

if if_ir(4)='0' then

shift_val <= if_ir(11 downto 7) ;

else

radr3<=if_ir(11 downto 8) ;

end if;


else

dec_op2<=X"00000000"&if_ir(7 downto 0);
shift_ror<='1';
dec_shift_val<='0'&if_ir(10 downto 8)&'0';


end if;

end if;

--branchment
if if_ir(27 downto 25)="101" then 

if if_ir(24)='1' then bl_i<='1';b_i<='0'; else bl_i<='0';b_i<='1'; end if;
offset32<=X"00"&if_ir(23 downto 0);

end if;

--accer mem simple
if if_ir(27 downto 26)="01" then 
pre_index<=if_ir(24);
ld_dest<=if_ir(15 downto 12);
if if_ir(20)='1' and if_ir(22)='0'  then ldr_i <='1'; end if;
if if_ir(20)='1' and if_ir(22)='1'  then ldrb_i <='1'; end if;

if if_ir(20)='1' and if_ir(22)='0'  then str_i <='1'; end if;
if if_ir(20)='0' and if_ir(22)='1'  then strb_i <='1'; end if;

if if_ir(25)='0' then 
radr2<=if_ir(3 downto 0); --Rm


if if_ir(6 downto 5)="00" then  shift_lsl <= '1'  ; else shift_lsl <='0'; end if ;
if if_ir(6 downto 5)="01" then  shift_lsr <= '1'; else shift_lsr <='0'; end if;
if if_ir(6 downto 5)="10" then  shift_asr <= '1'; else  shift_asr <='0'; end if;
if if_ir(6 downto 5)="11" then  shift_ror <= '1'; else  shift_ror <='0'; end if;

if if_ir(4)='0' then

shift_val <= if_ir(11 downto 7) ;

else

radr3<=if_ir(11 downto 8) ;

end if;


else

dec_op2<=X"00000000"&if_ir(7 downto 0);
shift_ror<='1';
dec_shift_val<='0'&if_ir(10 downto 8)&'0';


end if;

end if;

--accer mem multipl
if if_ir(27 downto 25)="100" then 

mtrans_list<=if_ir(15 downto 0);
pre_index<=if_ir(24);
radr1<=if_ir(19 downto 16);

end if;

--multipl
if if_ir(27 downto 22)="000000" then 
mul_i <=not if_ir(21) ;
mla_i <=if_ir(21) ;

end if;

end process;





















end Behavior;
