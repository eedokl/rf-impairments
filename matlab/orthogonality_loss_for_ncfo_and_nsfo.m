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
clear all;

% Figures similar to Figures 3.4 to 3.7 from
% Stefan Mueller-Weinfurtner: 'OFDM for Wireless Communications'
% PhD Thesis, University of Erlangen-Nuremberg

% activate plotting of certain figures
PLOT_FIGURE_3_4                                                         = 1;
PLOT_FIGURE_3_5                                                         = 1;
PLOT_FIGURE_3_6                                                         = 1;
PLOT_FIGURE_3_7                                                         = 1;


% FFT size
D                                                                       = 2048;
N_ACTIVE_CARRIERS                                                       = 1201;



if PLOT_FIGURE_3_4 == 1
figure(1)
% --------------------------------------------------------------------------------------------------------------------- %
% normalized carrier frequency offset
fc = 2.5e9;
fco = 2.5e9 * 0.1 / 1e6; % 0.1ppm .... that is the remaining offset after correction (like defined in 25.101)
fsub=15e3;
NCFO                                                                    = 0.001;
NCFO = fco / fsub;


% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        if (mod(nu,100)==0)
            disp(nu);
        end
    
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
grid;
xlabel('nu');
ylabel('10*log10(SIR(nu)) [dB]');
title(sprintf('Impact of NCFO = %d on Subcarrier SIR [dB]'),NCFO);
%axis([-27 -17 10 40]);
end

if PLOT_FIGURE_3_5 == 1
clear CIR_dB;    
figure(2)
% --------------------------------------------------------------------------------------------------------------------- %
% current subcarrier
nu                                                                      = 0;

% loop for NCFOs
for NCFO = 0.001 : 0.001 : 0.5,

        if (mod(NCFO,0.1)==0)
            disp(NCFO);
        end

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

semilogx([0.001 : 0.001 : 0.5],CIR_dB(1:length([0.001 : 0.001 : 0.5])), 'r-');
hold;

% current subcarrier
nu                                                                      = (N_ACTIVE_CARRIERS-1)/2;

% loop for NCFOs
for NCFO = 0.001 : 0.001 : 0.5,

        if (mod(NCFO,0.1)==0)
            disp(NCFO);
        end

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

semilogx([0.001 : 0.001 : 0.5],CIR_dB(1:length([0.001 : 0.001 : 0.5])), 'b--');

% current subcarrier
nu                                                                      = -(N_ACTIVE_CARRIERS-1)/2;

% loop for NCFOs
for NCFO = 0.001 : 0.001 : 0.5,

        if (mod(NCFO,0.1)==0)
            disp(NCFO);
        end

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

semilogx([0.001 : 0.001 : 0.5],CIR_dB(1:length([0.001 : 0.001 : 0.5])), 'k-.');
hold;
legend( 'nu = 0'      ,...
        sprintf('nu = -%d',(N_ACTIVE_CARRIERS-1)/2)  ,...
        sprintf('nu = +%d',(N_ACTIVE_CARRIERS-1)/2)  );
%axis([0.001 0.6 0 55]);
grid;
xlabel('NCFO');
ylabel('10*log10(SIR(NCFO)) [dB]');
title('Impact of NCFO on Subcarrier SIR [dB]');

end

if PLOT_FIGURE_3_6 == 1
clear CIR_dB;    
figure(3)
% --------------------------------------------------------------------------------------------------------------------- %
% normalized sampling frequency offset
%NSFO                                                                    = 0.00001;
NSFO                                                                    = 15/1e6; % 15ppm


% loop for active subcarriers
for nu = -floor(N_ACTIVE_CARRIERS/2) : 1 : +floor(N_ACTIVE_CARRIERS/2),

        if (mod(nu,100)==0)
            disp(nu);
        end
    
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
grid;
xlabel('nu');
ylabel('10*log10(SIR(nu)) [dB]');
title(sprintf('Impact of NSFO = %d ppm on Subcarrier SIR [dB]',NSFO*1e6));
%axis([-27 +27 5 65]);
end

if PLOT_FIGURE_3_7 == 1
clear CIR_dB;    
figure(4)
% --------------------------------------------------------------------------------------------------------------------- %
% current subcarrier
nu                                                                      = 0;

% loop for NCFOs
for NSFO = 0.000001 : 0.000001 : 0.0001,

        if (mod(NSFO,0.00001)==0)
            disp(NSFO);
        end

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
        CIR_dB(round(NSFO*1000000))                                     = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

semilogx([0.000001 : 0.000001 : 0.0001],CIR_dB(1:length([0.000001 : 0.000001 : 0.0001])), 'r-');
hold,

% current subcarrier
nu                                                                      = +(N_ACTIVE_CARRIERS-1)/2;

% loop for NCFOs                 
%          0.000015
for NSFO = 0.000001 : 0.000001 : 0.0001,

        if (mod(NSFO,0.00001)==0)
            disp(NSFO);
        end

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
        CIR_dB(round(NSFO*1000000))                                     = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

semilogx([0.000001 : 0.000001 : 0.0001],CIR_dB(1:length([0.000001 : 0.000001 : 0.0001])), 'b--');

% current subcarrier
nu                                                                      = +(N_ACTIVE_CARRIERS-1)/4;

% loop for NCFOs
for NSFO = 0.000001 : 0.000001 : 0.0001,

        if (mod(NSFO,0.00001)==0)
            disp(NSFO);
        end

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
        CIR_dB(round(NSFO*1000000))                                     = 10*log10(stf_dividend_abs_sqr / sum_stf_divisor_abs_sqr);

end

semilogx([0.000001 : 0.000001 : 0.0001],CIR_dB(1:length([0.000001 : 0.000001 : 0.0001])), 'k-.');
hold,
%axis([0.001 0.6 0 55]);
grid;
legend( 'nu = 0'      ,...
        sprintf('nu = +%d',(N_ACTIVE_CARRIERS-1)/2)  ,...
        sprintf('nu = +%d',nu) );
xlabel('NSFO');
ylabel('10*log10(SIR(NSFO)) [dB]');
title('Impact of NSFO on Subcarrier SIR [dB]');

end













