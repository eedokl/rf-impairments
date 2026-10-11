function out = add_iq_sl (in,iqImbalOn,ampImbal,phsImbal)
% The I/Q Imbalance block creates a complex baseband model of the signal impairments caused by imbalances 
% between in-phase and quadrature receiver components. Typically, these are caused by differences in the 
% physical channels for the two components of the signal.
%
% The I/Q Imbalance block applies amplitude and phase imbalances to the in-phase and quadrature components of the input signal, 
% and then combines the results into a complex signal. The block 
%  - Separates the signal into its in-phase and quadrature components. 
%  - Applies amplitude and phase imbalances, specified by the I/Q amplitude imbalance (dB) and I/Q phase imbalance (deg) parameters, 
%    respectively, to both components.
%  - Combines the in-phase and quadrature components into a complex signal.
%
%
% The value of the I/Q amplitude imbalance parameter is divided between the in-phase and quadrature components:
%  - The block applies a gain of 1+ampImbal to the in-phase component and a gain of 1-ampImbal to the quadrature component.
%
% Parameters:
% ampImbal = I/Q amplitude imbalance
%   - Scalar specifying the I/Q amplitude imbalance.
%
% phsImbal = I/Q phase imbalance (deg)
%   - Scalar specifying the I/Q phase imbalance in degrees.
%
%
if iqImbalOn == 0,
    out = in;
    return;
end
Igain = 1+ampImbal;
Qgain = 1-ampImbal;

% Gain Imbalance can be expressed in dB

Iphase = -0.5*phsImbal*pi/180*2;
Qphase = pi/2+0.5*phsImbal*pi/180*2;

real_gain = real(in) * Igain * exp(j*Iphase);
imag_gain = imag(in) * Qgain * exp(j*Qphase);

out = real_gain + imag_gain;
