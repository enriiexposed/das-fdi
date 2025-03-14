---------------------------------------------------------------------
--
--  Fichero:
--    lab5.vhd  12/09/2023
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Laboratorio 5: Loopback con FIFO
--
--  Notas de diseño:
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lab5 is
  port (
    clk    :  in std_logic;
    rst    :  in std_logic;
    RxD    :  in std_logic; 
    TxD    : out std_logic;
    TxEn   :  in  std_logic;
    leds   : out std_logic_vector(15 downto 0);
    an_n   : out std_logic_vector (3 downto 0);   -- selector de display  
    segs_n : out std_logic_vector(7 downto 0)     -- código 7 segmentos
  );
END lab5;

-----------------------------------------------------------------
library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture syn of lab5 is

  constant FREQ_KHZ : natural := 100_000;  -- frecuencia de operacion en KHz
  constant BAUDRATE : natural := 1200;     -- vaelocidad de transmisión
  
  signal dataRx, dataTx: std_logic_vector (7 downto 0);
  signal dataRdyTx, dataRdyRx, busy, empty, full: std_logic;
  
  signal rstSync, TxEnSync : std_logic;
  signal fifostatus : std_logic_vector (3 downto 0);
  
  signal numData : std_logic_vector (3 downto 0);
  signal en : std_logic;
  
  signal ensAux : std_logic_vector(3 downto 0);
  signal binsAux : std_logic_vector(15 downto 0);
  
begin

  rstSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '0' )
    port map ( clk => clk, x => rst, xSync => rstSync );
    
  TxEnSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '0' )
    port map ( clk => clk, x => TxEn, xSync => TxEnSync );

  receiver: rs232receiver
    generic map ( FREQ_KHZ => FREQ_KHZ, BAUDRATE => BAUDRATE )
    port map ( clk => clk, rst => rstSync, dataRdy => dataRdyRx, data => dataRx, RxD => RxD );

  fifo : fifoQueue
    generic map ( WL => 8, DEPTH => 16 )
    port map ( clk => clk, rst => rstSync, wrE => dataRdyRx, dataIn => dataRx, rdE => dataRdyTx, dataOut => dataTx, numData => numData, full => full, empty => empty );

  dataRdyTx <= '1' when empty = '0' and TxEnSync = '1' and busy = '0' else '0';
   
  transmitter: rs232transmitter 
    generic map ( FREQ_KHZ => FREQ_KHZ, BAUDRATE => BAUDRATE )
    port map ( clk => clk, rst => rstSync, dataRdy => dataRdyTx, data => dataTx, busy => busy, TxD => TxD );

  fifoStatus <= X"F" when full='1' else X"E";
  
  en <= full or empty;

  numDataDecoder:
  process( numData, full )
    variable i : natural;
  begin
      leds <= ( others => '0' );
      if full='1' then
        leds <= (others => '1');
      else
        for i in 0 to 15 loop
          if (to_integer(unsigned(numData)) = i) then
            leds(i) <= '1';
          else leds(i) <= '0';
          end if;
        end loop;
       end if;
  end process;
  
  auxSignals : 
  ensAux <= "110" & en;
  binsAux <= dataRx(7 downto 4) & dataRx(3 downto 0) & "0000" & fifoStatus; 
  
  
  displayInterface : segsBankRefresher
    generic map ( FREQ_KHZ => FREQ_KHZ, SIZE => 4 )
    port map ( clk => clk, ens => ensAux, bins => binsAux, dps => "0000", an_n => an_n, segs_n => segs_n ); 
    
end syn;