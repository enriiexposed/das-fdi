---------------------------------------------------------------------
--
--  Fichero:
--    segsDisplayInterface.vhd  15/1/2018
--
--    (c) J.M. Mendias
--    Dise�o Autom�tico de Sistemas
--    Facultad de Inform�tica. Universidad Complutense de Madrid
--
--  Prop�sito:
--    Refresca un display de 7-segs en configuraci�n �nodo com�n
--
--  Notas de dise�o:
--    Orientado a FPGA Xilinx 7 series: no reset y valor inicial
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity segsBankRefresher is
  generic(
    FREQ_KHZ : natural;   -- frecuencia de operacion en KHz
    SIZE     : natural    -- n�mero de displays a refrescar     
  );
  port (
    -- host side
    clk    : in std_logic;                              -- reloj del sistema
    ens    : in std_logic_vector (SIZE-1 downto 0);     -- capacitaciones
    bins   : in std_logic_vector (4*SIZE-1 downto 0);   -- c�digos binarios a mostrar
    dps    : in std_logic_vector (SIZE-1 downto 0);     -- puntos
    -- 7 segs display side
    an_n   : out std_logic_vector (SIZE-1 downto 0);    -- selector de display  
    segs_n : out std_logic_vector (7 downto 0)          -- c�digo 7 segmentos 
  );
end segsBankRefresher;

---------------------------------------------------------------------

use work.common.all;

architecture syn of segsBankRefresher is

  constant REFRESH_RATE   : natural := 60;                          -- Frecuencia de refresco
  constant CYCLESxREFRESH : natural := FREQ_KHZ*1000/REFRESH_RATE;  -- Periodo de refresco en ciclos
  constant CYCLESxDIGIT   : natural := CYCLESxREFRESH/SIZE;         -- Periodo de persistencia en ciclos

  -- Registros
  signal count : natural range 0 to CYCLESxDIGIT-1 := 0;
  signal index : natural range 0 to SIZE-1         := 0;

  -- Se�ales
  signal bin : std_logic_vector (3 downto 0);
  signal dp  : std_logic;
  signal en  : std_logic;
  
begin
 
  process (clk, bins, dps, ens)
  begin
    bin <= bins( 4*index+3 downto 4*index );
    dp  <= dps( index );
    en  <= ens( index );
    an_n          <= ( others => '1' );
    an_n( index ) <= '0';
    if rising_edge(clk) then 
      count <= (count + 1) mod CYCLESxDIGIT;    
      if count = CYCLESxDIGIT-1 then
        index <= (index + 1) mod SIZE;
      end if;
    end if;
  end process;
  
  converter : bin2segs
    port map ( en => en, bin => bin, dp => dp, segs_n => segs_n );
  
end syn;