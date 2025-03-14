-------------------------------------------------------------------
--
--  Fichero:
--    synchronizer.vhd  07/09/2023
--
--    (c) J.M. Mendias
--    Dise�o Autom�tico de Sistemas
--    Facultad de Inform�tica. Universidad Complutense de Madrid
--
--  Prop�sito:
--    Sincroniza una entrada binaria
--
--  Notas de dise�o:
--    Orientado a FPGA Xilinx 7 series: no reset y valor inicial
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
  generic (
    STAGES  : natural;       -- n�mero de biestables del sincronizador
    XPOL    : std_logic      -- polaridad (valor en reposo) de la se�al a sincronizar
  );
  port (
    clk   : in  std_logic;   -- reloj del sistema
    x     : in  std_logic;   -- entrada binaria a sincronizar
    xSync : out std_logic    -- salida sincronizada que sigue a la entrada
  );
end synchronizer;

-------------------------------------------------------------------

architecture syn of synchronizer is 
begin

  process (clk)
    variable aux : std_logic_vector(STAGES-1 downto 0) := (others => XPOL); 
  begin
    xSync <= aux(STAGES-1);		
    if rising_edge(clk) then
      for i in STAGES-1 downto 1 loop
        aux(i) := aux(i-1);
      end loop;
      aux(0) := x;
    end if;
  end process;

end syn;
