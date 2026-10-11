function [      mod_block               ,...
                N_SYMBOLS_PER_PACKET    ]       = ofdmmod(      tx_data_field_data_mod  ,...
                                                                N_FFT                   ,...
                                                                N_GI                    ,...
                                                                N_SD                    )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function OFDM MODULATION
%
% Function implements the complete OFDM modulation
%
% INPUT
% block:	                input block in frequency-domain
%
% N_FFT:                        Parameter
%
% N_GI:                         Parameter
%
% N_SD:                         Parameter
%
% OUTPUT
% mod_block:	                OFDM-modulated output block in time-domain
%
% N_SYMBOLS_PER_PACKET:         Parameter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_SYMBOLS_PER_PACKET    = length(tx_data_field_data_mod) / N_SD;

in_block_tx             = zeros(1,N_FFT);

ll                      = ceil((N_FFT-N_SD+1)/2);

% 'separate' transmit data packet into blocks of N_SD bits
in_block_tx(ll+[1:N_SD])= reshape(      tx_data_field_data_mod  ,...
                                        N_SD                    ,...
                                        N_SYMBOLS_PER_PACKET    );

% transformation into time-domain by means of IFFT
ifft_block              = ifft(fftshift(in_block_tx),N_FFT)*sqrt(N_FFT);
        
% extend by guard interval GI
if N_GI>0
%  gi_block                = [     ifft_block(N_FFT-N_GI+1:N_FFT,:),...
%                                  ifft_block(1:N_FFT,:)];
  gi_block                = [     ifft_block(N_FFT-N_GI+1:N_FFT),...
                                  ifft_block(1:N_FFT)];
else
  gi_block = ifft_block;
end
        
% 'combine' all blocks of N_FFT + N_GI bits to transmit data packet
mod_block               = reshape(      gi_block                                ,...
                                        1                                       ,...
                                        N_SYMBOLS_PER_PACKET * (N_FFT + N_GI)   );
