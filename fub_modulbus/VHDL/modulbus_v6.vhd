--TITLE "'ModulBus_V6' => Modul-Bus-Macro mit 16Bit-Anwender-I/O, Autor: W.Panschow, Stand: 12.10.06, Vers: V06 ";

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+ Beschreibung:
--+ 
--+  Das Macro 'Modul_Bus_Macro' realisiert die Schnittstelle zum Modul-Bus, es hat zwei Betriebsarten.
--+  
--+     1) Der Normalbetrieb:
--+     Hierbei müssen  a l l e  fest verdrahtete Signalgruppen (VG-Leiste)
--+     mit den Modul-Bus-Signalen und Kartenkennungen übereinstimmen.
--+     Wenn:
--+             I)      VG_Mod_ID[7..0] == MOD_ID[7..0] ist, steckt richtige Karte auf dem richtigen Busplatz.
--+                     Wobei VG_Mod_ID[] den Kartentyp vorgibt, der an diesem Steckplatz erwartet wird, und
--+                     MOD_ID[] den Typ der bestückten Karte beschreibt. Über den Parameter 'MOD_ID' wird
--+                     MOD_ID[] festgelegt, dezimal 37 entspricht z.B. dem Kartentyp Event-Sequencer.
--+
--+             II)     VG_Mod_Adr[4..0] == Mod_Adr[4..0] ist, wird der entsprechende Busplatz adressiert.
--+                     Wobei VG_Mod_Adr[] die Adresse des Steckplatzes festlegt und Mod_Adr[] die aktuell
--+                     angesprochene Modul_Bus_Adresse darstellt.
--+
--+                     Außerdem sollte die Sub_Adresse des Modul-Busses 'Sub_Adr[7..0]' eine gültige Funktion beim jeweiligen
--+                     Kartentyp auslösen. Nur dann sollte von der Adressdekodierung ein 'DT_Adr_Deco' kommen und der Daten-Bus-
--+                     Treiber zum Modul-Bus aktiviert werden.
--+
--+     2) Der Diagnosebetrieb:
--+
--+                     Hier steckt  n i c h t  die richtige Karte auf dem richtigen Busplatz ( VG_Mod_ID[] <> MOD_ID[] ).
--+                     Um solch eine Fehlkonfiguration mit Software erkennen zu können gibt es sechs standardisierte Subadressen.
--+                     Stimmt die am Steckplatz fest verdrahtete VG_Mod_Adr[4..0] mit der auf den Modul-Bus angelegten
--+                     Mod_Adr[4..0] überein, liefert der Macro zumindest bei diesen sechs Subadressen:
--+
--+                             1) Die am Steckplatz verdrahtetete VG_Mod_ID[].
--+                             2) Die MOD_ID[] des bestückten Kartentyps.
--+                             Siehe auch im Konstanten-Definitionsteil nach 'C_Rd_ID'.
--+                             3) Das VG_Skalierungsbyte.
--+                             4) Die VG_Mod_Adresse.
--+                                Siehe auch im Konstanten-Definitionsteil nach 'C_Rd_Skal_Adr'.
--+                             5) Die EPLD_Vers[7..0].
--+                             6) Das Status_Reg[7..0]:        Bit0 = 'Power_Up_Reset'
--+                                Bit1 = 'Timeout', das LB des Modulbustransfers ist nicht rechtzeitig vom
--+                                Modulbus-Kontroller geliefert worden.
--+                                Bit2..7 = Stat_IN[2..7]
--+
--+                                Lesen: liefert das Status_Reg[], Schreiben: Eine '1' an die Bits[1..0] geschrieben, loescht die
--+                                Bits[1..0] im Status_Reg[].
--+                                7)* Lese 'ST_160_Skal[7..0]'
--+                                8)* Lese 'Macro_Activ'([7]), 'Macro_Skal_OK'([6]) und 'ST_160_Auxi[5..0]'
--+                                Der Macro gibt nur für diese 6 (8)* Lese-Subadressen das Dtack 'DT_Mod_Bus'. Alle anderen Subadressen
--+                                belassen den 'Modul_Bus_Macro' im passiven Zustand.
--+
--+     *) Nur wenn 'St_160pol' gleich '1' ist.
--+
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.MATH_REAL.all;
library lpm;
use lpm.lpm_components.all;

--library work;
--USE PW_VHDL_LIB.all;

