% =============================================================================== %
%
% Title         : Testbench for Loss of Orthogonality due to
%                 1. Carrier Frequency Offset
%                 2. Sampling Frequency Offset
%
% Project       : LTE
%
% File          : orthogonality_loss.m
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

% Figures 3.4 to 3.7 according to Equation (3.60) from
% Stefan Mueller-Weinfurtner: 'OFDM for Wireless Communications'
% PhD Thesis, University of Erlangen-Nuremberg

% activate plotting of certain figures
PLOT_FIGURE_3_4                                                         = 1;
PLOT_FIGURE_3_5                                                         = 1;
PLOT_FIGURE_3_6                                                         = 1;
PLOT_FIGURE_3_7                                                         = 1;


% FFT size
D                                                                       = 64;
N_ACTIVE_CARRIERS                                                       = 53;



if PLOT_FIGURE_3_4 == 1
figure(1)
% --------------------------------------------------------------------------------------------------------------------- %
% normalized carrier frequency offset
NCFO                                                                    = 0.01;

% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)],CIR_dB, 'r-');
hold;

% normalized carrier frequency offset
NCFO                                                                    = 0.0316;

% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)],CIR_dB, 'b--');


% normalized carrier frequency offset
NCFO                                                                    = 0.1;

% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)],CIR_dB, 'k-.');
hold;
legend( 'NCFO = 0.01'   ,...
        'NCFO = 0.0316' ,...
        'NCFO = 0.1'    );
grid;
xlabel('nu');
ylabel('10*log10(SIR(nu)) [dB]');
title('Impact of NCFO on Subcarrier SIR [dB]');
axis([-27 -17 10 40]);
end

if PLOT_FIGURE_3_6 == 1
figure(2)
% --------------------------------------------------------------------------------------------------------------------- %
% normalized sampling frequency offset
NSFO                                                                    = 1e-4;

% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)],CIR_dB, 'r-');
hold;

% normalized sampling frequency offset
NSFO                                                                    = 1e-3;

% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)],CIR_dB, 'b--');

% normalized sampling frequency offset
NSFO                                                                    = 1e-2;

% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)],CIR_dB, 'k-.');
hold;
legend( 'NCFO = 0.01'   ,...
        'NCFO = 0.0316' ,...
        'NCFO = 0.1'    );
grid;
xlabel('nu');
ylabel('10*log10(SIR(nu)) [dB]');
title('Impact of NSFO on Subcarrier SIR [dB]');
axis([-27 +27 5 65]);
end

if PLOT_FIGURE_3_5 == 1
figure(3)
% --------------------------------------------------------------------------------------------------------------------- %
% current subcarrier
nu                                                                      = 0;

% loop for NCFOs
for NCFO = 0.001 : 0.001 : 0.5,

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(round(NCFO*1000))                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

semilogx([0.001 : 0.001 : 0.5],CIR_dB, 'r-');
hold;

% current subcarrier
nu                                                                      = +26;

% loop for NCFOs
for NCFO = 0.001 : 0.001 : 0.5,

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(round(NCFO*1000))                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

semilogx([0.001 : 0.001 : 0.5],CIR_dB, 'b--');

% current subcarrier
nu                                                                      = -26;

% loop for NCFOs
for NCFO = 0.001 : 0.001 : 0.5,

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    NCFO                ,...
                                                                                                    0                   );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(round(NCFO*1000))                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

semilogx([0.001 : 0.001 : 0.5],CIR_dB, 'k-.');
hold;
legend( 'nu = 0'    ,...
        'nu = -26'  ,...
        'nu = +26'  );
axis([0.001 0.6 0 55]);
grid;
xlabel('nu');
ylabel('10*log10(SIR(nu)) [dB]');
title('Impact of NCFO on Subcarrier SIR [dB]');

end



if PLOT_FIGURE_3_7 == 1
figure(4)
% --------------------------------------------------------------------------------------------------------------------- %
% FFT size
D                                                                       = 64;
N_ACTIVE_CARRIERS                                                       = 53;
% normalized sampling frequency offset
NSFO                                                                    = 0.01/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'r-');
hold;

% FFT size
D                                                                       = 128;
N_ACTIVE_CARRIERS                                                       = 105;
% normalized sampling frequency offset
NSFO                                                                    = 0.01/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'r--');

% FFT size
D                                                                       = 256;
N_ACTIVE_CARRIERS                                                       = 209;
% normalized sampling frequency offset
NSFO                                                                    = 0.01/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'r-.');

% FFT size
D                                                                       = 64;
N_ACTIVE_CARRIERS                                                       = 53;
% normalized sampling frequency offset
NSFO                                                                    = 0.0316/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'b-');

% FFT size
D                                                                       = 128;
N_ACTIVE_CARRIERS                                                       = 105;
% normalized sampling frequency offset
NSFO                                                                    = 0.0316/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'b--');

% FFT size
D                                                                       = 256;
N_ACTIVE_CARRIERS                                                       = 209;
% normalized sampling frequency offset
NSFO                                                                    = 0.0316/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'b-.');

% FFT size
D                                                                       = 64;
N_ACTIVE_CARRIERS                                                       = 53;
% normalized sampling frequency offset
NSFO                                                                    = 0.1/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'k-');

% FFT size
D                                                                       = 128;
N_ACTIVE_CARRIERS                                                       = 105;
% normalized sampling frequency offset
NSFO                                                                    = 0.1/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'k--');

% FFT size
D                                                                       = 256;
N_ACTIVE_CARRIERS                                                       = 209;
% normalized sampling frequency offset
NSFO                                                                    = 0.1/D;

% loop for active subcarriers
CIR_dB                                                                  = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        % dividend
        [stf_dividend           ,...
         debug_stf_nu_t_nu      ]                                       = stf_nu_t_nu  (            nu                  ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );
        stf_dividend_abs_sqr                                            = (abs(stf_dividend)).^2;

        % divisor
        stf_divisor                                                     = zeros(1,length(-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)));
        for nu_t = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

                [stf_divisor(nu_t+floor(N_ACTIVE_CARRIERS/2)+1) ,...
                 debug_stf_nu_t_nu                              ]       = stf_nu_t_nu  (            nu_t                ,...
                                                                                                    nu                  ,...
                                                                                                    D                   ,...
                                                                                                    0                   ,...
                                                                                                    NSFO                );

        end
        stf_divisor_abs_sqr                                             = (abs(stf_divisor)).^2;
        sum_stf_divisor_abs_sqr                                         = sum(stf_divisor_abs_sqr) - stf_divisor_abs_sqr(nu+floor(N_ACTIVE_CARRIERS/2)+1);                                                                                            

        % CIR
        CIR_dB(nu+floor(N_ACTIVE_CARRIERS/2)+1)                         = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

plot([-floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2)]/D,CIR_dB, 'k-.');
hold;
legend( 'D =  64, D*NSFO = 0.01'   ,...
        'D = 128, D*NSFO = 0.01'   ,...
        'D = 256, D*NSFO = 0.01'   ,...
        'D =  64, D*NSFO = 0.0316' ,...
        'D = 128, D*NSFO = 0.0316' ,...
        'D = 256, D*NSFO = 0.0316' ,...
        'D =  64, D*NSFO = 0.1'    ,...
        'D = 128, D*NSFO = 0.1'    ,...
        'D = 256, D*NSFO = 0.1'    );
grid;
xlabel('nu/D');
ylabel('10*log10(SIR(nu)) [dB]');
title('Impact of NSFO on Subcarrier SIR [dB]');
%axis([-0.42 +0.42 20 65]);
end













