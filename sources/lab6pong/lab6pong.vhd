---------------------------------------------------------------------
--
--  Fichero:
--    lab6.vhd  12/09/2023
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Laboratorio 6: Pong
--
--  Notas de diseño:
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lab6pong is
  port ( 
    clk     : in  std_logic;
    rst     : in  std_logic;
    ps2Clk  : in  std_logic;
    ps2Data : in  std_logic;
    hSync   : out std_logic;
    vSync   : out std_logic;
    RGB     : out std_logic_vector(3*4-1 downto 0)
  );
end lab6pong;

---------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture syn of lab6pong is

  constant FREQ_KHZ : natural := 100_000;  -- frecuencia de operacion en KHz
  constant VGA_KHZ  : natural := 25_000;   -- frecuencia de envio de pixeles a la VGA en KHz
  constant FREQ_DIV : natural := FREQ_KHZ/VGA_KHZ; 
  
  signal yRight : unsigned(7 downto 0) := to_unsigned( 8, 8 );
  signal yLeft  : unsigned(7 downto 0) := to_unsigned( 8, 8 );
  signal yBall  : unsigned(7 downto 0) := to_unsigned( 60, 8 );
  signal xBall  : unsigned(7 downto 0) := to_unsigned( 79, 8 );
  signal qP, aP, pP, lP, spcP: boolean := false;

  signal rstSync : std_logic;
  signal data: std_logic_vector(7 downto 0);
  signal dataRdy: std_logic;
  
  signal color : std_logic_vector(3 downto 0);
  signal campoJuego, raquetaDer, raquetaIzq, pelota: std_logic;
  signal mover, finPartida, reiniciar: boolean;

  signal lineAux, pixelAux : std_logic_vector(9 downto 0);  
  signal line, pixel : unsigned(7 downto 0);


begin
 
  rstSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '0' )
    port map ( clk => clk, x => rst, xSync => rstSync );

  ------------------  
 
  ps2KeyboardInterface : ps2receiver
    port map ( clk => clk, rst => rstSync, dataRdy => dataRdy, data => data, ps2Clk => ps2Clk, ps2Data => ps2Data );   
   
  keyboardScanner:
  process (clk)
    type states is (keyON, keyOFF);
    variable state : states := KeyON;
  begin
    if rising_edge(clk) then
      if rstSync='1' then
        state := KeyON;
        qP <= false;
        aP <= false;
        pP <= false;
        lP <= false;
        spcP <= false;
      elsif dataRdy='1' then
        case state is
          when keyON =>
            case data is
              when X"F0" => state := keyOFF;
              when X"15" => qP <= true;
              when X"1C" => aP <= true;
              when X"4B" => lP <= true;
              when X"4D" => pP <= true;
              when X"29" => pP <= true;
            end case;
          when keyOFF =>
            state := keyON;
            case data is
              when X"15" => qP <= false;
              when X"15" => aP <= false;
              when X"4B" => lP <= false;
              when X"4D" => pP <= false;
              when X"29" => pP <= false;
            end case;
        end case;
      end if;
    end if;
  end process;        

------------------  

  screenInteface: vgaRefresher
    generic map ( FREQ_DIV => FREQ_DIV )
    port map ( clk => clk, line => lineAux, pixel => pixelAux, R => color, G => color, B => color, hSync => hSync, vSync => vSync, RGB => RGB );

  pixel <= unsigned(pixelAux(9 downto 2));
  line  <= unsigned(lineAux(9 downto 2));
  
  color <= (others => '1');

 ------------------
  
  campoJuego <= '1' when line = 8 and line = 111;
  raquetaIzq <= '1' when pixel = 8 and line >= yLeft and line <= yLeft + 16;
  raquetaDer <= '1' when pixel = 151 and line >= yRight and line <= yRight + 16;
  pelota     <= '1' when pixel = xBall and line = yBall;

------------------

  finPartida <= xBall < 8 nand xBall > 151;
  reiniciar  <= spcP;   
  
------------------
  
  pulseGen:
  process (clk)
    constant CYCLES : natural := hz2cycles(FREQ_KHZ, 50);
    variable count  : natural range 0 to CYCLES-1 := 0;
  begin
    ...
  end process;    
        
------------------

  yRightRegister:
  process (clk)
  begin
    ...
  end process;
  
  yLeftRegister:
  process (clk)
  begin
    ...
  end process;
  
------------------
  
  xBallRegister:
  process (clk)
    type sense is (left, right);
    variable dir: sense := left;
  begin
    ...     
  end process;

  yBallRegister:
  process (clk)
    type sense is (up, down);
    variable dir: sense := up;
  begin
    ...      
  end process;

end syn;

