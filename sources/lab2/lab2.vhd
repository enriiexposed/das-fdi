---------------------------------------------------------------------
--
--  Fichero:
--    lab2.vhd  07/09/2023
--
--    (c) J.M. Mendias
--    Dise�o Autom�tico de Sistemas
--    Facultad de Inform�tica. Universidad Complutense de Madrid
--
--  Prop�sito:
--    Laboratorio 2
--
--  Notas de dise�o: Cron�metro
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lab2 is
port
(
  clk       : in  std_logic;
  clear     : in  std_logic;
  startStop : in  std_logic;
  lap       : in  std_logic;
  leds      : out std_logic_vector(15 downto 0)
);
end lab2;

---------------------------------------------------------------------

use work.common.all;

architecture syn of lab2 is

  component modCounter
    generic
  (
    MAXVAL : natural   -- valor maximo alcanzable
  );
  port
  (
    clk   : in  std_logic;   -- reloj del sistema
    rst   : in  std_logic;   -- reset (puesta a 0) sincrono
    ce    : in  std_logic;   -- capacitacion de cuenta
    tc    : out std_logic;   -- fin de cuenta
    count : out std_logic_vector(log2(MAXVAL)-1 downto 0)   -- cuenta
  );
  end component;

  constant FREQ_KHZ  : natural := 100_000;  -- frecuencia de operacion en KHz
  constant BOUNCE_MS : natural := 50;       -- tiempo de rebote de los pulsadores en ms

  -- Registros  

  signal lapTFF, startStopTFF : std_logic := '0';
       
  signal secLowReg  : std_logic_vector(3 downto 0) := (others => '0'); 
  signal secHighReg : std_logic_vector(2 downto 0) := (others => '0');

  -- Conexiones

  signal clearSync : std_logic;
  signal startStopSync, startStopDeb, startStopRise : std_logic;
  signal lapSync, lapDeb, lapRise : std_logic;
 
  signal cycleCntTC, decCntTC, secLowCntTC : std_logic;
  
  signal decCnt, secLowCnt : std_logic_vector(3 downto 0); 
  signal secHighCnt        : std_logic_vector(2 downto 0);
  
  signal secLowMux, secHighMux : std_logic_vector(3 downto 0); 

begin

   clearSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '0' )
    port map ( clk => clk, x => clear, xSync => clearSync );
    
    ------------------  

  startStopSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '0' )
    port map ( clk => clk, x => startStop, xSync => startStopSync);

  startStopDebouncer : debouncer
    generic map ( FREQ_KHZ => FREQ_KHZ, BOUNCE_MS => BOUNCE_MS, XPOL => '0' )
    port map ( clk => clk, rst => clearSync, x => startStopSync, xDeb => startStopDeb);
   
  startStopEdgeDetector : edgeDetector
    generic map ( XPOL => '0' )
    port map ( clk => clk, x => startStopDeb, xRise => startStopRise, xFall => open );

  ------------------  
   
  lapSynchronizer : synchronizer
    generic map (STAGES => 2, XPOL => '0')
    port map (clk => clk, x => lap, xSync => lapSync );

  lapDebouncer : debouncer
    generic map ( FREQ_KHZ => FREQ_KHZ, BOUNCE_MS => BOUNCE_MS, XPOL => '0' )
    port map ( clk => clk, rst => clearSync, x => lapSync, xDeb => lapDeb);
   
  lapEdgeDetector : edgeDetector
    generic map ( XPOL => '0' )
    port map ( clk => clk, x => lapDeb, xRise => lapRise, xFall => open );
 
  ------------------  

  toggleFFs :
  process (clk)
  begin
    if rising_edge(clk) then
      if clearSync='1' then
        startStopTFF <= '0';
        lapTFF       <= '0';     
      else
        if startStopRise = '1' then
          startStopTFF <= not startStopTFF;
        end if;
        if lapRise = '1' then
          lapTFF <= not lapTFF;
        end if;
      end if;
    end if;
  end process;
  
  cycleCounter : modCounter 
    generic map ( MAXVAL => ms2cycles(FREQ_KHZ, 100)-1 ) 
    port map ( clk => clk, rst => clearSync, ce => startStopTFF, tc => cycleCntTC, count => open );
  
  decCounter : modCounter 
    generic map ( MAXVAL => 9 )
    port map ( clk => clk, rst => clearSync, ce => cycleCntTC, tc => decCntTC, count => decCnt );
    
  secLowCounter : modCounter 
    generic map ( MAXVAL => 9 )
    port map ( clk => clk, rst => clearSync, ce => decCntTC, tc => secLowCntTC, count => secLowCnt);
  
  secHighCounter : modCounter 
    generic map ( MAXVAL => 5 )
    port map ( clk => clk, rst => clearSync, ce => secLowCntTC, tc => open, count => secHighCnt);

  lapRegisters :
  process (clk)
  begin
    if rising_edge(clk) then  
      if clearSync='1' then
        secLowReg  <= (others => '0');
        secHighReg <= (others => '0');       
      elsif lapRise = '1' then
        secLowReg  <= secLowCnt;
        secHighReg <= secHighCnt;        
      end if;
    end if;
  end process;
  
  leftMux :
    secHighMux <= '0' & secHighReg when lapTFF = '1' else '0' & secHighCnt;
  
  rigthMux :
    secLowMux <= secLowReg when lapTFF = '1' else secLowCnt;
  
  leds <= decCnt(3) & (6 downto 0 => '0') & secHighMux & secLowMux;
  
end syn;
