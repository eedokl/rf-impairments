function out = add_phase_noise(in,PhNsOn,PhNs,Fo)

% The Phase Noise block appies phase noise to a complex, baseband signal. The block applies the phase noise as follows:
%   - Generates additive white Gaussian noise (AWGN) and filters it with a digital filter.
%   - Adds the resulting noise to the angle component of the input signal.
%
% Complex baseband model of receiver phase noise.
%
% The output of this block is noise with a spectrum characterized by a 1/f slope.  
% The level of the spectrum is specified by the noise power contained in a one hertz 
% bandwidth offset from the carrier by a certain frequency.  
%
% Parameters:
% Phase noise level (dBc/Hz)
%   - Scalar specifying the phase noise level.
% Frequency offset (Hz)
%   - Scalar specifying the frequency offset in Hertz.
% Initial seed
%   - Nonnegative integer specifying the initial seed for the random number
%     generator the block uses to generate noise
%
% [1] Kasdin, N.J., "Discrete Simulation of Colored Noise and Stochastic Processes and 1/(f^alpha); 
%     Power Law Noise Generation," The Proceedings of the IEEE, May, 1995, Vol. 83, No. 5
if PhNsOn == 0,
    out = in;
    return;
end
if PhNs>0,
	error('Phase noise level should be negative.');
end
num = sqrt(2*pi*Fo*10^((PhNs)/10));
if num>.1,
	warning('Current parameters in phase noise block may produce inaccurate results.');
end
num_taps = 64;
den = zeros(1,num_taps);
den(1) = 1;
for idx = 2:num_taps
   den(idx) = (idx - 2.5) * den(idx-1) / (idx-1);
end


% generate noise
%variance = 1; % tbc?!?
noise = randn(size(in));

%generate filter with num, den from above
filtered_noise = filter(num, den, noise);

%random phase
phase_noise = exp(j*filtered_noise);

out = in .* phase_noise;
