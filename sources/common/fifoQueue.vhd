-------------------------------------------------------------------
--
--  Fichero:
--    fifo.vhd  1/10/2015
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Buffer de tipo FIFO
--
--  Notas de diseño:
--    - Está implementada como un banco de registros
--    - Si la FIFO está llena, los nuevos datos que se intenten 
--      almacenar se ignoran
--    - Si la FIFO está vacía, las lecturas devuelven valores no
--      validos
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

entity fifoQueue is
  generic (
    WL    : natural;   -- anchura de la palabra de fifo
    DEPTH : natural    -- numero de palabras en fifo
  );
  port (
    clk     : in  std_logic;   -- reloj del sistema
    rst     : in  std_logic;   -- reset síncrono del sistema
    wrE     : in  std_logic;   -- se activa durante 1 ciclo para escribir un dato en la fifo
    dataIn  : in  std_logic_vector(WL-1 downto 0);   -- dato a escribir
    rdE     : in  std_logic;   -- se activa durante 1 ciclo para leer un dato de la fifo
    dataOut : out std_logic_vector(WL-1 downto 0);   -- dato a leer
    numData : out std_logic_vector(log2(DEPTH)-1 downto 0);   -- numero de datos almacenados
    full    : out std_logic;   -- indicador de fifo llena
    empty   : out std_logic    -- indicador de fifo vacia
  );
end fifoQueue;

-------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;

architecture syn of fifoQueue is

  type regFileType is array (0 to DEPTH-1) of std_logic_vector(WL-1 downto 0);

  -- Registros
  signal regFile : regFileType := (others => (others => '0'));
  signal wrPointer, rdPointer : natural range 0 to DEPTH-1 := 0;
  signal isFull  : std_logic := '0';
  signal isEmpty : std_logic := '1';
  
  -- Señales  
  signal nextWrPointer, nextRdPointer : natural range 0 to DEPTH-1;
  signal rdFifo  : std_logic;
  signal wrFifo  : std_logic;
  
begin
  -- el banco de registros siempre hace la lectura en dataOut, 
  -- pero solo escribe si recibe alguna peticion de escritura 
  registerFile:
  process (clk, rdPointer, regFile)
  begin
    dataOut <= regFile(rdPointer);
    if rising_edge(clk) then
      if wrFifo='1' then
        regFile(wrPointer) <= dataIn;
      end if;
    end if;
  end process;
  
  -- escribo si recibo peticion y no esta llena
  wrFifo <= '1' when wrE = '1' and isFull = '0' else '0';
  
  -- leo si recibo peticion y no esta vacia
  rdFifo <= '1' when rdE = '1' and isEmpty = '0' else '0';
  
  -- Sumadores para el puntero de lectura
  nextWrPointer <=  0 when wrPointer = DEPTH-1 else wrPointer + 1;
  nextRdPointer <= 0 when rdPointer = DEPTH-1 else rdPointer + 1 ;
    
  fsmd:
  process (clk)     
  begin     
    if rising_edge(clk) then
      if rst='1' then
        wrPointer <= 0;
        rdPointer <= 0;
        isFull    <= '0';
        isEmpty   <= '1';
      else
        -- peticion de escritura
        if wrFifo='1' then
          if (nextWrPointer = rdPointer) then 
            isFull <= '1';
          else 
            isFull <= '0';
          end if;
          isEmpty <= '0';
          wrPointer <= nextWrPointer;
          end if;
        end if;
        -- peticion de lectura
        if rdFifo='1' then
          if (nextRdPointer = wrPointer) then 
            isEmpty <= '1';
          else 
            isEmpty <= '0';
          end if;          
          isFull <= '0';
          rdPointer <= nextRdPointer;
        end if;
      end if;
  end process;
 
  full    <= isFull;
  empty   <= isEmpty;
  numData <= std_logic_vector(to_unsigned(WrPointer - RdPointer, log2(DEPTH)));
 
end syn;


