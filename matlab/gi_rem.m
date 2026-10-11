function [gi_rem_block] = gi_rem(   block       ,...
                                    WPLACEMENT  ,...
                                    N_FFT       ,...
                                    N_GI        )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function OFDM DEMODULATION
%
% Function implements the guard interval removal as the
% inverse TX operation to guard interval adding.
%
% The function works on a packet basis.
%
% INPUT
% block:	        input block
%
% N_FFT:                Parameter
%
% N_GI:                 Parameter
%
% OUTPUT
% gi_rem__block:	output block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input subblock length
L_in            = length(block)/( N_FFT + N_GI );

% output subblock length
L_out           = L_in * N_FFT;

% 'separate' packet into subblocks of (N_FFT + N_GI) bits
subblock        = reshape(block, N_FFT + N_GI,L_in);

% remove guard interval
% this operation also determines the FFT window placement
% using the WPLACEMENT value
gi_rem_subblock = subblock(N_GI + WPLACEMENT + 1 : N_FFT + N_GI + WPLACEMENT,:);
        
% 'combine' subblocks of N_FFT bits to packet
gi_rem_block    = reshape(gi_rem_subblock,1,L_out);