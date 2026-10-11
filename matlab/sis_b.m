function    [   sis_b_over_x        ,...
                debug               ]                           = sis_b  (      b               ,...
                                                                                x               )

% =============================================================================== %
%
% Title         : Compute 'sis' Function
%
% Project       : LTE
%
% File          : sis_b.m
% Author        : Oliver Klein
%
% Created       : 2005/02/21
% Revision      : 0.1
%
% =============================================================================== %
%
%                              (C) COPYRIGHT 2005
%
%                              ALL RIGHTS RESERVED
%
% =============================================================================== %
%
% Functional Description:
% =======================
%
% Function implements Equation (3.56) from
% Stefan Mueller-Weinfurtner
% 'OFDM for Wireless Communications'
% PhD Thesis, University of Erlangen-Nuremberg
%
%
% INPUT
% -----------------------------------------------------------
% b:                                    parameter
%                                        
%
% x:                                    parameter
%                                        
%
%
% OUTPUT
% -----------------------------------------------------------
% sis_b_over_x:                         parameter
%                       
%
% debug:                                signal
%                                       debug port
%
% =============================================================================== %


for m = 1:length(x),
    
        if      (x(m)/b - round(x(m)/b)) ~= 0

                %
                sis_b_over_x(m)         = 1/b * (sin(pi * x(m)) ./ sin(pi * x(m) / b));

        else

                %
                k                       = x(m)/b;

                %
                sis_b_over_x(m)         = (-1).^(k * (b+1));

        end

end


% assign debug port
debug                                   = -99;




















