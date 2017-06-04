library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
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
end Reg;

architecture Behavior OF Reg is

-- RF 
type rf_array is array(15 downto 0) of std_logic_vector(31 downto 0);
signal r_reg	: rf_array;

signal r_valid : Std_Logic_Vector(15 downto 0);
signal r_c		: Std_Logic;
signal r_z		: Std_Logic;
signal r_n		: Std_Logic;
signal r_v		: Std_Logic;
signal r_cznv	: Std_Logic;
signal r_vv		: Std_Logic;

begin

process (ck)
begin
	if rising_edge(ck) then
		if reset_n = '0' then
			r_valid <= X"FFFF";
			r_reg(15) <= X"00000000";
			r_cznv	<= '1';
			r_vv		<= '1';
		else
		
		        r_cznv	<= '0';
			    r_vv		<= '0';

                if inc_pc='1' then
                r_reg(15)<=std_logic_vector(unsigned(r_reg(15)) + 4);
                 end if;
                 
                 r_valid(to_integer(signed(inval_adr1))) <=inval1;
                 r_valid(to_integer(signed(inval_adr2)))<=inval2;
                
                 end if;
end if;
end process;

process(wen1,wen2,wadr2,wadr1,wcry,wzero,wneg,wovr,cspr_wb,inval_czn)
 begin
 if cspr_wb='1' then 
 r_c<=wcry;
 r_z<=wzero;
 r_n<=wneg;
 r_v<=wovr;
 end if;
 
 if inval_czn='1' then
  r_cznv	<= '1';
  end if;
   if inval_ovr='1' then
   r_v	<= '0';
   end if;
 
 if wen1='1' then
 r_reg(to_integer(signed(wadr1)))<=wdata1 ;
  r_valid(to_integer(signed(wadr1))) <='1';

 end if;
 
 if wen2='1' and wadr2 = wadr1 and  wen1='1' then
 else
 if wen2='1' then
  r_reg(to_integer(signed(wadr2)))<=wdata2 ;
   r_valid(to_integer(signed(wadr2))) <='1';
 end if;
 end if;
 
 end process;

process(radr1,radr2,inval_adr1,inval_adr2)
begin

case(r_valid(to_integer(signed(radr1)))) is

when '1' =>
reg_rd1<= r_reg(to_integer(signed(radr1)));
reg_v1<='1';

when '0' =>reg_v1<='0';

when others => reg_v1<='0'; 
end case;


case(r_valid(to_integer(signed(radr2)))) is

when '1' =>
reg_rd2<= r_reg(to_integer(signed(radr2)));
reg_v2<='1';

when '0' =>reg_v2<='0';



when others => reg_v2<='0'; 
end case;



case(r_valid(to_integer(signed(radr3)))) is

when '1' =>
reg_rd2<= r_reg(to_integer(signed(radr3)));
reg_v3<='1';

when '0' =>reg_v3<='0';
when others => reg_v3<='0'; 
end case;


end process;


reg_pcv	<='0' when r_reg(15)=X"00000000" else '1';
reg_cry<=r_c;
 reg_zero<=r_z;
 reg_neg<=r_n;
 reg_cznv<=r_cznv;
 reg_vv<=r_vv;
 reg_ovr<=r_v;



end Behavior;















