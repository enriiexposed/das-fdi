---------------------------------------------------------------------
--
--  Fichero:
--    lab9.vhd  09/02/2024
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Laboratorio 9
--
--  Notas de diseño:
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lab9 is
  port ( 
    clk     : in  std_logic;
    rst     : in  std_logic;
    ps2Clk  : inout  std_logic;
    ps2Data : inout  std_logic;
    sws     : in std_logic_vector(2 downto 0);
    hSync   : out std_logic;
    vSync   : out std_logic;
    RGB     : out std_logic_vector(3*4-1 downto 0)
  );
end lab9;

---------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture syn of lab9 is

  constant FREQ_KHZ : natural := 100_000;  -- frecuencia de operacion en KHz
  constant VGA_KHZ  : natural := 25_000;   -- frecuencia de envio de pixeles a la VGA en KHz
  constant FREQ_DIV : natural := FREQ_KHZ/VGA_KHZ; 
  
  constant PIXELSxLINE : natural := 640;
  constant LINESxFRAME : natural := 480;
  
  signal rstSync : std_logic;
  
  signal TxData    : std_logic_vector(7 downto 0) := (others => '0');
  signal TxDataRdy : std_logic := '0';
  
  signal RXData    : std_logic_vector(7 downto 0);
  signal RxDataRdy : std_logic;
    
  signal status   : std_logic_vector(7 downto 0) := (others => '0');
  signal x        : unsigned(log2(PIXELSxLINE)-1 downto 0) := (others => '0');
  signal y        : unsigned(log2(LINESxFRAME)-1 downto 0) := (others => '0');
  signal colorRdy : std_logic := '0';

  signal pixel : std_logic_vector(9 downto 0);
  signal line  : std_logic_vector(8 downto 0);

  signal RGBinterface : std_logic_vector (RGB'range);
  
begin
   
  rstSynchronizer : synchronizer
    generic map ( STAGES => 2, XPOL => '0' )
    port map ( clk => clk, x => rst, xSync => rstSync );

  ------------------  
  
  mouseInterface : ps2Interface
    generic map ( FREQ_KHZ => FREQ_KHZ )
    port map ( clk => clk, rst => rstSync, RxDataRdy => RxDataRdy, RxData => RxData, TxDataRdy => TxDataRdy, TxData => TxData, busy => open, ps2Clk => ps2Clk, ps2Data => ps2Data );

  mouseScanner : 
  process(clk)
    type states is ( sendEnable, waitACK, waitingStatus, waitingXoffset, waitingYoffset );
    variable state     : states := sendEnable;
    variable xOffset   : signed(x'range);
    variable yOffset   : signed(y'range); 
  begin
    if rising_edge(clk) then
      if rstSync='1' then
        TxDataRdy <= '0';
        TxData    <= (others => '0');
        x         <= (others => '0');
        y         <= (others => '0');
        status    <= (others => '0');
        state     := sendEnable;
      else
        case state is
          when sendEnable =>
            TxData <= X"F4";
            TxDataRdy <= '1';
            state := waitACK;
          when waitACK => 
            TxDataRdy <= '0';
            if RxDataRdy='1' then
              state := waitingStatus;         
            end if;
          when waitingStatus =>
            status <= RxData;
            if RxDataRdy='1' then
              state := waitingXoffset;         
            end if;
          when waitingXoffset =>
              if status(6) = '0' then
                xOffset := signed(status(4) & RxData);
                x <= unsigned(std_logic_vector(signed(std_logic_vector(x)) + xOffset));
              end if;
              if RxDataRdy='1' then
                state := waitingYoffset;
              end if;
          when waitingYoffset =>
              -- Pintamos en la x e y que tengamos
              colorRdy <= status(0);
              if status(7) = '0' then
                yOffset := signed(status(5) & RxData);
                y <= unsigned(std_logic_vector(signed(std_logic_vector(y)) + yOffset));
              end if;
              if RxDataRdy='1' then
                state := waitingStatus;   
              end if;
        end case;         
      end if;
    end if;
  end process;
                      
  ------------------  

  screenInterface: vgaGraphicInterface 
    generic map ( FREQ_DIV => FREQ_DIV )
    port map ( clk => clk, clear => status(1), x => std_logic_vector(x), y => std_logic_vector(y), color => sws, dataRdy => colorRdy, line => line, pixel => pixel, hSync => hSync, vSync => vSync, RGB => RGBinterface );   
 
 ------------------
 
  cursorRender:
  process (pixel, line, x,  y)
     -- Puntero 16x16: 0-negro, 1-blanco, 2-transparente
    constant SIZE : natural := 16;
    type pointerRom is array(0 to SIZE*SIZE-1) of natural range 0 to 2;
    constant rom: pointerRom := (
      0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
      0,1,0,2,2,2,2,2,2,2,2,2,2,2,2,2,
      0,1,1,0,2,2,2,2,2,2,2,2,2,2,2,2,
      0,1,1,1,0,2,2,2,2,2,2,2,2,2,2,2,
      0,1,1,1,1,0,2,2,2,2,2,2,2,2,2,2,
      0,1,1,1,1,1,0,2,2,2,2,2,2,2,2,2,
      0,1,1,1,1,1,1,0,2,2,2,2,2,2,2,2,
      0,1,1,1,1,1,1,1,0,2,2,2,2,2,2,2,
      0,1,1,1,1,1,0,0,0,0,2,2,2,2,2,2,
      0,1,1,1,1,1,0,2,2,2,2,2,2,2,2,2,
      0,1,0,0,1,1,0,2,2,2,2,2,2,2,2,2,
      0,0,2,2,0,1,1,0,2,2,2,2,2,2,2,2,
      0,2,2,2,0,1,1,0,2,2,2,2,2,2,2,2,
      2,2,2,2,2,0,1,1,0,2,2,2,2,2,2,2,
      2,2,2,2,2,0,1,1,0,2,2,2,2,2,2,2,
      2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2
    );
    variable xAddr : natural range 0 to 15;
    variable yAddr : natural range 0 to 15;    
  begin
    RGB <= RGBInterface;
    if pixel >= std_logic_vector(x) and pixel < std_logic_vector(x + size) and line >= std_logic_vector(y) and line < std_logic_vector(y + size) then
      xAddr := to_integer(x(3 downto 0));
      yAddr := to_integer(y(3 downto 0));
      case rom(yAddr * xAddr) is
        when 0 => RGB <= (others => '0');
        when 1 => RGB <= (others => '1');
        when 2 => null;
      end case;
    end if;
  end process;   

end syn;