-------------------------------------------------------------------
--
--  Fichero:
--    rs232receiver.vhd  12/09/2023
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Conversor elemental de una linea serie RS-232 a paralelo con 
--    protocolo de strobe
--
--  Notas de diseño:
--    - Parity: NONE
--    - Num data bits: 8
--    - Num stop bits: 1
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rs232receiver is
  generic (
    FREQ_KHZ : natural;  -- frecuencia de operacion en KHz
    BAUDRATE : natural   -- velocidad de comunicacion
  );
  port (
    -- host side
    clk     : in  std_logic;   -- reloj del sistema
    rst     : in  std_logic;   -- reset síncrono del sistema
    dataRdy : out std_logic;   -- se activa durante 1 ciclo cada vez que hay un nuevo dato recibido
    data    : out std_logic_vector (7 downto 0);   -- dato recibido
    -- RS232 side
    RxD     : in  std_logic    -- entrada de datos serie del interfaz RS-232
  );
end rs232receiver;

-------------------------------------------------------------------

use work.common.all;

architecture syn of rs232receiver is

  signal RxDSync : std_logic;
  signal readRxD, baudCntCE : boolean;

begin

  RxDSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '1' )
    port map ( clk => clk, x => RxD, xSync => RxDSync );

  baudCnt:
  process (clk)
    constant CYCLES : natural := ((FREQ_KHZ * 1000) / BAUDRATE);
    variable count : natural range 0 to CYCLES - 1 := 0;
  begin
    readRxD <= ( count = CYCLES/2-1 );
    if rising_edge(clk) then
      if baudCntCE then
        if (count = CYCLES-1) then
          count := 0;
        else count := count + 1; 
        end if;
      end if;
    end if;
  end process;
  
  fsmd:
  process (clk)
    variable bitPos : natural range 0 to 10 := 0;
    variable RxDSht : std_logic_vector(9 downto 0) := (others => '0');
  begin
    data      <= RxDSht(8 downto 1);
    baudCntCE <= (bitPos /= 0);
    if rising_edge(clk) then
      if rst='1' then
        bitPos := 0;
        RxDSht := (others => '0');
      else
        case bitPos is
          when 0 =>                              -- Esperando bit de start
            dataRdy <= '0';
            if (RxDSync = '0') then
              bitPos := 1;
            end if;
          when others =>
            if (readRxD) then
                RxDSht := RxDSync & RxDSht(9 downto 1);
                if (bitPos = 10) then
                  dataRdy <= '1';
                  bitPos := 0;
                else
                  bitPos := bitPos + 1;
                end if;
            end if;
        end case;
      end if;
    end if;
  end process;
  
end syn;
