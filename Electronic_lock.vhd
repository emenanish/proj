library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.All;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity Elock is
Port (
seg: out std_logic_vector(6 downto 0);
led: out std_logic_vector(15 downto 0):="0000000000000000";
an: out std_logic_vector(3 downto 0);
sw: in std_logic_vector(3 downto 0);
clk: in std_logic;
btnC: in std_logic;
btnU: in std_logic;
btnD: in std_logic;
btnL: in std_logic;
btnR: in std_logic);
end Elock;
architecture Behavioral of Elock is
signal slowclock: std_logic_vector(25 downto 0);
signal loc: integer range 0 to 3 := 0;
--signal lock: integer range 0 to 3 := 0;
signal press: integer := 0;
signal reset : std_logic := '0';
signal sgd1: std_logic_vector(3 downto 0):="0000";
signal sgd2: std_logic_vector(3 downto 0):="0000";
signal sgd3: std_logic_vector(3 downto 0):="0000";
signal sgd4: std_logic_vector(3 downto 0):="0000";
signal sgdf: std_logic_vector(15 downto 0):="0000000000000000";
--signal sgdt: std_logic_vector(15 downto 0):="0000000000000000";
signal counter: std_logic_vector(1 downto 0);
signal timer10: integer range 0 to 1000000000 := 0;
signal timer30: integer range 0 to 1000000000 := 0;
signal attmpt: integer := 0;
signal abtnc: std_logic := '0';
signal abtnL: std_logic := '0';
signal secs: integer range 0 to 60:= 0;
signal secs30: integer range 0 to 60:= 0;
signal countemp: integer range 0 to 1000000000 := 0;
signal time10: std_logic;
signal pstate: integer := 0;
signal nstate: integer := 0;
signal lstate: integer := 0;
signal pexp: integer := 0;
signal nexp: integer := 0;
--signal lexp: integer := 1;
begin
process (clk)
begin
if rising_edge(clk) then
slowclock <= slowclock + '1';
end if;
end process;
process(clk,timer10,secs,pstate,nstate,reset)
begin
if rising_edge(clk) and pstate = 1 then
if reset = '1' then
timer10 <=0;
secs <=0;
else
if timer10 = 99999999 then
timer10 <=0;
if secs = 9 then
nstate <= 1;
else
secs <= secs + 1;
end if;
else
timer10 <= timer10 +1 ;
end if;
end if;
end if;
end process;

process(clk,timer30,secs30,press,lstate,reset)
begin
if rising_edge(clk) and press = 1 then
if reset = '1' then
timer30 <=0;
secs30 <=0;
else
if timer30 = 99999999 then
timer30 <=0;
if secs30 = 29 then
lstate <= 1;
--press <= 0;
else
secs30 <= secs30 + 1;
end if;
else
timer30 <= timer30 +1 ;
end if;
end if;
end if;
end process;
counter (1 downto 0)  <= slowclock(18 downto 17);
--sgdf <= sgdt;
--timer30  <= slowclock(25);
process (clk,btnL,sgd1,sgdf)
begin
if rising_edge(clk) and btnL = '1' then
press<=1;
sgd1(3 downto 0)<= sw(3 downto 0);
sgdf(15 downto 12) <= sgd1;

end if;
end process;
process (clk,btnU,sgd2,sgdf)
begin
if rising_edge(clk) and btnU = '1' then
sgd2(3 downto 0)<= sw(3 downto 0); 
sgdf(11 downto 8) <= sgd2; end if;
end process;
process (clk,btnD,sgd3,sgdf)
begin
if rising_edge(clk) and btnD = '1' then
sgd3(3 downto 0) <= sw(3 downto 0);
sgdf(7 downto 4) <= sgd3; end if;
end process;
process (clk,btnR,sgd4,sgdf)
begin
if rising_edge(clk) and btnR = '1' then
sgd4(3 downto 0) <= sw(3 downto 0); 
sgdf(3 downto 0) <= sgd4; end if;
end process;
process (clk,btnC,abtnc,attmpt,time10,nstate,lstate,pstate,loc)
begin
if rising_edge(clk) then
if (btnC = '1' and abtnc = '0') then
if attmpt < 1 and loc = 0 then
if lstate = 0 then
if sgdf = "1000010100010011" then
loc <= 1;
attmpt <= 0;
pstate <= 0;

else 
attmpt <= attmpt +1;
if attmpt > 1 then
loc <= 2;
pstate <= 1;
nexp <= 0;
end if;
end if;
end if;
elsif loc = 1 then
loc <= 0 ;
attmpt <= 0;
--pexp <= 0;
else
loc <= 2;
pstate <= 1;
nexp <= 0;
attmpt <= 0;
end if;
elsif nexp=0 and nstate = 1 then
loc <= 0;
attmpt <= 0;
nexp <= 1;
--lstate <= 0;
end if;
abtnc <= btnc;
end if;
end process;

process(loc)
begin
if loc = 1 then
led <= "1111111111111111";
elsif loc = 0 then
led <= "0000000000000000";
end if;
end process;

process(counter,sgdf,loc)
begin 
case counter is 
when "00" => an <= "0111";
if loc = 1 then
seg<="1000001";
elsif loc = 2 then
seg <="0001100";
elsif loc = 0 then
seg <= "1111111";

end if;
when "01" => an <= "1011";
if loc = 1 then
seg<="0101011";
elsif loc = 2 then
seg <= "0001000";
elsif loc = 0 then
 seg <= "1000111";

end if;
when "10" => an <= "1101";
if loc = 1 then
seg<="1000111";
elsif loc = 2 then
seg <= "1000001";
elsif loc = 0 then
seg <= "1000000";

end if;
when "11" => an <= "1110";
if loc = 1 then
seg<= "1000110";
elsif loc = 2 then
seg <= "0010010";
elsif loc = 0 then
 seg <= "1000110";

end if;
end case;
end process;

end Behavioral;
