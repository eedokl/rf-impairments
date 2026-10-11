% =============================================================================== %
%
% Title         : Testbench for 'stf' Function
%
% Project       : LTE
%
% File          : testbench_stf_nu_t_nu.m
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

% plot 'stf' function according to
% Equation (3.55)
% Stefan Mueller-Weinfurtner
% 'OFDM for Wireless Communications'
% PhD Thesis, University of Erlangen-Nuremberg


% FFT size
D                                                               = 8192;

% current subcarrier
nu                                                              = 0;



% --------------------------------------------------------------------------------------------------------------------- %
% normalized carrier frequency offset
NCFO                                                            = 0.1;
% normalized sampling frequency offset
NSFO                                                            = 0;

for nu_t = -100 : 1 : +100

        [stf(nu_t+100+1)           ,...
         debug_stf_nu_t_nu   ]                                  = stf_nu_t_nu  (            nu_t                ,...
                                                                                            nu                  ,...
                                                                                            D                   ,...
                                                                                            NCFO                ,...
                                                                                            NSFO                );

end

figure(1)
plot([[-100:1:-1] 0 [1:1:+100]],[abs(stf(1:100)) 0 abs(stf(102:201))],'r-')
hold;

% --------------------------------------------------------------------------------------------------------------------- %
% normalized carrier frequency offset
NCFO                                                            = 0;
% normalized sampling frequency offset
NSFO                                                            = 0.1;

for nu_t = -100 : 1 : +100

        [stf(nu_t+100+1)           ,...
         debug_stf_nu_t_nu   ]                                  = stf_nu_t_nu  (            nu_t                ,...
                                                                                            nu                  ,...
                                                                                            D                   ,...
                                                                                            NCFO                ,...
                                                                                            NSFO                );

end

plot([[-100:1:-1] 0 [1:1:+100]],[abs(stf(1:100)) 0 abs(stf(102:201))],'b-')
hold;
grid;
xlabel('Subcarrier Index');
ylabel('Subcarrier Transfer Factor');
legend( 'NCFO = 0.1, NSFO = 0.0'  ,...
        'NCFO = 0.0, NSFO = 0.1'  );
axis([-105 +105 -0.005 +0.12]);






