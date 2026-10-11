function [h] = gls_coef(    mu  ,...
                            L   ,...
                            wp  )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function GLS_COEF
%
% Function implements fractional delay (FD) approximation
% using 'general least squares' method.
%
% [1]               V. Välimäki
%                   Discrete-Time Modeling of Acoustic Tubes Using
%                   Fractional Delay Filters,
%                   Chapter 3.2.4:
%                   'General Least Squares FIR Approximation
%                   of a Complex Frequency Response'
%                   PhD Thesis
%                   Helsinki University of Technology
%                   Finland, December 1995
%
% INPUT
% mu:               fractional delay (0 <= mu <= 1)
%
% filterlength:     L
%
% wp:               passband edge of approximation
%
% OUTPUT
% h:                filter coefficient vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filter order
N = L-1;

if rem(N,2) == 1        % N odd, L even

        % Eq.(3.34),Eq.(3.35) in [1]
        D       = mu + (N / 2) - (1 / 2);
        
else                    % N even,L odd

        % Eq.(3.34),Eq.(3.36) in [1]
        D       = mu + (N / 2);
        
end

% build Toeplitz matrix P and vector p1
cT=zeros(L,1);
p1=zeros(L,1);

if 0
for k=0:N

    % Eq.(3.47) in [1]
    cT(k+1)     = wp * sinc(k * wp);

    % Eq.(3.48) in [1]
    p1(k+1)     = wp * sinc((k - D) * wp);
end    
else
    cT(1:N+1)   = wp * sinc([0:N] * wp);
    p1(1:N+1)   = wp * sinc(([0:N] - D) * wp);
end

% Eq.(3.47) in [1]
P               = toeplitz(cT);

% Eq.(3.46) in [1]
h               = (P \ p1);

% reverse h
h               = flipud(h);
