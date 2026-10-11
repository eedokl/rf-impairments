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

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % init phase of correlation
                
                
                for i = 1 : (L - 1),
                    
                        tmp                     = 0;
                        
                        for j = 1 : i,
                            
                                tmp             = tmp + gls_coef_vector( j , i - ( j - 1 ) ) * in_block( j );
                                
                        end
                        
                        so_block_tmp(i)         = tmp;
                        
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % regular phase of correlation: loop for each sample of the packet

                for i = L : N_TX_PACKET,

                        tmp                     = 0;
                        
                        for j = 1 : L,
                            
                                tmp             = tmp + gls_coef_vector( i - ( L - j ), L - ( j - 1 ) ) * in_block( i - ( L - j ) );
                                
                        end
                        
                        so_block_tmp(i)         = tmp;                        
                    
                end                    

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % post phase of correlation

                
                for k = N_TX_PACKET + 1 : N_TX_PACKET + (L - 1),

                        tmp                     = 0;
                        index                   = L;
                        
                        for j = k - (N_TX_PACKET + (L - 1)) : 0,
                                
                                tmp             = tmp + gls_coef_vector( N_TX_PACKET + j, index ) * in_block( N_TX_PACKET + j );
                                
                                index           = index - 1;
                        end
                        
                        so_block_tmp(k)         = tmp;                        
                    
                end                                                        
                
                % remove transition samples
                so_block                = so_block_tmp(L/2 + 1 : end - (L/2 - 1)).';
            
        elseif  MAX_SAMP_CLOCK_OFFSET_ON == 1
                
                % parameter settings for computation of interpolator coefficients
                % freqz(gls_coef(0.5,32,0.87),1,1024),subplot(2,1,1),axis([0 1 -0.01 0.01])
                L                       = 32;
                %L                       = 8;
                wp                      = 0.87;
                %wp                      = 0.5;
            
                % sampling (clock) offset [Hz] due to FO_Hz [Hz]
                SO_Hz                   = SAMP_CLOCK_Hz / CARRIER_FREQ_Hz * CARRIER_FREQ_OFFSET_Hz;
                
                % sampling (clock) offset delta xi from sample to sample due to FO_Hz [Hz]
                delta_xi                = SO_Hz / SAMP_CLOCK_Hz;                
                
                % sampling (clock) offset per packet
                sampling_shift          = delta_xi * N_TX_PACKET;
                
                % compute coefficients for interpolation filtering
                sampling_shift_coef     = gls_coef(sampling_shift,L,wp);
                %sampling_shift_coef     = sinc( -64 + sampling_shift : +64 + sampling_shift );
                
                % apply sampling shift by means of interpolation filtering
                so_block_tmp            = conv(sampling_shift_coef,in_block);
                
                % remove transition samples
                so_block                = so_block_tmp(L/2 + 1 : end - (L/2 - 1));
                %so_block                = so_block_tmp(65:end-64);
            
        end
   
end
