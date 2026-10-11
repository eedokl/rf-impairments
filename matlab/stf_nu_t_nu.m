function    [   stf                 ,...
                debug               ]                           = stf_nu_t_nu  (    nu_t                ,...
                                                                                    nu                  ,...
                                                                                    D                   ,...
                                                                                    NCFO                ,...
                                                                                    NSFO                )

% =============================================================================== %
%
% Title         : Compute Subcarrier Transfer Factor
%
% Project       : LTE
%
% File          : stf_nu_t_nu.m
% Author        : Oliver Klein
%
% Created       : 2005/02/21
% Revision      : 0.1
%
% =============================================================================== %
%
% Functional Description:
% =======================
%
% Function implements Equation (3.55) from
% Stefan Mueller-Weinfurtner
% 'OFDM for Wireless Communications'
% PhD Thesis, University of Erlangen-Nuremberg
%
%
% INPUT
% -----------------------------------------------------------
% nu_t:                                 parameter
%                                        
%
% nu:                                   parameter
%                                        
%
% D:                                    parameter
%                                        
%
% NCFO:                                 parameter
%                                        
%
% NSFO:                                 parameter
%                                        
%
%
% OUTPUT
% -----------------------------------------------------------
% stf:                                  parameter
%                       
%
% debug:                                signal
%                                       debug port
%
% =============================================================================== %

%
tmp                                                                     = ((1 + NSFO) * nu_t - nu + NCFO);

% exponential term
exponential_term                                                        = exp(j * pi * (D-1)/D * tmp);

% 'sis' function term
[sis_function_term      ,...
 debug_sis_b            ]                                               = sis_b  (          D               ,...
                                                                                            tmp             );

%
stf                                                                     = exponential_term * sis_function_term;

% assign debug port
debug                                                                   = -99;




















