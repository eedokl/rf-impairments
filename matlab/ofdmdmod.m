function [demod_block] = ofdmdmod(block,N_FFT,N_SD)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function OFDM DEMODULATION
%
% Function implements the complete OFDM demodulation as the
% inverse TX operation to OFDM modulation.
%
% INPUT
% block:	input block in time-domain
%
% OUTPUT
% demod_block:	OFDM-demodulated output block in frequency-domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L_in            = length(block) / N_FFT;
L_out           = L_in * N_SD;

% 'separate' receive data packet into blocks of N_SD bits
in_block_rx     = reshape(block,N_FFT,L_in);
 
% transformation into frequency-domain by means of FFT
fft_block       = fftshift(fft(in_block_rx,N_FFT))/sqrt(N_FFT);

% inverse reordering of DATA field according to advice in standard at page 11/12 and removal of IFFT pad bits
%block_reordered = [	fft_block(39:64,:)
%			fft_block(1:27,:)];

ll              = ceil((N_FFT-N_SD+1)/2);
block_reordered = fft_block(ll+[1:N_SD]);        

        
% combine blocks of N_SD bits to OFDM-demodulated packet
demod_block     = reshape(block_reordered,1,L_out);
