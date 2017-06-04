library ieee;
use ieee.std_logic_1164.all;
--library fifo;
--use fifo.all;

entity fifo_tb is
end fifo_tb;

----------------------------------------------------------------------

architecture Behavior OF fifo_tb is

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


signal din		: std_logic_vector(3 downto 0);
signal full 	: std_logic;
signal push 	: std_logic := '0';

signal dout		: std_logic_vector(3 downto 0);
signal empty 	: std_logic;
signal pop	 	: std_logic := '0';


signal ck		: std_logic;
signal reset_n	: std_logic := '0';
signal vdd		: bit := '1';
signal vss		: bit := '0';

begin

--  Component instantiation.

	fifo_4b : fifo
	generic map (WIDTH => 4)
	port map (	din	 => din,
					full		 => full,
					push		 => push,

					dout	 => dout,
					empty		 => empty,
					pop		 => pop,


					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

	process
	begin

		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;

		reset_n <= '1';
		din <= X"1";
		push <= '1';

		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;

		push <= '0';
		pop <= '1';

		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;

		din <= X"2";
		pop <= '0';
		push <= '1';

		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;

		din <= X"3";
		pop <= '1';
		push <= '1';

		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;

		pop <= '1';
		push <= '0';

		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;

		wait;
		end process;

end Behavior;
