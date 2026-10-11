function out = add_dc_offset(samples,DCO_ON,offset_I,offset_Q)
% blabla
if nargin < 4, offset_Q = 0; end
if nargin < 3, offset_I = 0; end

% specify level of amplitude imbalance
%SOR_dB
if      DCO_ON == 0
        % transparent functionality
        out                                                             = samples;

elseif  DCO_ON == 1
        % transform DC offset [dB] to linear domain
        
        %SOR_lin                                                         = 10^( SOR_dB / 20 );
    
        % signal power
        %S                                                               = 1;
        
        % offset power
        %O                                                               = S / SOR_lin;
        %O = 0.01;
        %N_SAMPLES = length(samples);
        % generation of complex-valued DC offset with desired amplitude and random phase
        %dco                                                             = sqrt(O) * exp ( j * rand(1, N_SAMPLES) * 2 * pi );
        
        % combine additively input signal with DC offset
        %out                                                             = samples         + dco;

        out								 = samples + (offset_I + j * offset_Q);    
end
