% =============================================================================== %
%
% Title         : Testbench for 'sis' Function
%
% Project       : LTE
%
% File          : testbench_sis_function.m
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
clear all;

% plot 'sis' function according to
% Equation (3.56)
% Stefan Mueller-Weinfurtner
% 'OFDM for Wireless Communications'
% PhD Thesis, University of Erlangen-Nuremberg
stepsize                                        = 0.01;
x                                               = [0 : stepsize : 16];
%
[sis_b_for_b_equal_6 ,...
 debug_sis_b         ]                          = sis_b  (          6               ,...
                                                                    x               );
[sis_b_for_b_equal_7 ,...
 debug_sis_b         ]                          = sis_b  (          7               ,...
                                                                    x               );
[sis_b_for_b_equal_8 ,...
 debug_sis_b         ]                          = sis_b  (          8               ,...
                                                                    x               );
%
if 1
    figure(1)    
    plot(sis_b_for_b_equal_6,'r-');
    hold;
    plot(sis_b_for_b_equal_7,'b--');
    plot(sis_b_for_b_equal_8,'k-.');
    hold;
    grid;
    xlabel('x');
    ylabel('sis_b(x)');
    title('Exemplary Plot of the "sis"-Function for b = 6,7 and 8');
    legend( 'b = 6'  ,...
            'b = 7'  ,...
            'b = 8'  );
    axis([0 16/stepsize -1.1 +1.1]);
end    

















