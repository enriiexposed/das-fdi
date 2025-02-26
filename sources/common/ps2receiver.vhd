-------------------------------------------------------------------
--
--  Fichero:
--    ps2receiver.vhd  12/09/2023
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Conversor elemental de una linea serie PS2 a paralelo con 
--    protocolo de strobe de 1 ciclo
--
--  Notas de diseño:
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ps2receiver is
  port (
    -- host side
    clk        : in  std_logic;   -- reloj del sistema
    rst        : in  std_logic;   -- reset síncrono del sistema      
    dataRdy    : out std_logic;   -- se activa durante 1 ciclo cada vez que hay un nuevo dato recibido
    data       : out std_logic_vector (7 downto 0);  -- dato recibido
    -- PS2 side
    ps2Clk     : in  std_logic;   -- entrada de reloj del interfaz PS2
    ps2Data    : in  std_logic    -- entrada de datos serie del interfaz PS2
  );
end ps2receiver;

-------------------------------------------------------------------

use work.common.all;

architecture syn of ps2receiver is
 
  signal ps2DataShf: std_logic_vector(10 downto 0) := (others =>'1');

  signal ps2ClkSync, ps2DataSync, ps2ClkFall: std_logic;
  signal lastBit, parityOK: std_logic;

begin

  ps2ClkSynchronizer : synchronizer
    generic map(STAGES => 2, XPOL => '0')
    port map(clk => clk, x => ps2Clk, xSync => ps2ClkSync);
    

  ps2DataSynchronizer : synchronizer
    generic map(STAGES => 2, XPOL => '0')
    port map(clk => clk, x => ps2Data, xSync => ps2DataSync);

  ps2ClkEdgeDetector : edgeDetector
    generic map(XPOL => '0')
    port map(clk => clk, x => ps2ClkSync, xFall => ps2ClkFall, xRise => open);
    

  ps2DataShifter:
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or lastBit = '1' then
        ps2DataShf <= (others => '1');
      else
        ps2DataShf <= '0' & ps2DataShf(ps2DataShf'left downto 1);
      end if;
    end if;
  end process;

  oddParityCheker :
  process(ps2DataShf)
    variable aux : std_logic;
  begin
    aux := ps2DataShf(0);
    for i in ps2DataShf'range loop
      if ps2DataShf(i) = '1' then
        aux := not aux;
      end if;
    end loop;
    parityOK <= aux;
  end process;

  lastBitChecker :
  lastBit <= not ps2DataShf(0);  
   
  outputRegisters :
  process (clk)
  begin
    if rising_edge(clk) then 
        if rst = '0' then
          data <= (others => '0');
          dataRdy <= '0';
        else
          dataRdy <= parityOk and lastBit;
          data <= ps2DataShf(8 downto 1);
        end if;
    end if;
  end process;
    
end syn;
