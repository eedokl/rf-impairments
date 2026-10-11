function [rx_data_field_so_comp,last_delay,PHASE_OFFSET] = samp_clock_offset_simulation_function(last_delay,M,SCO,t_offset,CFO,PHASE_OFFSET,OFDM_ON,PN_LEVEL,PN_FO,ampImbal,phsImbal,DC_I,DC_Q)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose:	Simulation of uncoded BPSK, QPSK, 16-QAM and 64-QAM
%		+ OFDM over AWGN + Hard/Soft decision
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear;
if nargin<1, last_delay = 0; end
if nargin<2, M = 4; end
if nargin<3, SCO = 0; end
if nargin<4, toffset = 0; end
if nargin<5, CFO = 0; end
if nargin<6, PHASE_OFFSET = 0; end
if nargin<7, OFDM_ON = 1; end
if nargin<8, PN_LEVEL = -120; end
if nargin<9, PN_FO = 100; end
if nargin<10, ampImbal = 0; end
if nargin<11, phsImbal = 10; end
if nargin<12, DC_I = 0; end
if nargin<13, DC_Q = 0; end
SNR_dB		            = [     2
                                        2.5
                                        2.75
                                        3
                                        3.25
                                        3.5
                                        3.75
                                        4       ];
NUM_PACKETS             = [     500
                                        1000
                                        1000
                                        1000
                                        1000
                                        1500
                                        2000
                                        3000    ]/10;

%SNR_dB = [2:1:10]';                                    
%NUM_PACKETS = ones(size(SNR_dB))*50;

% Overrule SNR_dB and NUM_PACKETS settings
SNR_dB		                    = 1000;%-0.3;
NUM_PACKETS                     = 1;

SC_Hz                           = 30.72e6;
CF_Hz                           = 2.5e9;

SCO_ON                          = 1;
MAX_SCO_ON                      = 0;

CFO_ON                          = 1;
CFO_Hz                          = CFO/1e6*CF_Hz;
CFO_EST_C_ON                    = 0;
CFO_EST_F_ON                    = 0;
CFO_COMP_C_ON                   = 0;

SCO_COMP_ON                     = 0;
IDEAL_SCO_COMP                  = 1;

PHASE_NOISE_ON                  = 1;

% some constant
N_FFT                           = 128;%2048;
N_GI                            = 9;%512;
N_SYM                           = N_FFT + N_GI;
N_SD                            = 72;%1201;
N_ST                            = 72;%1201;

% packet definition (N corresponds to length in samples)
N_PSDU	                        = 72;%1201;

if (OFDM_ON)
N_SIGNAL                        = N_GI + N_FFT;
N_DATA                          = N_GI + N_FFT;

N_TX_PACKET                     = N_GI + N_FFT;
else
N_SIGNAL                        = N_SD;
N_DATA                          = N_SD;

N_TX_PACKET                     = N_SD;
end

WPLACEMENT_TIME                 = 0;
WPLACEMENT_FREQ                 = 0;
WP_COMP_ON                      = 0;

%%%%%%%%%%%%%%%%%%% Loading Section %%%%%%%%%%%%%%%%%%%%%%%
% computation of fractional delay filter coefficients based on CARRIER_FREQ_OFFSET_Hz
% assuming 32 coefficients and BPSK, it takes about 80 seconds to finish computing
if 1
    L                       = 32;
    wp                      = 0.87;
    CFO_Hz1                 = SCO/1e6*CF_Hz;
    DelayOffset             = t_offset;
    %MAX_SCO_ON = 1;
    [gls_coef_vector,last_delay] = gen_gls_coef( MAX_SCO_ON                 ,...
                                            L                               ,...
                                            wp                              ,...
                                            CFO_Hz1                         ,...
                                            CF_Hz                           ,...
                                            SC_Hz                           ,...
                                            N_TX_PACKET                     ,...
                                            DelayOffset);
    %disp('Coefficient Computation READY !!!');
    %MAX_SCO_ON = 0;
    %save gls_coef_15ppm.txt gls_coef_vector -ASCII
end

% initialization of arrays
CFO_EST_HZ              = zeros(max(NUM_PACKETS),length(SNR_dB));


