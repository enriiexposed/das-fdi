-------------------------------------------------------------------
--
--  Fichero:
--    ps2interface.vhd  14/02/2024
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Interfaz bidireccional con un dispositivo PS2
--
--  Notas de diseño:
--    - No chequea paraidad en recepcion
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ps2interface is
  generic(
    FREQ_KHZ  : natural    -- frecuencia de operacion en KHz
  );
  port (
    -- host side
    clk        : in  std_logic;   -- reloj del sistema
    rst        : in  std_logic;   -- reset síncrono del sistema      
    RxDataRdy  : out std_logic;   -- se activa durante 1 ciclo cada vez que hay un nuevo dato recibido
    RxData     : out std_logic_vector (7 downto 0);   -- dato recibido
    TxDataRdy  : in  std_logic;   -- se activa durante 1 ciclo cada vez que hay un nuevo dato a transmitir   
    TxData     : in  std_logic_vector (7 downto 0);   -- dato a transmitir
    busy       : out std_logic;   -- se activa mientras esta transmitiendo
    -- PS2 side
    ps2Clk     : inout  std_logic;   -- reloj del interfaz PS2
    ps2Data    : inout  std_logic    -- datos serie del interfaz PS2
  );
end ps2interface;

-------------------------------------------------------------------

use work.common.all;

architecture syn of ps2interface is
  
  signal ps2ClkSync, ps2DataSync, ps2ClkFall, ps2ClkRise : std_logic;
  signal TxParity : std_logic;
    
begin

  ps2ClkSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '1' )
    port map ( clk => clk, x => ps2Clk, xSync => ps2ClkSync );

  ps2ClkEdgeDetector : edgeDetector
    generic map ( XPOL => '1' )
    port map ( clk => clk, x => ps2ClkSync, xFall => ps2ClkFall, xRise => ps2ClkRise );

------------------

  ps2DataSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '1' )
    port map ( clk => clk, x => ps2Data, xSync => ps2DataSync );

------------------
      
  TxOddParityGenerator :
  process (TxData)
    variable aux : std_logic;
  begin
    aux := TxData(0);
    for i in 1 to 7 loop
      aux := aux xor TxData(i);
    end loop;
    TxParity <= not aux;
  end process;
  
------------------

  fsmdt:
  process (clk)
    type states is ( idle, receiving, clkDown, dataDown, waitingClkRise, sending );
    variable state     : states := idle;
    variable numCycles : natural := 0;
    variable bitPos    : natural range 0 to 10 := 0;
    variable shifter   : std_logic_vector (10 downto 0) := (others => '0');
  begin
  
    RxData <= shifter(8 downto 1);
    case state is
      when idle =>
        ps2Clk  <= 'Z';
        ps2Data <= 'Z';
        busy <= '0';
        RxDataRdy <= '0';
      when receiving =>
        ps2Clk  <= 'Z';
        ps2Data <= 'Z';
        busy <= '0';
      when clkDown => 
        ps2Clk <= '0';
        ps2Data <= '0';
        busy <= '1';
      when dataDown =>
        ps2Clk <= '0';
        ps2Data <= shifter(0);
        busy <= '1';
        
      when waitingClkRise | sending =>
        ps2Clk <= 'Z';
        ps2Data <= shifter(0);
        busy <= '1';   
    end case; 
    
    if rising_edge(clk) then
      if rst='1' then
        state := idle;
      -- Estados con timing se quedan hasta que acabe el tiempo
      elsif numCycles /= 0 then
        numCycles := numCycles - 1;
      else
        case state is
          when idle =>         
            if txDataRdy='1' then
              state     := clkDown;
              numCycles := us2cycles(FREQ_KHZ, 100);
              shifter   := "1" & TxParity & TxData & "0";
              bitPos    := 0;
            elsif ps2ClkFall='1' then
              state     := receiving;
              shifter   := (others => '0');
              bitPos    := bitPos + 1;
            end if;
          when receiving =>     
            if (ps2ClkFall = '1') then
              shifter   := ps2DataSync & shifter(10 downto 1);
              if (bitPos < 10) then  
                bitPos    := bitPos + 1;
              else 
                state   := idle;
                RxDataRdy <= '1';
              end if;
            end if;
          when clkDown =>
            if (numCycles = 0) then
              state := dataDown;
              numCycles := us2cycles(FREQ_KHZ, 500);
            end if;
          when dataDown =>
            if (numCycles = 0) then
              state := waitingClkRise;
            end if;
          when waitingClkRise =>
            if ps2ClkRise = '1' then
              state     := sending;
            end if;
          when sending =>
            if (ps2ClkRise = '1') then
              if (bitPos < 10) then
                shifter   := ps2DataSync & shifter(10 downto 1);
                bitPos    := bitPos + 1;
              else 
                state   := idle;
              end if;
            end if;      
        end case;
      end if;
    end if;
    
  end process;

end syn;
 
  