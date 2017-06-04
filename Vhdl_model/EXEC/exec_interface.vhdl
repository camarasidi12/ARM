library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXec is
	port(
	-- Decode interface synchro
			dec2exe_empty	: in Std_logic;
			exe_pop			: out Std_logic;

	-- Decode interface operands
			dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: in Std_Logic; -- Rd destination write back
			dec_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Decode to mem interface 
			dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W
			dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R
			dec_pre_index 	: in Std_logic;

			dec_mem_lw		: in Std_Logic;
			dec_mem_lb		: in Std_Logic;
			dec_mem_sw		: in Std_Logic;
			dec_mem_sb		: in Std_Logic;

	-- Shifter command
			dec_shift_lsl	: in Std_Logic;
			dec_shift_lsr	: in Std_Logic;
			dec_shift_asr	: in Std_Logic;
			dec_shift_ror	: in Std_Logic;
			dec_shift_rrx	: in Std_Logic;
			dec_shift_val	: in Std_Logic_Vector(4 downto 0);
			dec_cy			: in Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: in Std_Logic;
			dec_comp_op2	: in Std_Logic;
			dec_alu_cy 		: in Std_Logic;

	-- Alu command
			dec_alu_add		: in Std_Logic;
			dec_alu_and		: in Std_Logic;
			dec_alu_or		: in Std_Logic;
			dec_alu_xor		: in Std_Logic;

	-- Exe bypass to decod
			exe_res			: out Std_Logic_Vector(31 downto 0);

			exe_c				: out Std_Logic;
			exe_v				: out Std_Logic;
			exe_n				: out Std_Logic;
			exe_z				: out Std_Logic;

			exe_dest			: out Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: out Std_Logic; -- Rd destination write back
			exe_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Mem interface
			exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- Alu res register
			exe_mem_data	: out Std_Logic_Vector(31 downto 0);
			exe_mem_dest	: out Std_Logic_Vector(3 downto 0);

			exe_mem_lw		: out Std_Logic;
			exe_mem_lb		: out Std_Logic;
			exe_mem_sw		: out Std_Logic;
			exe_mem_sb		: out Std_Logic;

			exe2mem_empty	: out Std_logic;
			mem_pop			: in Std_logic;

	-- global interface
			ck					: in Std_logic;
			reset_n			: in Std_logic;
			vdd				: in bit;
			vss				: in bit);
end EXec;

----------------------------------------------------------------------

architecture Behavior OF EXec is

component alu
    port ( op1			: in Std_Logic_Vector(31 downto 0);
           op2			: in Std_Logic_Vector(31 downto 0);
           cin			: in Std_Logic;

           cmd_add	: in Std_Logic;
           cmd_and	: in Std_Logic;
           cmd_or		: in Std_Logic;
           cmd_xor	: in Std_Logic;

           res			: out Std_Logic_Vector(31 downto 0);
           cout		: out Std_Logic;
           z			: out Std_Logic;
           n			: out Std_Logic;
           v			: out Std_Logic;
			  
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


signal op2_lsl		: std_logic_vector(31 downto 0);
signal op2_lsr		: std_logic_vector(31 downto 0);
signal op2_asr		: std_logic_vector(31 downto 0);
signal op2_ror		: std_logic_vector(31 downto 0);

signal shift_asr32	: std_logic_vector(31 downto 0);
signal shift_ror32	: std_logic_vector(31 downto 0);
signal sign_op2	: std_logic_vector(31 downto 0);
signal shift_right_in	: std_logic_vector(31 downto 0);
signal op2_right	: std_logic_vector(31 downto 0);
signal op2_shift	: std_logic_vector(31 downto 0);

signal left_cy		: std_logic;
signal right_cy	: std_logic;
signal shift_c 	: std_logic;
signal alu_c 		: std_logic;

signal op2			: std_logic_vector(31 downto 0);
signal op1			: std_logic_vector(31 downto 0);


signal alu_res		: std_logic_vector(31 downto 0);
signal res_reg		: std_logic_vector(31 downto 0);
signal mem_adr		: std_logic_vector(31 downto 0);

signal exe_push 	: std_logic;
signal exe2mem_full	: std_logic;
signal mem_acces	: std_logic;

begin

--  Component instantiation.
	alu_inst : alu
	port map (	op1		 => op1,
					op2		 => op2,
					cin		 => dec_alu_cy,

					cmd_add	 => dec_alu_add,
					cmd_and	 => dec_alu_and,
					cmd_or	 => dec_alu_or,
					cmd_xor	 => dec_alu_xor,

					res		 => alu_res,
					cout		 => alu_c,
					z			 => exe_z,
					n			 => exe_n,
					v			 => exe_v,

					vdd		 => vdd,
					vss		 => vss);

	exec2mem : fifo
	generic map (WIDTH => 72)
	port map (

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

end Behavior;
