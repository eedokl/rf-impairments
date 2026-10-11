function [mod_block] = datamod(block,M)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function DATA MODULATION
%
% Function implements the data modulation specified
% in section 17.3.5.7 of 802.11a.
%
% The exact implementation has been taken from the PhD
% Thesis of Heiko Schmidt:
% 'OFDM fuer die drahtlose Datenuebertragung in Gebaeuden'
%
% using equations
% (5.1.3)  for BPSK
% (5.1.5)  for QPSK
% (5.1.9)  for 16-QAM
% (5.1.12) for 64-QAM
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

	K_MOD = 1;
	
	% BPSK modulation (+-1)
	b_0            = reshape(block,log2(M),length(block)/log2(M));
	i_BPSK_symbols = 2 * b_0 - 1;
	
	mod_block      = K_MOD * (i_BPSK_symbols + j * 0);

end
		
%%%%%%%%%%%%%%%%%%% QPSK %%%%%%%%%%%%%%%%%%%%%%%
if M == 4

	K_MOD = 1/sqrt(2);
	
	% QPSK modulation (+-1/+-j)
	bits_matrix     = reshape(block,log2(M),length(block)/log2(M));
	b_0             = bits_matrix(1,:);
	b_1             = bits_matrix(2,:);
	i_QPSK_symbols  = 2 * b_0 - 1;
	q_QPSK_symbols  = 2 * b_1 - 1;

	mod_block       = K_MOD * (i_QPSK_symbols + j * q_QPSK_symbols);

end
		
%%%%%%%%%%%%%%%%%%% 16-QAM %%%%%%%%%%%%%%%%%%%%%%%
if M == 16

	K_MOD = 1/sqrt(10);
	
	% 16-QAM modulation (+-3/+-1/+-3j/+-j)
	bits_matrix     = reshape(block,log2(M),length(block)/log2(M));
	b_0             = bits_matrix(1,:);
	b_1             = bits_matrix(2,:);
	b_2             = bits_matrix(3,:);
	b_3             = bits_matrix(4,:);
	i_16QAM_symbols = (2 * b_0 - 1) .* (3 - 2 * b_1);
	q_16QAM_symbols = (2 * b_2 - 1) .* (3 - 2 * b_3);

	mod_block       = K_MOD * (i_16QAM_symbols + j * q_16QAM_symbols);

end		
		
%%%%%%%%%%%%%%%%%%% 64-QAM %%%%%%%%%%%%%%%%%%%%%%%
if M == 64

	K_MOD = 1/sqrt(42);
	
	% 64-QAM modulation (+-7/+-5/+-3/+-1/+-7j/+-5j/+-3j/+-j)
	bits_matrix     = reshape(block,log2(M),length(block)/log2(M));
	b_0             = bits_matrix(1,:);
	b_1             = bits_matrix(2,:);
	b_2             = bits_matrix(3,:);
	b_3             = bits_matrix(4,:);
	b_4             = bits_matrix(5,:);
	b_5             = bits_matrix(6,:);
	i_64QAM_symbols = (2 * b_0 - 1) .* (4 - (2 * b_1 - 1) .* (3 - 2 * b_2));
	q_64QAM_symbols = (2 * b_3 - 1) .* (4 - (2 * b_4 - 1) .* (3 - 2 * b_5));

	mod_block       = K_MOD * (i_64QAM_symbols + j * q_64QAM_symbols);

end