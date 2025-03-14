---------------------------------------------------------------------
--
--  Fichero:
--    vgaRefresher.vhd  22/01/2024
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Genera las señales de color y sincronismo de un interfaz VGA
--    con resolución 640x420 px
--
--  Notas de diseño:
--    - Válido para frecuencias de reloj multiplos de 25 MHz
--    
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vgaRefresher is
  generic(
    FREQ_DIV  : natural  -- razon entre la frecuencia de reloj del sistema y 25 MHz
  );
  port ( 
    -- host side
    clk   : in  std_logic;   -- reloj del sistema
    line  : out std_logic_vector(9 downto 0);   -- numero de linea que se esta barriendo
    pixel : out std_logic_vector(9 downto 0);   -- numero de pixel que se esta barriendo
    R     : in  std_logic_vector(3 downto 0);   -- intensidad roja del pixel que se esta barriendo
    G     : in  std_logic_vector(3 downto 0);   -- intensidad verde del pixel que se esta barriendo
    B     : in  std_logic_vector(3 downto 0);   -- intensidad azul del pixel que se esta barriendo
    -- VGA side
    hSync : out std_logic := '0';   -- sincronizacion horizontal
    vSync : out std_logic := '0';   -- sincronizacion vertical
    RGB   : out std_logic_vector(11 downto 0) := (others => '0')   -- canales de color
  );
end vgaRefresher;

---------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use work.common.all;

architecture syn of vgaRefresher is

  constant CYCLESxPIXEL : natural := FREQ_DIV;
  constant PIXELSxLINE  : natural := 800;
  constant LINESxFRAME  : natural := 525;
     
  signal hSyncInt, vSyncInt : std_logic;

  signal cycleCnt : natural range 0 to CYCLESxPIXEL-1 := 0;  
  signal pixelCnt : unsigned(pixel'range) := (others=>'0');
  signal lineCnt  : unsigned(line'range)  := (others=>'0');

  signal blanking : boolean;
  
begin

  counters:
  process (clk)
  begin
    if rising_edge(clk) then
      cycleCnt <= cycleCnt + 1;
      if cycleCnt=CYCLESxPIXEL-1 then
        cycleCnt <= 0;
        pixelCnt <= pixelCnt + 1;
        if pixelCnt=PIXELSxLINE-1 then
          pixelCnt <= (others => '0');
          lineCnt <= lineCnt + 1;
          if lineCnt=LINESxFRAME-1 then 
            lineCnt <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  pixel <= std_logic_vector(pixelCnt);
  line  <= std_logic_vector(lineCnt);
  
  hSyncInt <= '1' when pixelCnt >= 656 nand pixelCnt < 752 else '0';
  vSyncInt <= '1' when lineCnt >= 490 nand lineCnt < 492 else '0';        

  blanking <= (pixelCnt >= 640) or (lineCnt >= 480);
  
  outputRegisters:
  process (clk)
  begin
    if rising_edge(clk) then
      if cycleCnt = CYCLESxPIXEL-1 then
          hSync <= hSyncInt; 
          vSync <= vSyncInt;
          for i in 0 to 3 loop
            if not blanking then
              RGB(i + 8) <= R(i);
            end if;
          end loop;
          for i in 0 to 3 loop
            if not blanking then
              RGB(i + 4) <= G(i);
            end if;
          end loop;
          for i in 0 to 3 loop
            if not blanking then
              RGB(i) <= B(i);
            end if;
          end loop;
      end if;
    end if;
  end process;
    
end syn;

