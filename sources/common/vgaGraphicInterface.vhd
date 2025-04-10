---------------------------------------------------------------------
--
--  Fichero:
--    vgaGraphicInterface.vhd  04/03/2024
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Genera las señales de color y sincronismo de un interfaz gráfico
--    VGA con resolución de 640x480 pixeles.
--
--  Notas de diseño:
--    - Para frecuencias a partir de 50 Mhz en multiplos de 25 MHz
--    - Incluye una memoria de refresco para almacenar los pixeles
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vgaGraphicInterface is
  generic(
    FREQ_DIV : natural  -- valor por el que dividir la frecuencia del reloj del sistema para obtener 25 MHz
  );
  port ( 
    -- host side
    clk     : in std_logic;   -- reloj del sistema
    clear   : in std_logic;   -- borra la memoria de refresco
    dataRdy : in std_logic;   -- se activa durante 1 ciclo cada vez que hay un nuevo pixel a visualizar
    color   : in std_logic_vector (2 downto 0);   -- color del pixel a visualizar
    x       : in std_logic_vector (9 downto 0);   -- columna en donde visualizar el pixel
    y       : in std_logic_vector (8 downto 0);   -- fila en donde visualizar el pixel
    --
    line    : out std_logic_vector(8 downto 0);   -- numero de linea que se esta barriendo
    pixel   : out std_logic_vector(9 downto 0);   -- numero de pixel que se esta barriendo
    -- VGA side
    hSync   : out std_logic;   -- sincronizacion horizontal
    vSync   : out std_logic;   -- sincronizacion vertical
    RGB     : out std_logic_vector (11 downto 0)   -- canales de color
  );
end vgaGraphicInterface;

---------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture syn of vgaGraphicInterface is

  constant PIXELSxLINE : natural := 640;
  constant LINESxFRAME : natural := 480;
  
  signal pixelRefresher : std_logic_vector (9 downto 0);
  signal lineRefresher  : std_logic_vector (9 downto 0);
    
  signal xInt     : std_logic_vector (x'range);
  signal yInt     : std_logic_vector (y'range);
  
  signal clearX   : unsigned (x'range) := (others => '0');
  signal clearY   : unsigned (y'range) := (others => '0');
  signal clearing : std_logic;
 
  signal ramRdAddr, ramWrAddr : std_logic_vector (18 downto 0);
  signal we : std_logic;
  signal ramWrData     : std_logic_vector (2 downto 0);
  
  signal R, G, B : std_logic_vector(3 downto 0);
  
  type   ramType is array (0 to 2**(x'length+y'length)-1) of std_logic_vector (color'range);
  signal ram : ramType;
  
begin

  screenInteface: vgaRefresher
    generic map ( FREQ_DIV => FREQ_DIV )
    port map ( clk => clk, line => lineRefresher, pixel => pixelRefresher, R => R, G => G, B => B, hSync => hSync, vSync => vSync, RGB => RGB );
    
  line  <= lineRefresher(8 downto 0);
  pixel <= pixelRefresher;

------------------  

  we        <= clearing or dataRdy;
  ramWrData <= color when clearing = '0' else (others => '0');      
  ramWrAddr <= Y & X when clearing = '0' else std_logic_vector(clearY & clearX); 
  ramRdAddr <= lineRefresher(8 downto 0) & pixelRefresher;
  
  process (clk)
    variable ramOut : std_logic_vector (2 downto 0);
  begin
    R <= (others => ramOut(2));
    G <= (others => ramOut(1));
    B <= (others => ramOut(0));  
    if rising_edge(clk) then
      if we ='1' then
        ram( to_integer( unsigned( ramWrAddr ) ) ) <= ramWrData;
      end if;
      ramOut := ram( to_integer( unsigned( ramRdAddr ) ) );
    end if;
  end process;  
  
  clearCounters:
  process (clk, clearX, clearY, clear)
  begin
    if clear = '1' or clearX /= (9 downto 0 => '0') or clearY /= (8 downto 0 => '0') then
      clearing <= '1';
    else
      clearing <= '0';
    end if;
    
    if rising_edge(clk) then
      if clear='1' or clearing='1' then
        if (clearX = PIXELSxLINE) then
            clearX <= (others => '0');
            if (clearY = LINESxFRAME) then
                clearY <= (others => '0');
            else
                clearY <= clearY + 1;
            end if;
        else clearX <= clearX + 1;
        end if;
      end if;
    end if;
  end process; 
     
END syn;
