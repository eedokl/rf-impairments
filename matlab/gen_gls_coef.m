function [gls_coef_vector,last_delta] = gen_gls_coef(                      MAX_SAMP_CLOCK_OFFSET_ON        ,...
                                                                L                               ,...
                                                                wp                              ,...
                                                                CARRIER_FREQ_OFFSET_Hz          ,...
                                                                CARRIER_FREQ_Hz                 ,...
                                                                SAMP_CLOCK_Hz                   ,...
                                                                N_TX_PACKET                     ,...
                                                                InitialOffset                   )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function GEN_GLS_COEF
%
% Function implements 
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
% gls_coef_vector:	        Signal
%                               
% Oliver Klein
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<8, InitialOffset=0; end          
% check parameter settings for computation of interpolator coefficients
% freqz(gls_coef(0.5,L,wp),1,1024),subplot(2,1,1),axis([0 1 -0.01 0.01])

% sampling (clock) offset [Hz] due to FO_Hz [Hz]
SO_Hz                           = SAMP_CLOCK_Hz / CARRIER_FREQ_Hz * CARRIER_FREQ_OFFSET_Hz;
                
% sampling (clock) offset delta xi from sample to sample due to FO_Hz [Hz]
% fraction of a sample the sampling point is off from ideal time instant
delta_xi                        = SO_Hz / SAMP_CLOCK_Hz;                


if      MAX_SAMP_CLOCK_OFFSET_ON == 0

        % vector of sampling (clock) offsets containing one offset for each sample in the packet
        % each element specifies the fraction of a sample the sampling point is off from ideal time instant for the corresponding sample
        sampling_shift_vector           = delta_xi * [ 0 : 1 : N_TX_PACKET - 1 ] + InitialOffset;

        % initialize gls_coef_vector
        gls_coef_vector                 = zeros(N_TX_PACKET,L);

        % compute N_TX_PACKET sets of coefficents for the fractional delay interpolator where each set represents a specific 
        for i = 1 : N_TX_PACKET,
                
                % compute coefficients for interpolation filtering
                gls_coef_vector(i,:)    = gls_coef(sampling_shift_vector(i),L,wp).';
                
        end
        last_delta = sampling_shift_vector(end);

elseif  MAX_SAMP_CLOCK_OFFSET_ON == 1

        % sampling (clock) offset for entire packet
        % which specifies the fraction of a sample the sampling point is off from ideal time instant for the corresponding sample
        sampling_shift                  = delta_xi * N_TX_PACKET + InitialOffset

        % compute all N_TX_PACKET set of coefficents for the fractional delay interpolator        
        gls_coef_vector                 = repmat(gls_coef(sampling_shift,L,wp).',N_TX_PACKET,1);
        %gls_coef_vector                 = repmat(sinc(-64 + sampling_shift : 1 : 64 + sampling_shift),N_TX_PACKET,1);

        last_delta = sampling_shift;
        
end        