for x = 1 : length(SNR_dB), %%%%%%%%%% Loop for SNR %%%%%%%
for y = 1 : NUM_PACKETS(x), %%%%%%% Loop for Packets %%%%%%
    
	    % disp('current packet number')
	    %disp(y);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  T R A N S M I T T E R
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

	    %%%%%%%%%%%%%%%%%%% Data Modulation %%%%%%%%%%%%%%%
   	    tx_bits = 0*( randn(1,N_PSDU*log2(M)) > 0 ); %okl

        tx_data_field_data_mod          = datamod(tx_bits,M);
        
	    %%%%%%%%%%%%%% OFDM Modulation %%%%%%%%%%%%%%%%%%%%
        if (OFDM_ON)
        [tx_data_field_ofdm_mod ,...
         N_SYMBOLS_PER_PACKET   ]       = ofdmmod(      tx_data_field_data_mod  ,...
                                                        N_FFT                   ,...
                                                        N_GI                    ,...
                                                        N_SD                    );
        else
          tx_data_field_ofdm_mod = tx_data_field_data_mod;
          N_SYMBOLS_PER_PACKET   = length(tx_data_field_data_mod);
        end
	    %%%%%%%%%%%%% Simulation Packet Building %%%%%%%%%%
	    tx_packet                       = tx_data_field_ofdm_mod;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   I Q   I M B A L A N C E   I N T R O D U C T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        tx_packet_iq                    = add_iq_imbalance_ld(tx_packet                 ,...
                                                           1                            ,...
                                                           ampImbal                     ,...
                                                           phsImbal                     );

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   D C   O F F S E T   I N T R O D U C T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        tx_packet_dc                    = add_dc_offset   (tx_packet_iq                 ,...
                                                           1                            ,...
                                                           DC_I                         ,...
                                                           DC_Q                         );


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   C A R R I E R   F R E Q U E N C Y   O F F S E T   I N T R O D U C T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        [tx_packet_cfo,PHASE_OFFSET]    = add_cfo(      tx_packet_dc                    ,...
                                                        CFO_ON                          ,...
                                                        N_TX_PACKET                     ,...
                                                        CFO_Hz                          ,...
                                                        SC_Hz                           ,...
                                                        PHASE_OFFSET);
        
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  S A M P L I N G   C L O C K   O F F S E T   I N T R O D U C T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tx_packet_sco                   = add_sco_interpolate(      tx_packet_cfo                   ,...
                                                        gls_coef_vector                 ,...
                                                        SCO_ON                          ,...
                                                        MAX_SCO_ON                      ,...
                                                        CFO_Hz                          ,...
                                                        CF_Hz                           ,...
                                                        SC_Hz                           ,...
                                                        N_TX_PACKET                     );
        
                                                    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  P H A S E   N O I S E   I N T R O D U C T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tx_packet_sco                   = add_phase_noise(tx_packet_sco                ,...
                                                          PHASE_NOISE_ON               ,...
                                                          PN_LEVEL                     ,...
                                                          PN_FO                        );
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  A W G N   I N T R O D U C T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % linear SNR
        SNR                             = 10^( SNR_dB(x) / 10 );
        % generation of noise samples
        randn('state',sum(100*clock));
        noise_amplitude                 = 1/sqrt(2*SNR);
        awgn_inphase                    = noise_amplitude * randn(1,N_TX_PACKET );
        randn('state',sum(100*clock));
        awgn_quadrature                 = noise_amplitude * randn(1,N_TX_PACKET );
        awgn                            = awgn_inphase + j * awgn_quadrature;
        
        % addition of noise samples
        rx_packet_awgn                  = tx_packet_sco + awgn;

        % check SNR
        %Channel_SNR(y)                  = 10*log10( mean(tx_packet(1:end).*conj(tx_packet(1:end))) / var(noise(1:end)) );
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  I N N E R   R E C E I V E R
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%% Coarse Carrier Frequency Offset Estimation %%%%
        rx_data_field_signal_rem        = rx_packet_awgn;
                                                    
        %%%%%%% Remove GI incl. FFT Window Placement %%%%%%
        if (OFDM_ON)
          rx_data_field                   = gi_rem(     rx_data_field_signal_rem                ,...
                                                        WPLACEMENT_TIME                         ,...
                                                        N_FFT                                   ,...
                                                        N_GI                                    );
	    %%%%%%%%%%%%%% OFDM Demodulation %%%%%%%%%%%%%%%%%%
          rx_data_field_ofdm_demod        = ofdmdmod(   rx_data_field                           ,...
                                                        N_FFT                                   ,...
                                                        N_SD                                    );
                                                    
        %%%%%%% Compensate for FFT Window Placement %%%%%%%
          [rx_data_field_wp_comp  ,...
           wp_phase_shifts        ]       = wp_comp(    rx_data_field_ofdm_demod                ,...
                                                        WP_COMP_ON                              ,...
                                                        WPLACEMENT_FREQ                         ,...
                                                        N_SYMBOLS_PER_PACKET                    ,...
                                                        N_SD                                    );                                                                                                
        else % single carrier
            rx_data_field_wp_comp         = rx_data_field_signal_rem;
        end
                                                    
        %%%%%%%%%%%%%% SCO Compensation %%%%%%%%%%%%%%%%%%
        [rx_data_field_so_comp  ,...
         so_phase_shifts        ]       = sco_comp(     rx_data_field_wp_comp                   ,...
                                                        SCO_COMP_ON                             ,...
                                                        IDEAL_SCO_COMP                          ,...
                                                        MAX_SCO_ON                              ,...
                                                        CFO_Hz                                  ,...
                                                        CFO_EST_HZ(y,x)                         ,...
                                                        CF_Hz                                   ,...
                                                        SC_Hz                                   ,...
                                                        N_SYMBOLS_PER_PACKET                    ,...
                                                        N_SD                                    );
        
        %%%%%%%%%%%%%% Channel Estimation %%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%% Channel Equalization %%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%% Data Demodulation %%%%%%%%%%%%%%%%%%
        rx_data_field_data_demod        = datadmod(     rx_data_field_so_comp                   ,...
                                                        M                                       );
        rx_bits                         = rx_data_field_data_demod.' > 0;                                                            
                                                    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  P E R F O R M A N C E   E V A L U A T I O N
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % count number of errors for current packet
	    num_err_cod(y)                  = sum(rx_bits ~= tx_bits);
	    % compute and store coded BER for current packet
	    curr_codber(y)                  = num_err_cod(y) / (log2(M)*N_PSDU);
	    % disp('coded BER for current packet');
        % disp(curr_codber(y));
        % pseudo CRC check (any error yields CRC check error)
	    if num_err_cod(y) == 0
                crc(y) = 0; % CRC passed
	    else
                crc(y) = 1; % CRC failed
	    end
    
