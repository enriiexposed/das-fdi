---------------------------------------------------------------------
--
--  Fichero:
--    bin2segs.vhd  07/09/2023
--
--    (c) J.M. Mendias
--    Dise�o Autom�tico de Sistemas
--    Facultad de Inform�tica. Universidad Complutense de Madrid
--
--  Prop�sito:
--    Convierte codigo binario a codigo 7-segmentos
--
--  Notas de dise�o:
--    - Asume que los sementos se encienden en logica inversa
--    - Los segmentos se ordenan en segs alfab�ticamente de izquierda 
--      a derecha: a=segs_n(6), b=segs_n(5)... g=segs_n(0)
--    - El punto se corresponde con segs_n(7)
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity bin2segs is
  port (
    -- host side
    en     : in std_logic;                      -- capacitacion
    bin    : in std_logic_vector(3 downto 0);   -- codigo binario
    dp     : in std_logic;                      -- punto
    -- leds side
    segs_n : out std_logic_vector(7 downto 0)   -- codigo 7-segmentos (logica inversa)
  );
end bin2segs;

-------------------------------------------------------------------

architecture syn of bin2segs is
  signal segs : std_logic_vector(7 downto 0);
begin 

  segs(7) <= dp;
  with bin select
    segs(6 downto 0) <= 
        "0000001" when X"0",
        "1001111" when X"1",
        "0010010" when X"2",
        "0000110" when X"3",
        "1001100" when X"4",
        "0100100" when X"5",
        "0100000" when X"6",
        "0001111" when X"7",
        "0000000" when X"8",
        "0001100" when X"9",
        "0001000" when X"A",
        "1100000" when X"B",
        "0110001" when X"C",
        "1000010" when X"D",
        "0110000" when X"E",
        "0111000" when others;
      
  segs_n <= segs when en = '1' else "11111111";

end syn;