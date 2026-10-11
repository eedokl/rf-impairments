function waveform = add_iq_imbalance_fw(waveform,onoff,IQ_alpha,IQ_theta);
% The I/Q Imbalance block creates a complex baseband model of the signal impairments caused by imbalances 
% between in-phase and quadrature receiver components. Typically, these are caused by differences in the 
% physical channels for the two components of the signal.
%
% The I/Q Imbalance block applies amplitude and phase imbalances to the in-phase and quadrature components of the input signal.
%
% Parameters:
% ampImbal = I/Q amplitude imbalance
%   - Scalar specifying the I/Q amplitude imbalance.
%
% phsImbal = I/Q phase imbalance (deg)
%   - Scalar specifying the I/Q phase imbalance in degrees.
%
% Reference:
%   (1) Fredrik's Report referencing to Fettweis, Dirty RF
if nargin < 4, IQ_theta = 0.013; end
if nargin < 3, IQ_alpha = 0.3; end

phi = IQ_theta/180*pi;
g = IQ_alpha;

K1 = (1 + g * exp(-j*phi))/2;

K2 = (1 - g * exp( j*phi))/2;


waveform = K1*waveform + K2*conj(waveform);



