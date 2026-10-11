function waveform = add_iq_imbalance_ld(waveform,onoff,IQ_alpha,IQ_theta);
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
%   (1) A UE perspective on the Mathematics and Down-Link Algorithms behind LTE
if nargin < 4, IQ_theta = 0.013; end
if nargin < 3, IQ_alpha = 0.3; end

%IQ_theta = -IQ_theta/180/2;
%a=cos(2*pi*(1-IQ_theta)) + i*IQ_alpha*sin(2*pi*(1-IQ_theta));
%b=IQ_alpha*cos(2*pi*(1-IQ_theta)) - i*sin(2*pi*(1-IQ_theta));

% or equivalently:
IQ_theta = IQ_theta/180*pi;

a =          cos(IQ_theta) + i*IQ_alpha*sin(IQ_theta);

b = IQ_alpha*cos(IQ_theta) - i         *sin(IQ_theta);


waveform = a*waveform + b*conj(waveform);



