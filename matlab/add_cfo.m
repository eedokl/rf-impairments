function [ fo_block, last_phase ] = add_cfo         ( in_block                ,...
                                                    FREQUENCY_OFFSET_ON     ,...
                                                    N_TX_PACKET             ,...
                                                    FO_Hz                   ,...
                                                    SAMP_RATE               ,...
                                                    start_phase)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function (CARRIER) FREQUENCY OFFSET
%
% The frequency offset is introduced as an increasing (accumulated)
% phase difference from one sample to the next.
%
% Implemented procedure
% ---------------------
% 1. derive phase difference per sample from desired frequency offset (return value)
% 2. create packet-length vector of sample-spaced phase differences
% 3. rotate input block sample-wise using sample-spaced phase differences yielding output block (return value)
%
% Phase difference unit is radiant.
%
% The function works on a packet basis, i.e., is called
% once per packet.
%
% %%% INPUT %%%
% in_block:	            Signal
%                       input block
%
% FREQUENCY_OFFSET_ON:  Parameter
%                       0 - transparent function
%                       1 - function introduces frequency offset
%
% N_TX_PACKET:          Parameter
%                       length of input block
%
% FO_Hz:                Parameter
%                       carrier frequency offset (Hz)
%
% SAMP_RATE:            Parameter
%                       sampling rate (20MHz)
%
% %%% OUTPUT %%%
% fo_block:	            Signal
%                       output block = input block * carrier frequency offset
%
% delta_phi_sample_rad: Parameter
%                       carrier frequency offset introduced as the phase
%                       from one sample to the next [rad]
%
% Oliver Klein
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<6, start_phase = 0; end

if      FREQUENCY_OFFSET_ON == 0

        % no introduction of frequency offset
        fo_block                = in_block;
        delta_phi_sample_rad    = 0;
        last_phase              = 0;
    
elseif  FREQUENCY_OFFSET_ON == 1

        % phase difference from sample to sample due to FO_Hz [rad]
        delta_phi_sample_rad    = 2 * pi / SAMP_RATE * FO_Hz;

        % packet-length vector of sample-spaced phase differences [rad]
        phase_shifts            = exp ( j * (delta_phi_sample_rad * [0:N_TX_PACKET-1] + start_phase));
        
        % rotate input block sample-wise using sample-spaced phase differences
        fo_block                = in_block .* phase_shifts;
        
        last_phase              = rem(delta_phi_sample_rad * N_TX_PACKET + start_phase,2*pi);
        
end
