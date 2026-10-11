function [out_block] =      datadmod(       in_block                ,...
                                            M                       )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function DATA DEMODULATION
%
% Function implements the data demodulation as reverse
% to the data modulation operation as specified
% in section 17.3.5.7 of 802.11a.
%
% The exact implementation has been taken from the PhD
% Thesis of Heiko Schmidt:
% 'OFDM fuer die drahtlose Datenuebertragung in Gebaeuden'
%
% using equations
% (5.1.4)  for BPSK
% (5.1.6)  for QPSK
% (5.1.10)  for 16-QAM
% (5.1.13) for 64-QAM
%
% INPUT
% block:	input block
% M:		2  - BPSK
%		4  - QPSK
%		16 - 16-QAM
%		64 - 64-QAM
%
% OUTPUT
% mod_block:	modulated output block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% BPSK %%%%%%%%%%%%%%%%%%%%%%%
if M == 2			                
 	%K_MOD = 1;
                % demapping of symbol to bit 0
		b_0                     = real(in_block);
                
		out_block               = reshape([b_0]',log2(M) * length(in_block),1);
end

%%%%%%%%%%%%%%%%%%% QPSK %%%%%%%%%%%%%%%%%%%%%%%
if M == 4
	%K_MOD = 1/sqrt(2);
                % demapping of symbol to bits 0 ... 1
		b_0                     = real(in_block);
		b_1                     = imag(in_block);
                
		out_block               = reshape([b_0',b_1']',log2(M) * length(in_block),1);
end

%%%%%%%%%%%%%%%%%%% 16-QAM %%%%%%%%%%%%%%%%%%%%%%%
if M == 16
	K_MOD = 1/sqrt(10);
		% demapping of symbol to bits 0 ... 3
		b_0                     = real(in_block);
		b_1                     = 2 * K_MOD - abs(b_0);
		b_2                     = imag(in_block);		
		b_3                     = 2 * K_MOD - abs(b_2);
                
		out_block               = reshape([b_0',b_1',b_2',b_3']',log2(M) * length(in_block),1);
end

%%%%%%%%%%%%%%%%%%% 64-QAM %%%%%%%%%%%%%%%%%%%%%%%
if M == 64
	K_MOD = 1/sqrt(42);
		% demapping of symbol to bits 0 ... 5
		b_0                     = real(in_block);
		b_1                     = 4 * K_MOD - abs(b_0);
		b_2                     = 2 * K_MOD - abs(b_1);
		b_3                     = imag(in_block);		
		b_4                     = 4 * K_MOD - abs(b_3);
		b_5                     = 2 * K_MOD - abs(b_4);

		out_block               = reshape([b_0',b_1',b_2',b_3',b_4',b_5']',log2(M) * length(in_block),1);
end