entity modulbus_v6 is
  generic(
    St_160_pol      : integer := 0;  --      0 ==> VG96-Modulbus,    1 ==> 160 poliger Modulbus (5-Reihig)                           --
    Mod_Id          : integer := 16#55#;
    CLK_in_Hz       : integer := 50000000;  -- Damit das Design schnell auf eine andere Frequenz umgestellt werden kann, wird diese         --
    -- in Hz festgelegt. Zähler die betimmte Zeiten realisieren sollen z.B. 'time_out_cnt'          --
    -- werden entprechend berechnet.
    Loader_Base_Adr : integer := 240;
    Res_Deb_in_ns   : integer := 100;
    nDS_Deb_in_ns   : integer := 20;
    Use_LPM         : integer := 0;
    Test            : integer := 0
    );
  port(
    Epld_Vers     : in  std_logic_vector(7 downto 0) := "00000000";
    VG_Mod_Id     : in  std_logic_vector(7 downto 0);  -- Der an diesem Modul-Bus-Steckplatz erwartete Karten-Typ (an der VG-Leiste fest verdrahtet).  --
    VG_Mod_Adr    : in  std_logic_vector(4 downto 0);  -- Adresse des Modul-Bus-Steckplatzes (an der VG-Leiste fest verdrahtet).                                               --
    VG_Mod_Skal   : in  std_logic_vector(7 downto 0);  -- Modul-Bus-Skalierung, für jeden Kartentyp unterschiedl. Bedeutung (an VG-Leiste verdrahtet). --
    St_160_Skal   : in  std_logic_vector(7 downto 0);
    St_160_Auxi   : in  std_logic_vector(5 downto 0);
    Stat_IN       : in  std_logic_vector(7 downto 2);
    Macro_Activ   : in  std_logic                    := '1';
    Macro_Skal_OK : in  std_logic                    := '1';
    Mod_Adr       : in  std_logic_vector(4 downto 0);  -- Adresse des gerade laufenden Modul-Bus-Zyklusses.                                                                                    --      
    Sub_Adr       : in  std_logic_vector(7 downto 0);  -- Sub-Adresse des gerade laufenden Modul-Bus-Zyklusses.                                                                                --      
    RDnWR         : in  std_logic;  -- Lese/Schreibsignal des Modul-Busses. RD/WR = 1 => Lesen.                                                                             --
    nDS           : in  std_logic;  -- Datenstrobe des Modul-Busses. /DS = 0 => aktiv.                                                                                              --
    CLK           : in  std_logic;  -- Systemtakt des restlichen Designs sollte >= 12 Mhz sein.                                                                             --
    nMB_Reset     : in  std_logic;
    V_Data_Rd     : in  std_logic_vector(15 downto 0);  -- Data to Modulbus, alle Daten-Quellen die außerhalb dieses Macros liegen sollten hier über    --
    -- Multiplexer angeschlossen werden.                                                                                                                    --
    nExt_Data_En  : out std_logic;  -- Signal = 0, schaltet externen Datentreiber des Modul-Busses ein.

    Mod_Data : inout std_logic_vector(7 downto 0);  -- Daten-Bus des Modul-Busses.                                                                                                                                  --

    nDt_Mod_Bus     : out std_logic;  -- Data-Acknowlege zum Modul-Bus.                                                                                                                               --
    Sub_Adr_La      : out std_logic_vector(7 downto 1);
    Data_Wr_La      : out std_logic_vector(15 downto 0);
    Extern_Wr_Activ : out std_logic;
    Extern_Wr_Fin   : out std_logic;
    Extern_Rd_Activ : out std_logic;
    Extern_Rd_Fin   : out std_logic;
    Extern_Dtack    : in  std_logic;  -- Alle extern dekodierten Modul-Bus-Aktionen, müssen hier ihr Dtack anlegen.                                   --
    Powerup_Res     : out std_logic := '0';
    nInterlock      : out std_logic;
    Timeout         : out std_logic;
    Id_OK           : out std_logic;
    nID_OK_Led      : out std_logic;
    Led_Ena         : out std_logic;
    nPower_Up_Led   : out std_logic;
    nSel_Led        : out std_logic;
    nDt_Led         : out std_logic
    );

  constant Clk_in_ps : integer := 1000000000 / (Clk_in_Hz / 1000);
  constant Clk_in_ns : integer := 1000000000 / Clk_in_Hz;

  constant C_Timeout_in_ns : integer := 2800;  --  2,8 us      --
  constant C_Timeout_cnt   : integer := C_timeout_in_ns * 1000 / Clk_in_ps;

  constant C_Led_Time_in_ns  : integer := 25000000;  -- 25 ms        --
  constant C_Led_Ena_Cnt     : integer := C_Led_Time_in_ns / Clk_in_ns;
  constant C_Led_Ena_Tst_Cnt : integer := 3;



  ----------------------------------------------------------------------------------------------
  -- Standardisierte Subadresse zum Lesen der IDs.                                            --
  -- Achtung nur Bit[7..1] definiert. Bit0 dient zur HB-LB-Kennung.                           --
  -- Bit0 = 0 => HB = Subadr. FE => lese 'MOD_ID[7..0]'    = ID der Karte,                    --
  -- Bit0 = 1 => LB = Subadr. FF => lese 'VG_MOD_ID[7..0]' = ID der VG-Leiste.                --
  ----------------------------------------------------------------------------------------------
  constant C_Rd_ID : std_logic_vector(7 downto 0) := X"FE";

  ----------------------------------------------------------------------------------------------
  -- Standardisierte Subadresse zum Lesen der Skalierung und der Moduladresse.                --
  -- Achtung nur Bit[7..1] definiert. Bit0 dient zur HB-LB-Kennung.                           --
  -- Bit0 = 0 => HB = Subadr. FC => lese 'VG_Mod_Skal[7..0]' = Skalierung an der VG-Leiste    --
  -- Bit0 = 1 => LB = Subadr. FD => lese 'VG_Mod_Adr[4..0]'  = Moduladresse an der VG-Leiste. --
  ----------------------------------------------------------------------------------------------
  constant C_Rd_Skal_Adr : std_logic_vector(7 downto 0) := X"FC";

  ----------------------------------------------------------------------------------------------
  -- Standardisierte Subadresse zum Lesen der EPLD-Version und Lesen Rücksetzen                         --
  -- des 'Status-Reg[7..0]'.                                                                                                                                    --
  -- Achtung nur Bit[7..1] definiert. Bit0 dient zur HB-LB-Kennung.                                     --
  -- Bit0 = 0 => HB = Subadr. FA => lese 'Epld_Vers[7..0]'                                                                      --
  -- Bit0 = 1 => LB = Subadr. FB => lesen/rücksetzen des 'Status-Reg[7..0]'.                                    --
  ----------------------------------------------------------------------------------------------
  constant C_Rd_EPLD_Vers_Rd_Wr_Stat : std_logic_vector(7 downto 0) := X"FA";

  ----------------------------------------------------------------------------------------------
  -- Standardisierte Subadresse bei selektiertem 160pol. Stecker (Paramerter 'ST_160pol = 1)    --
  -- wird die 2. Skalierung 'ST_160_Skal[]' und von 'ST_160_Auxi[]' gelesen.                                    --
  -- Achtung nur Bit[7..1] definiert. Bit0 dient zur HB-LB-Kennung.                           --
  -- Bit0 = 0 => HB = Subadr. F8 => lese 'ST_160_Skal[7..0]' = 2tes Skalierungsbyte                 --
  -- Bit0 = 1 => LB = Subadr. F9 => lese 'ST_160_Auxi[5..0]' = z.B. Logiauswahlschalter bei     --
  -- der 'MB64-APK'.                                                                                                                                                    --
  ----------------------------------------------------------------------------------------------
  constant C_Rd_Skal2_Adr : std_logic_vector(7 downto 0) := X"F8";

  ------------------------------------------------------------------------------------------------------
  -- Die Adressen Loader-Base-Adr bis Loader-Base-Adr+3 sollen genau wie die interen Zugriffe unab-     --
  -- hängig vom ID des Steckplatzes funktionieren. Es sollen aber die exteren Strobes erzeugt werden,   --
  -- da der Loader-Macro nicht im Modulbus-Macro integriert werden soll.                                                                --
  ------------------------------------------------------------------------------------------------------
  constant C_Loader_Base_Adr : std_logic_vector(7 downto 0) := conv_std_logic_vector(Loader_Base_Adr, 8);



  function set_cnt_ge_1 (production_cnt : integer) return integer is

    variable cnt : integer;
    
  begin
    if production_cnt > 1 then
      cnt := production_cnt;
    else
      cnt := 1;
    end if;
    return cnt;
  end set_cnt_ge_1;


  function prod_or_test (production, test_data, test : integer) return integer is

    variable data : integer;
    
  begin
    if Test = 1 then
      data := test_data;
    else
      data := production;
    end if;

    return data;

  end prod_or_test;

  constant C_Res_Deb_cnt : integer := set_cnt_ge_1(Res_Deb_in_ns * 1000 / Clk_in_ps);

  constant C_nDS_Deb_cnt : integer := set_cnt_ge_1(nDS_Deb_in_ns * 1000 / Clk_in_ps);
  
end modulbus_v6;


architecture Arch_modulbus_v6 of modulbus_v6 is

  type T_State_Mod_SM is (
    Idle,
    Rd_HB,
    Wait_Rd_LB,
    Rd_LB,
    Rd_Fin,
    Wr_HB,
    Wait_Wr_LB,
    Wr_LB,
    WR_Fin);

  signal State_Mod_SM : T_State_Mod_SM;

  function How_many_Bits (int : integer) return integer is

    variable i, tmp : integer;

  begin
    tmp := int;
    i   := 0;
    while tmp > 0 loop
      tmp := tmp / 2;
      i   := i + 1;
    end loop;
    return i;
  end How_many_bits;


  constant C_Ld_Led_cnt : integer := prod_or_test(C_Led_Ena_Cnt, C_Led_Ena_Tst_Cnt, Test);



  signal S_MB_Macro_Rd_Mux : std_logic_vector(7 downto 0);
  signal S_Timeout_cnt     : std_logic_vector((How_many_Bits(C_Timeout_cnt)) downto 0);
  signal S_Sel_To_Cnt      : std_logic;
  signal S_Set_TO_Cnt      : std_logic;
  signal S_Timeout         : std_logic;
  signal S_Adr_OK          : std_logic_vector(1 downto 0);  -- Als Vektor damit Flankenerkennung möglich ist.
  signal S_ID_OK           : std_logic;
  signal S_DS_Sync         : std_logic;
  signal S_DS              : std_logic;
  signal S_DT_Intern       : std_logic;
  signal S_Status_Reg      : std_logic_vector(1 downto 0);
  signal S_Wr_Status_Reg   : std_logic;
  signal S_Wr_Status_Reg_r : std_logic;
  signal S_Powerup_Res_Cnt : std_logic_vector(2 downto 0) := "000";
  signal S_Powerup_Res     : std_logic;
  signal S_Sub_Adr_La      : std_logic_vector(7 downto 1);
  signal S_Data_Wr_La      : std_logic_vector(15 downto 0);

  signal S_DT_Delay : std_logic_vector(2 downto 0);

  signal S_Led_Ena : std_logic;

  constant C_Led_Time_Width : integer := integer(ceil(log2(real(C_Led_Ena_Cnt))));
  signal S_Led_cnt          : std_logic_vector(C_Led_Time_Width downto 0);

  signal S_Extern_Access : std_logic;
  signal S_Intern_Access : std_logic;

  signal S_Extern_Wr_Activ : std_logic_vector(1 downto 0);
  signal S_Extern_Wr_Fin   : std_logic;

  signal S_Extern_Rd_Activ : std_logic;
  signal S_Extern_Rd_Fin   : std_logic;

  signal S_Start_DT_Led : std_logic;

  signal S_SM_Reset : std_logic;

  signal S_Adr_Comp_Live : std_logic;  -- Das Live Signal des Adressvergleichers
  signal S_Adr_Comp_DB   : std_logic;  -- Das Entprellte Signal des Adressvergleichers

  signal S_MB_Reset : std_logic;
  signal MB_Reset   : std_logic;  -- um (... <= not nMB_Reset) bei der Instanzierung zu vermeiden


  component Led
    generic (
      Use_LPM : integer := 1
      );
    port(
      clk    : in  std_logic;
      ena    : in  std_logic;
      Sig_In : in  std_logic;
      nled   : out std_logic
      );
  end component;


  component Debounce
    generic(
      DB_Cnt     : integer := 3;
      DB_Tst_Cnt : integer := 3;
      Use_LPM    : integer := 0;
      Test       : integer := 0
      );
    port(
      DB_In  : in  std_logic;
      Reset  : in  std_logic;
      Clk    : in  std_logic;
      DB_Out : out std_logic
      );
  end component;
  

begin

  assert (false)
    report "C_Led_Time_in_ns = " & integer'image(C_Led_Time_in_ns) & ",     C_Led_Time_Width = " & integer'image(C_Led_Time_Width+1)
    severity note;

  assert (false)
    report "C_nDS_Deb_cnt = " & integer'image(C_nDS_Deb_cnt) & ",     C_Res_Deb_cnt = " & integer'image(C_Res_Deb_cnt)
    severity note;


  P_SM_Reset : process (clk)
  begin
    if clk'event and clk = '1' then
      if S_Timeout = '1' or S_Powerup_Res = '1' then
        S_SM_Reset <= '1';
      else
        S_SM_Reset <= '0';
      end if;
    end if;
  end process P_SM_Reset;

  Mod_SM : process (clk, S_SM_Reset)

  begin
    if S_SM_Reset = '1' then
      State_Mod_SM <= Idle;
    elsif clk'event and clk = '1' then

      S_Extern_Wr_Fin <= '0';
      S_Extern_Rd_Fin <= '0';

      case State_Mod_SM is

        when Idle =>
          S_Extern_Access   <= '0';
          S_Intern_Access   <= '0';
          S_Extern_Wr_Activ <= (others => '0');
          S_Extern_Rd_Activ <= '0';
          if S_Adr_Comp_DB = '1' and S_DS_Sync = '1' and Sub_Adr(0) = '0' then
            S_Sub_Adr_La <= Sub_Adr(7 downto 1);
            if Sub_Adr(7 downto 1) >= C_Rd_Skal2_Adr(7 downto 1) then
              S_Intern_Access <= '1';
              S_Extern_Access <= '0';
            else
              S_Intern_Access <= '0';
              if S_ID_OK = '1' or Sub_Adr(7 downto 2) = C_Loader_Base_Adr(7 downto 2) then  -- Die 2 Loader-Sub-Adr.--
                S_Extern_Access <= '1';  -- sollen unabhägig vom --
              end if;  -- ID funktionieren!    --
            end if;
            if RDnWR = '1' then
              State_Mod_SM <= Rd_HB;
            else
              State_Mod_SM <= Wr_HB;
            end if;
          end if;

        when Rd_HB =>
          if S_Extern_Access = '1' then
            S_Extern_Rd_Activ <= '1';
          end if;
          if S_DS_Sync = '0' then
            State_Mod_SM <= Wait_Rd_LB;
          end if;

        when Wait_Rd_LB =>
          if S_DS_Sync = '1' and Sub_Adr(0) = '1' then
            State_Mod_SM <= Rd_LB;
          end if;
          
        when Rd_LB =>
          if S_DS_Sync = '0' then
            S_Extern_Rd_Activ <= '0';
            S_Extern_Rd_Fin   <= '1';  -- V06, wurde in V05 erst in State "Rd_Fin" gesetzt!
            State_Mod_SM      <= Rd_Fin;
          end if;

        when Rd_Fin =>
          S_Extern_Access <= '0';
          S_Intern_Access <= '0';
          State_Mod_SM    <= Idle;

        when Wr_HB =>
          S_Data_Wr_La(15 downto 8) <= Mod_Data;
          if S_DS_Sync = '0' then
            State_Mod_SM <= Wait_Wr_LB;
          end if;
          
        when Wait_Wr_LB =>
          if S_DS_Sync = '1' and Sub_Adr(0) = '1' then
            State_Mod_SM <= Wr_LB;
          end if;

        when Wr_LB =>
          S_Data_Wr_La(7 downto 0) <= Mod_Data;
          if S_Extern_Access = '1' then
            S_Extern_Wr_Activ <= (S_Extern_Wr_Activ(0), '1');
          end if;
          if S_DS_Sync = '0' then
            S_Extern_Wr_Activ <= (others => '0');
            S_Extern_Wr_Fin   <= '1';  -- V06, wurde in V05 erst in State "WR_Fin" gesetzt!
            State_Mod_SM      <= WR_Fin;
          end if;

        when WR_Fin =>
          S_Extern_Access <= '0';
          S_Intern_Access <= '0';
          State_Mod_SM    <= Idle;

      end case;
    end if;
  end process Mod_SM;

  P_DT_MOD_Bus : process (clk, S_SM_Reset)

  begin
    if S_SM_Reset = '1' then
      S_DT_Delay     <= (others => '0');
      S_Start_DT_Led <= '0';
    elsif clk'event and clk = '1' then
      S_DT_Delay     <= (others => '0');
      S_Start_DT_Led <= '0';
      if S_DT_Intern = '1' then
        S_DT_Delay(S_DT_Delay'range) <= (S_DT_Delay(S_DT_Delay'high-1 downto 0) & '1');
        S_Start_DT_Led               <= '1';
      elsif S_Extern_Access = '1' then
        if (State_Mod_SM = Rd_HB or State_Mod_SM = Wr_LB) and Extern_Dtack = '1' then
          S_DT_Delay(S_DT_Delay'range) <= (S_DT_Delay(S_DT_Delay'high-1 downto 0) & '1');
                                        -- Beim Lesen muss der externe Macro beim High Byte schon gültige       --
          S_Start_DT_Led               <= '1';  -- Daten liefern, beim Schreiben wird das Datum erst mit dem            --
                                        -- Low Byte vom externen Macro gespeichert. Deshalb wird                        --
                                        -- Extern_Dtack hier ausgewertet.                                                                       --
        elsif State_Mod_SM = Rd_LB or State_Mod_SM = Wr_HB then
          S_DT_Delay(S_DT_Delay'range) <= (S_DT_Delay(S_DT_Delay'high-1 downto 0) & '1');
                                        -- Beim Lesen ist das Low Byte gleichzeitig mit dem High Byte           --
                                        -- gültig. Beim Schreiben wird das High Byte erst zwischenge-           --
                                        -- speichert. In beiden Fällen wird Dtack ohne Abfrage von                      --
                                        -- Extern_Dtack aktiv.                                                                                          --
        end if;
      end if;
    end if;
  end process P_DT_MOD_Bus;

  nDT_MOD_Bus <= '0' when (S_DT_Delay(S_DT_Delay'high) and not nDS) = '1' else '1';  --hier kein 'Z' für fib

  nExt_Data_En <= not ((S_Intern_Access or S_Extern_Access) and not nDS);
--nExt_Data_En <= not (S_Adr_OK(1) and not nDS);

  Sub_Adr_La <= S_Sub_Adr_La;


  ID_OK <= S_ID_OK;

  P_ID_OK : process (clk, S_Powerup_Res)
  begin
    if S_Powerup_Res = '1' then
      S_ID_OK    <= '0';
      nID_OK_Led <= 'Z';
    elsif clk'event and clk = '1' then
      if VG_Mod_ID = CONV_STD_LOGIC_VECTOR(MOD_ID, 8) then
        S_ID_OK    <= '1';
        nID_OK_Led <= '0';
      else
        S_ID_OK    <= '0';
        nID_OK_Led <= 'Z';
      end if;
    end if;
  end process;

  P_Status_Reg : process (clk, S_Powerup_Res)
  begin
    if S_Powerup_Res = '1' then
      S_Status_Reg      <= ("01");
      S_Wr_Status_Reg_r <= '0';
    elsif clk'event and clk = '1' then
      S_Wr_Status_Reg_r <= S_Wr_Status_Reg;
      if S_Wr_Status_Reg_r = '1' then
        S_Status_Reg <= S_Status_Reg and not S_Data_Wr_La(1 downto 0);
      elsif S_Timeout = '1' then
        S_Status_Reg(1) <= '1';
      end if;
    end if;
  end process;


  P_Interlock : process (S_Status_Reg(0))  -- Powerup_Res wird dem Modulbus-Kontroller über Interlock gemeldet
  begin
    if S_Status_Reg(0) = '0' then
      nInterlock <= 'Z';
    else
      nInterlock <= '0';
    end if;
  end process P_Interlock;

  P_Adr_Deco_Read_Mux : process (
    S_Sub_Adr_La, State_Mod_SM,
    VG_MOd_ID, VG_Mod_Skal, VG_Mod_Adr, EPLD_Vers,
    ST_160_Skal, Stat_IN, Macro_Activ, Macro_Skal_OK, ST_160_Auxi,
    S_Status_Reg, V_Data_Rd, S_Extern_Access, S_Intern_Access
    )
  begin
    S_MB_Macro_Rd_Mux <= (others => '0');
    S_DT_Intern       <= '0';
    S_Wr_Status_Reg   <= '0';
    if S_Extern_Access = '1' then
      --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Es besteht kein Diagnose-Zugriff auf die Modul-Buskarte, d.h. andere Lese-Register sind von anderen Macros an den              +
      -- Eingang Data_RD[15..0] zu legen und das Signal 'Extern_Dtack' muß 'S_MB_Macro_Rd_Mux[]' zum Scheiben in Richtung Modul-Bus schalten.   +
      --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      if State_Mod_SM = Rd_HB then
        S_MB_Macro_Rd_Mux <= V_Data_Rd(15 downto 8);
      elsif State_Mod_SM = Rd_LB then
        S_MB_Macro_Rd_Mux <= V_Data_Rd(7 downto 0);
      end if;
    elsif S_Intern_Access = '1' then
      case S_Sub_Adr_La(4 downto 1) is
        when C_Rd_ID(4 downto 1) =>
          if State_Mod_SM = Rd_HB then
            S_DT_Intern       <= '1';
            S_MB_Macro_Rd_Mux <= CONV_STD_LOGIC_VECTOR(MOD_ID, 8);  -- HB des 'ID' lesen = 'MOD_ID' zum Modul-Bus schalten.                 --
          end if;
          if State_Mod_SM = Rd_LB then
            S_DT_Intern       <= '1';
            S_MB_Macro_Rd_Mux <= VG_Mod_ID;  -- LB des 'ID' lesen = 'VG_Mod_ID[]' zum Modul-Bus schalten.    --
          end if;
        when C_Rd_Skal_Adr(4 downto 1) =>
          if State_Mod_SM = Rd_HB then
            S_DT_Intern       <= '1';
            S_MB_Macro_Rd_Mux <= VG_Mod_Skal;  -- HB der 'Skalierung-Adresse' = 'VG_Mod_Skal[]' zum Modul-Bus. --
          end if;
          if State_Mod_SM = Rd_LB then
            S_DT_Intern       <= '1';
            S_MB_Macro_Rd_Mux <= ('0'&'0'&'0'& VG_MOD_Adr);  -- LB der 'Skalierung-Adresse' = 'VG_Mod_Adr[]' zum Modul-Bus.. --
          end if;
        when C_Rd_EPLD_Vers_Rd_Wr_Stat(4 downto 1) =>
          if State_Mod_SM = Rd_HB then
            S_DT_Intern       <= '1';
            S_MB_Macro_Rd_Mux <= EPLD_Vers;  -- HB = 'EPLD-Vers[]' zum Modul-Bus.                                                    --
          end if;
          if State_Mod_SM = Rd_LB then
            S_DT_Intern       <= '1';
            S_MB_Macro_Rd_Mux <= (Stat_IN(7 downto 2) & S_Status_Reg);  -- LB = 'Status_Reg[]' lesen.                                                             --
          end if;
          if State_Mod_SM = Wr_HB then
            S_DT_Intern <= '1';
          end if;
          if State_Mod_SM = Wr_LB then
            S_DT_Intern <= '1';
          end if;
          if State_Mod_SM = Wr_Fin then
            S_Wr_Status_Reg <= '1';
          end if;
        when C_Rd_Skal2_Adr(4 downto 1) =>
          if St_160_pol = 1 then
            if State_Mod_SM = Rd_HB then
              S_DT_Intern       <= '1';
              S_MB_Macro_Rd_Mux <= ST_160_Skal;  -- HB von 'Rd_Skal2' = 'ST_160_Skal[7..0]' zum Modul-Bus.               --
            end if;
            if State_Mod_SM = Rd_LB then
              S_DT_Intern       <= '1';
              S_MB_Macro_Rd_Mux <= (Macro_Activ & Macro_Skal_OK & ST_160_Auxi);  -- LB von 'Rd_Skal2' = 'Macro_Activ', 'Macro_Skal_OK', und              --
            end if;
          end if;
        when others =>
          S_MB_Macro_Rd_Mux <= (others => '0');
          S_DT_Intern       <= '0';
          S_Wr_Status_Reg   <= '0';
      end case;
    end if;
    
  end process P_Adr_Deco_Read_Mux;

  P_MB_Tri_State_Buffer : process (S_MB_Macro_Rd_Mux, S_Adr_Comp_DB, S_DS_Sync, RDnWR)
  begin
    if not (S_Adr_Comp_DB = '1' and S_DS_Sync = '1' and RDnWR = '1') then
      Mod_Data <= (others => 'Z');
    else
      Mod_Data <= S_MB_Macro_Rd_Mux;
    end if;
  end process P_MB_Tri_State_Buffer;

  Powerup_Res <= S_Powerup_Res;

  P_Powerup : process (clk, S_MB_Reset)
  begin
    if S_MB_Reset = '1' then
      S_Powerup_Res_Cnt <= (others => '0');
    elsif clk'event and clk = '1' then
      if S_Wr_Status_Reg_r = '1' and S_Data_Wr_La(2) = '1' then
        S_Powerup_Res_Cnt <= (others => '0');
      elsif S_Powerup_Res_Cnt(S_Powerup_Res_Cnt'high) = '0' then
        S_Powerup_Res_Cnt <= S_Powerup_Res_Cnt + 1;
        S_Powerup_Res     <= '1';
      else
        S_Powerup_Res <= '0';
      end if;
    end if;
  end process;


  TO_with_lpm : if Use_LPM = 1 generate  -----------------------------------------------

  begin
    
    S_Sel_TO_Cnt <= '1' when State_Mod_SM /= Idle else '0';
    S_Set_TO_Cnt <= not S_Sel_TO_Cnt;

    timeout_cnt : lpm_counter
      generic map (
        lpm_width     => S_Timeout_Cnt'length,
        lpm_type      => "LPM_COUNTER",
        lpm_direction => "DOWN",
        lpm_avalue    => integer'image(C_Timeout_Cnt),
        lpm_svalue    => integer'image(C_Timeout_Cnt)
        )
      port map(
        clock  => clk,
        aset   => S_SM_Reset,
        sset   => S_Set_TO_Cnt,
        cnt_en => S_Sel_TO_Cnt,
        q      => S_Timeout_Cnt
        );

  end generate TO_with_lpm;  ----------------------------------------------------------


  TO_without_lpm : if Use_LPM = 0 generate  --------------------------------------------

  begin
    P_Timeout : process (clk, S_SM_Reset)
    begin
      if S_SM_Reset = '1' then
        S_Timeout_Cnt <= conv_std_logic_vector(C_Timeout_Cnt, S_Timeout_Cnt'length);
      elsif clk'event and clk = '1' then
        if State_Mod_SM = Idle then
          S_Timeout_Cnt <= conv_std_logic_vector(C_Timeout_Cnt, S_Timeout_Cnt'length);
        elsif S_Timeout_Cnt(S_Timeout_Cnt'left) = '0' then
          S_Timeout_Cnt <= S_Timeout_Cnt - 1;
        else
          S_Timeout_Cnt <= S_Timeout_Cnt;
        end if;
      end if;
    end process;
    
  end generate TO_without_lpm;  -------------------------------------------------------

  S_Timeout <= S_Timeout_Cnt(S_Timeout_Cnt'left);
  Timeout   <= S_Timeout;

  Data_Wr_La <= S_Data_Wr_La;


  Extern_Wr_Activ <= S_Extern_Wr_Activ(1);
  Extern_Wr_Fin   <= S_Extern_Wr_Fin;


  Extern_Rd_Activ <= S_Extern_Rd_Activ;
  Extern_Rd_Fin   <= S_Extern_Rd_Fin;


  S_Adr_Comp_Live <= '1' when VG_Mod_Adr(4 downto 0) = Mod_Adr(4 downto 0) else '0';

  Adr_Debounce : Debounce
    generic map(
      DB_Cnt     => C_nDS_Deb_cnt,
      DB_Tst_Cnt => 1,
      Use_lpm    => Use_lpm,
      Test       => 0
      )
    port map(
      DB_In  => S_Adr_Comp_Live,
      Reset  => S_Powerup_Res,
      Clk    => clk,
      DB_Out => S_Adr_Comp_DB
      );

  
  S_DS <= not nDS;

  DS_Debounce : Debounce
    generic map(
      DB_Cnt     => C_nDS_Deb_cnt,
      DB_Tst_Cnt => 1,
      Use_lpm    => Use_lpm,
      Test       => 0
      )
    port map(
      DB_In  => S_DS,
      Reset  => S_Powerup_Res,
      Clk    => clk,
      DB_Out => S_DS_Sync
      );

  MB_Reset <= not nMB_Reset;

  Res_Debounce : Debounce
    generic map(
      DB_Cnt     => C_Res_Deb_cnt,
      DB_Tst_Cnt => 1,
      Use_lpm    => Use_lpm,
      Test       => Test
      )
    port map(
      DB_In  => MB_Reset,
      Reset  => '0',
      Clk    => clk,
      DB_Out => S_MB_Reset
      );




  Led_Cnt_with_lpm : if Use_LPM = 1 generate  -----------------------------------------------

  begin
    led_cnt : lpm_counter
      generic map (
        lpm_width     => s_led_cnt'length,
        lpm_type      => "LPM_COUNTER",
        lpm_direction => "DOWN",
        lpm_svalue    => integer'image(C_Ld_Led_cnt)
        )
      port map(
        clock => clk,
        sset  => s_led_cnt(s_led_cnt'high),
        q     => s_led_cnt
        );

  end generate Led_Cnt_with_lpm;  ----------------------------------------------------------


  Led_Cnt_without_lpm : if Use_LPM = 0 generate  --------------------------------------------

  begin
    P_Led_Ena : process (clk, S_Powerup_Res)
    begin
      if S_Powerup_Res = '1' then
        S_Led_Cnt <= conv_std_logic_vector(C_Ld_Led_cnt, s_led_cnt'length);
      elsif clk'event and clk = '1' then
        if S_Led_Cnt(S_Led_Cnt'left) = '1' then
          S_Led_Cnt <= conv_std_logic_vector(C_Ld_Led_cnt, s_led_cnt'length);
        else
          S_Led_Cnt <= S_Led_Cnt - 1;
        end if;
      end if;
    end process P_Led_Ena;
    
  end generate Led_Cnt_without_lpm;  -------------------------------------------------------

  S_Led_Ena <= s_led_cnt(s_led_cnt'high);
  Led_Ena   <= S_Led_Ena;

  Sel_Led : Led
    generic map (
      Use_LPM => Use_LPM
      )
    port map(
      Sig_in => S_Adr_Comp_DB,
      Ena    => S_Led_Ena,
      clk    => clk,
      nLed   => nSel_Led
      );

  DT_Led : Led
    generic map (
      Use_LPM => Use_LPM
      )
    port map(
      Sig_in => S_Start_DT_Led,
      Ena    => S_Led_Ena,
      clk    => clk,
      nLed   => nDT_Led
      );

  nPower_Up_Led <= not S_Status_Reg(0);
  
end Arch_modulbus_v6;