end %%%%%%%%%%%%%%% End of Packets Loop %%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% BER/PER (entire simulation) %%%%%%%%%%%
% compute and store coded BER for entire simulation
final_codber(x) = mean(curr_codber);
% compute and store coded PER for entire simulation        
per(x) = sum(crc) / NUM_PACKETS(x);

end %%%%%%%%%%%%%%% End of SNRs Loop %%%%%%%%%%%%%%%%%%%%%%

RESULT(:,:,1)           = [     SNR_dB'
                                NUM_PACKETS'
                                final_codber
                                per             ];
%disp(RESULT(:,:,z));
%SNR = EsN0 = log2(M)*EbN0;
if 0
figure(1)
SNR = 10.^(SNR_dB/10);
EbN0 = SNR/log2(M);
Pb = Qfunc(sqrt(2*EbN0));
figure(1);
semilogy(SNR_dB,Pb,'b-',SNR_dB,final_codber,'o:'); grid on;
disp(RESULT);
end
if 0
figure(2)
plot(tx_data_field_data_mod,'or'); 
hold on;
%for i=1:1201, plot(rx_data_field_so_comp(i),'x'); axis([-1 1 -1 1]); title(sprintf('%d',i-600)), pause(.001),end;
plot(rx_data_field_so_comp,'x'); axis([-1 1 -1 1]);
hold off;
end
