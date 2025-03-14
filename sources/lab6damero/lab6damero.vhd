---------------------------------------------------------------------
--
--  Fichero:
--    lab6.vhd  23/01/2024
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Laboratorio 6: Damero
--
--  Notas de diseño:
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lab6damero is
  port ( 
    clk     : in  std_logic;
    hSync   : out std_logic;
    vSync   : out std_logic;
    RGB     : out std_logic_vector(11 downto 0)
  );
end lab6damero;

---------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture syn of lab6damero is

  constant FREQ_KHZ : natural := 100_000;  -- frecuencia de operacion en KHz
  constant VGA_KHZ  : natural := 25_000;   -- frecuencia de envio de pixeles a la VGA en KHz
  constant FREQ_DIV : natural := FREQ_KHZ/VGA_KHZ; 

  signal line, pixel : std_logic_vector(9 downto 0);
  signal color       : std_logic_vector(3 downto 0); 
  
begin
 
  screenInteface: vgaRefresher
    generic map ( FREQ_DIV => FREQ_DIV )
    port map ( clk => clk, line => line, pixel => pixel, R => color, G => color, B => color, hSync => hSync, vSync => vSync, RGB => RGB );
    
  color <= (others => pixel(4) xor line(4));

end syn;

