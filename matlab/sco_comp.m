function [      socomp_block    ,...
                phase_shifts    ]       = sco_comp(             in_block                        ,...
                                                                SO_COMP_ON                      ,...
                                                                IDEAL_SO_COMP                   ,...
                                                                MAX_SAMP_CLOCK_OFFSET_ON        ,...
                                                                CARRIER_FREQ_OFFSET_Hz          ,...
                                                                EST_CARRIER_FREQ_OFFSET_Hz      ,...
                                                                CARRIER_FREQ_Hz                 ,...
                                                                SAMP_CLOCK_Hz                   ,...
                                                                N_SYMBOLS_PER_PACKET            ,...
                                                                N_SD                            )
                                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function SAMPLING OFFSET COMPENSATION
%
% Function implements the sampling offset compensation.
%
% The frequency offset is compensated as an increasing (accumulated)
% phase difference from one sample to the next. Ideally, the phase
% difference applied is conjugate complex to the one introduced as
% frequency offset in the function 'add_fo'.
%
% Please note that the channel estimation algorithm runs on frequency offset compensated long preamble symbols.
% Therefore,the timing instant of channel estimation (or phase estimation in this context) which is exactly in
% between the two long preamble symbols has to be taken into account as the start of frequency offset compensation.
%
% The function is switched off (transparent) by SO_COMP_ON = 0.
%
% The function is configurable to use ideal (CARRIER_FREQ_OFFSET_Hz) or 
% estimated frequency offset (EST_CARRIER_FREQ_OFFSET_Hz) for compensation
% (IDEAL_SO_COMP).
%
% Implemented algorithm
% ---------------------
% 1. 
% 2. 
% 3. 
%
% The function works on a packet basis, i.e., is called once per packet.
%
% %%% INPUT %%%
% in_block:                     Signal
%                               input block potentially distorted by sampling clock offset
%
% SO_COMP_ON:                   Parameter
%                               sampling clock offset compensation on/off
%                               0 - no compensation (function is transparent)
%                               1 - sampling clock offset compensation
%
% IDEAL_SO_COMP:                Parameter
%                               0 - compensate sampling clock offset using EST_CARRIER_FREQ_OFFSET_Hz
%                               1 - compensate sampling clock offset using CARRIER_FREQ_OFFSET_Hz
%
% MAX_SAMP_CLOCK_OFFSET_ON:     Parameter
%                               0 - assume constant sampling clock offset (to be derived from worst case 
%                                   CARRIER_FREQ_OFFSET_Hz/EST_CARRIER_FREQ_OFFSET_Hz)
%                               1 - assume constant sampling clock offset (to be derived from worst case 
%                                   CARRIER_FREQ_OFFSET_Hz/EST_CARRIER_FREQ_OFFSET_Hz)
%
% CARRIER_FREQ_OFFSET_Hz:       Parameter
%                               actual (introduced) frequency offset [Hz]
%
% EST_CARRIER_FREQ_OFFSET_Hz:   Parameter
%                               estimated frequency offset [Hz]
%
% N_SYMBOLS_PER_PACKET:         Parameter
%
%
% %%% OUTPUT %%%
% socomp_block:                 Signal
%                               sampling clock offset compensated block
%
% phase_shifts:                 Signal
%                               packet-length vector of sample-spaced phase differences [rad]
%                               dim: (48 x N_SYMBOLS_PER_PACKET)
%
% Oliver Klein
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nc   = length(in_block);
NFFT = 2^nextpow2(Nc);


if      SO_COMP_ON == 0

        % no compensation (transparent functionality)
        socomp_block            = in_block;
        phase_shifts            = zeros(Nc,N_SYMBOLS_PER_PACKET);
    
elseif  SO_COMP_ON == 1

        % choose between compensation with actual or estimated frequency offset depending on parameter IDEAL_SO_COMP
        if      IDEAL_SO_COMP == 1

                % use actual (introduced) frequency offset for compensation
        	    FO_Hz           = CARRIER_FREQ_OFFSET_Hz;

        elseif  IDEAL_SO_COMP == 0

                % use estimated fine frequency offset for compensation
                FO_Hz           = EST_CARRIER_FREQ_OFFSET_Hz;

        end
        
        % sampling (clock) offset [Hz] due to FO_Hz [Hz]
        SO_Hz                   = SAMP_CLOCK_Hz / CARRIER_FREQ_Hz * FO_Hz;
                
        % sampling (clock) offset delta xi from sample to sample due to FO_Hz [Hz]
        delta_xi                = SO_Hz / SAMP_CLOCK_Hz;                
                
        % subcarriers indizes w pilots and DC
        m                       = [-(Nc-1)/2 : -1, 0, 1 : (Nc-1)/2];
        
        % choose between compensation of constant or variable sampling clock offset depending on parameter MAX_SAMP_CLOCK_OFFSET_ON
        if MAX_SAMP_CLOCK_OFFSET_ON == 1

                % maximum sampling (clock) offset delta xi for entire packet
                max_delta_xi    = delta_xi * length(in_block);
            
                % N_SD-length vector of phase rotation values per subcarrier [rad]
                phi_subcarrier  = max_delta_xi * m / (NFFT/2) * pi * 2 * Nc/NFFT;

                % N_SD-length vector of phase differences [rad] targeted for phase compensation
                phase_shifts    = repmat(1 * exp ( - j * phi_subcarrier ),N_SYMBOLS_PER_PACKET,1).';
                
        elseif MAX_SAMP_CLOCK_OFFSET_ON == 0
            
                % variable (increasing) sampling (clock) offsets delta xi for entire packet
                var_delta_xi    = delta_xi * [0 : N_SD * N_SYMBOLS_PER_PACKET - 1];
                
                % compute average variable sampling (clock) offset per OFDM symbol
                tmp             = reshape(var_delta_xi,N_SD,N_SYMBOLS_PER_PACKET);
                avg_var_delta_xi= mean(tmp);
                                
                % N_SD-length vector of phase rotation values per subcarrier [rad]
                % Note: the divisor should actually be 31.5 but 31 works definitely better
                warning('Equation optimized for WLAN - needs update for LTE');
                phi_subcarrier  = (m / (NFFT/2-1) * pi * 2 * NFFT/80)' * avg_var_delta_xi;
                
                % N_SD-length vector of phase differences [rad] targeted for phase compensation
                phase_shifts    = exp ( - j .* phi_subcarrier );
            
        end            
        
        % 'separate' in_block into blocks of N_SD bits
        in_block_sep            = reshape(in_block,Nc,N_SYMBOLS_PER_PACKET);
        
        %[in_block_sep(:,1) in_block(1:Nc).']
        %pause
        
        % initialize
        socomp_block_sep        = zeros(Nc,N_SYMBOLS_PER_PACKET);
        
        for x = 1 : N_SYMBOLS_PER_PACKET,            
            
                % compensation of subcarriers
                socomp_block_sep(:,x) = in_block_sep(:,x) .* phase_shifts(:,x);
                       
        end                
        
        % combine blocks of N_SD bits to so_block
        socomp_block            = reshape(socomp_block_sep,1,length(in_block));
        
end



