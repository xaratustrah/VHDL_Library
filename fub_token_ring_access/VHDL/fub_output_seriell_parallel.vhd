LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_output_seriell_parallel is

generic ( 
			bitSize				: integer := 8;
			bitSize_input		: integer := 8;
			adr_bitSize			: integer := 8;
			adr_bitSize_input	: integer := 8			
		) ;
port (  
		------------------------------------------------------
		local_adr			: in std_logic_vector( 7 downto 0 );
		target_adr			: in std_logic_vector( 7 downto 0 );
		------------------------------------------------------
		rst_i						: in std_logic;
		clk_i						: in std_logic;
		data_for_error_detection_i	: in std_logic_vector( bitSize_input + adr_bitSize_input - 1 downto 0);
		data_i						: in std_logic;
		data_clk_i					: in std_logic;
		no_more_data_i				: in std_logic;
		token_deleted_i				: in std_logic;
		ring_str_i					: in std_logic;
		delete_all_o				: out std_logic;
		data_o						: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_o						: out std_logic
	 );
	
end fub_output_seriell_parallel;

architecture fub_output_seriell_parallel_arch of fub_output_seriell_parallel is

type state_type is ( START, ADR_READ, PROOF_ERROR, ADR_PROOF, DATA, DATA_ERROR, DATA_ERROR_PROOF ); 

signal state 		: state_type;

signal count						: integer range 0 to (adr_bitSize + bitSize - 1) :=(bitSize + adr_bitSize - 1);
signal count2						: integer range 0 to (adr_bitSize_input + bitSize_input - 1) :=(bitSize_input + adr_bitSize_input - 1);
signal count_adr					: integer range 0 to 7 :=7;
signal data_intern					: std_logic_vector( adr_bitSize + bitSize - 1 downto 0 );
signal data_intern2					: std_logic_vector( adr_bitSize_input + bitSize_input - 1 downto 0 );
signal adr_intern					: std_logic_vector( 7 downto 0 );
signal error_proof					: std_logic;
signal data_for_error_detection		: std_logic_vector( adr_bitSize_input + bitSize_input - 1 downto 0 );

begin

	fub_output_seriell_parallel_process : process ( rst_i, clk_i )
	begin
		if rst_i = '1' then
			state				<= START;
			count  				<= (bitSize + adr_bitSize - 1);
			count2				<= (bitSize_input + adr_bitSize_input - 1);
			count_adr			<= 7;
			error_proof			<= '0';
			delete_all_o		<= '0';
			data_for_error_detection	<= ( others => '0' );
			data_o 						<= ( others => '0' );
			data_intern					<= ( others => '0' );
			data_intern2				<= ( others => '0' );
			adr_intern					<= ( others => '0' );
			str_o						<= '0';
		elsif clk_i'event and clk_i = '1' then
			data_for_error_detection 	<= data_for_error_detection_i;		-- sync
			str_o						<= '0';				--|| strobe reset
			delete_all_o				<= '0';				--|| delete_all_o reset
			case state is
				when START =>
					if data_clk_i = '1' and data_i = '1' and ring_str_i = '1' then	-- full token has arrived
						state 			<= ADR_READ;
					elsif data_clk_i = '1' and data_i = '1' and token_deleted_i = '1' then 
						state			<= ADR_READ;
						error_proof		<= '1';
					elsif data_clk_i = '1' and data_i = '0' and token_deleted_i = '1' then
						state			<= START;		--	empty token got deleted!
						delete_all_o	<= '1';		--|| delete_all_o set
					else
						state 	<= START;
					end if;
				when ADR_READ =>
					if data_clk_i = '1' then
						adr_intern(count_adr)	<= data_i;
						if count_adr > 0 then 	
							count_adr			<= count_adr - 1;
							state				<= ADR_READ;
						else
							count_adr			<= 7;
							if error_proof = '0' then
								state			<= ADR_PROOF;
							else
								state			<= PROOF_ERROR;
							end if;
						end if;
					end if;
				when PROOF_ERROR =>
					if adr_intern = target_adr then			-- now proof data
						state			<= DATA_ERROR;
					else									-- the wrong package got deleted => ERROR!
						delete_all_o	<= '1';				--|| delete_all_o set
						error_proof		<= '0';
						state			<= START;
					end if;	
				when ADR_PROOF =>
					if adr_intern = local_adr then
						state		<= DATA;					-- token reached target
					else
						state		<= START;					-- not our token
					end if;
				when DATA =>				
					if data_clk_i = '1' and no_more_data_i = '0' then
						if count > 0 then		
							data_intern(count) 	<= data_i ;
							count 				<= count - 1;
							state				<= DATA;
						else							-- the last bit is set into the vector data_o
							str_o				<= '1';				--|| strobe set
							data_intern(count)	<= data_i ;
							data_o 				<= data_intern ;	-- data_o will only change its value if all bits of the vector are set
							data_o(count)		<= data_i ;			-- data_intern will overwrite data_o when it is completly set // if busy_i = '1' this may cause package loss
							count 				<= (bitSize + adr_bitSize - 1);
							state				<= START;
						end if;
					elsif no_more_data_i = '1' then	
						state		<= START;
						count		<= (bitSize + adr_bitSize - 1);
					end if ;
				when DATA_ERROR =>				-- state to check if deleted token was the the one this ap sended
					if data_clk_i = '1' and no_more_data_i = '0' then
						if count2 > 0 then		
							data_intern2(count2)	<= data_i ;
							count2 					<= count2 - 1;
							state					<= DATA_ERROR;
						else
							data_intern2(count2)	<= data_i ;
							count2 					<= (bitSize_input + adr_bitSize_input - 1);
							state					<= DATA_ERROR_PROOF;
						end if;
					elsif no_more_data_i = '1' then	
						state			<= START;
						error_proof		<= '0';
						delete_all_o	<= '1';
						count2			<= (bitSize_input + adr_bitSize_input - 1);
					else
						state			<= DATA_ERROR;
					end if ;
				when DATA_ERROR_PROOF =>
					error_proof		<= '0';
					state			<= START;
					if data_intern2 = data_for_error_detection then
					else
						delete_all_o	<= '1';		--|| delete_all_o set
					end if;
			end case;
		end if;
	end process;
	
end fub_output_seriell_parallel_arch;