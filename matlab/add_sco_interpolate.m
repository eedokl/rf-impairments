function [ so_block ] =     add_sco(                            in_block                        ,...
                                                                gls_coef_vector                 ,...
                                                                SAMP_CLOCK_OFFSET_ON            ,...
                                                                MAX_SAMP_CLOCK_OFFSET_ON        ,...
                                                                CARRIER_FREQ_OFFSET_Hz          ,...
                                                                CARRIER_FREQ_Hz                 ,...
                                                                SAMP_CLOCK_Hz                   ,...
                                                                N_TX_PACKET                     )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function SAMPLING OFFSET
%
% The sampling offset is introduced as an ...
% ... difference from one sample to the next.
%
% Implemented procedure
% ---------------------
% 1. 
% 2. 
% 3. 
%
% The function works on a packet basis, i.e., is called
% once per packet.
%
% %%% INPUT %%%
% in_block:	                    Signal
%                               input block
%                               dim: 1 x N_TX_PACKET
%
% gls_coef_vector:              Signal
%                               dim: N_TX_PACKET x 8
%
% SAMP_CLOCK_OFFSET_ON:         Parameter
%                               0 - transparent function
%                               1 - function introduces sampling clock offset
%
% MAX_SAMP_CLOCK_OFFSET_ON:     Parameter
%                               0 - 
%                               1 - 
%
% CARRIER_FREQ_OFFSET_Hz:       Parameter
%                               carrier frequency offset (Hz)
%
% CARRIER_FREQ_Hz:              Parameter
%                               carrier frequency (Hz)
%
% SAMP_CLOCK_Hz:                Parameter
%                               sampling clock frequency (Hz)
%
% N_TX_PACKET:                  Parameter
%                               length of input block
%
% %%% OUTPUT %%%
% td_block:	                    Signal
%                               output block = input block convolved with gls_coef_vector
%                               dim: 1 x N_TX_PACKET
%
% Oliver Klein
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if      SAMP_CLOCK_OFFSET_ON == 0

        % no introduction of timing drift
        so_block                        = in_block;
    
elseif  SAMP_CLOCK_OFFSET_ON == 1

        % determine length L of fractional delay filter
        [dummy,L]                       = size(gls_coef_vector);
    
        % initialize output block
        so_block_tmp                    = zeros(N_TX_PACKET + (L - 1),1);
        
        if      MAX_SAMP_CLOCK_OFFSET_ON == 0

                state = zeros(1,31);
                so_filt_tmp = zeros(1,N_TX_PACKET+L-1);
                for i = 1 : N_TX_PACKET
                    [so_filt_tmp(i),state] = filter(gls_coef_vector(i,:),1,in_block(i),state);
                end
                % post processing for block mode
                for i = N_TX_PACKET+1 : N_TX_PACKET + (L - 1)
                    [so_filt_tmp(i),state] = filter(gls_coef_vector(N_TX_PACKET,:),1,0,state);
                end
                % remove transition samples
                so_block                   = so_filt_tmp(L/2 + 1 : end - (L/2 - 1));
                
        elseif  MAX_SAMP_CLOCK_OFFSET_ON == 1
                
                % parameter settings for computation of interpolator coefficients
                % freqz(gls_coef(0.5,32,0.87),1,1024),subplot(2,1,1),axis([0 1 -0.01 0.01])
                L                       = 32;
                wp                      = 0.87;
            
                % sampling (clock) offset [Hz] due to FO_Hz [Hz]
                SO_Hz                   = SAMP_CLOCK_Hz / CARRIER_FREQ_Hz * CARRIER_FREQ_OFFSET_Hz;
                
                % sampling (clock) offset delta xi from sample to sample due to FO_Hz [Hz]
                delta_xi                = SO_Hz / SAMP_CLOCK_Hz;                
                
                % sampling (clock) offset per packet
                sampling_shift          = delta_xi * N_TX_PACKET;
                
                % compute coefficients for interpolation filtering
                sampling_shift_coef     = gls_coef(sampling_shift,L,wp);
                
                % apply sampling shift by means of interpolation filtering
                so_block_tmp            = conv(sampling_shift_coef,in_block);
                
                % remove transition samples
                so_block                = so_block_tmp(L/2 + 1 : end - (L/2 - 1));
            
        end
   
end
