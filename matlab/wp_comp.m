function [      wpcomp_block    ,...
                phase_shifts    ]       = wp_comp(              in_block                        ,...
                                                                WP_COMP_ON                      ,...
                                                                WPLACEMENT                      ,...
                                                                N_SYMBOLS_PER_PACKET            ,...
                                                                N_SD                            )
                                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function 
%
% Function implements the window placement compensation in frequency domain
%
%
% The function is switched off (transparent) by WP_COMP_ON = 0.
%
%
% Implemented algorithm
% ---------------------
% 1. 
% 2. 
% 3. 
%
% The function works on a packet basis, i.e., is called once per packet.
%
% %%% INPUT %%%
% in_block:                     Signal
%                               input block potentially distorted by sampling clock offset
%
% WP_COMP_ON:                   Parameter
%                               window placement compensation on/off
%                               0 - no compensation (function is transparent)
%                               1 - window placement compensation
%
% N_SYMBOLS_PER_PACKET:         Parameter
%
%
% %%% OUTPUT %%%
% wpcomp_block:                 Signal
%                               window placement compensated block
%
% phase_shifts:                 Signal
%                               packet-length vector of sample-spaced phase differences [rad]
%                               dim: (Nc x N_SYMBOLS_PER_PACKET), 
%                                     Nc = Number of used carriers
%
% Oliver Klein
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nc   = length(in_block);
NFFT = 2^nextpow2(Nc);

if      WP_COMP_ON == 0

        % no compensation (transparent functionality)
        wpcomp_block            = in_block;
        phase_shifts            = zeros(Nc,N_SYMBOLS_PER_PACKET);

elseif  WP_COMP_ON == 1
    
        % all subcarriers indizes (typically also w/o pilots and w/o DC - not implemented here)
        m                       = [-(Nc-1)/2 : -1, 0, 1 : (Nc-1)/2];
        
        % N_SD-length vector of phase rotation values per subcarrier [rad]
        phi_subcarrier          = WPLACEMENT * 2 * pi * m / NFFT;

        % N_SD-length vector of phase differences [rad] targeted for phase compensation
        phase_shifts            = repmat(exp ( -j * phi_subcarrier ),N_SYMBOLS_PER_PACKET,1).';
        
        % 'separate' in_block into blocks of N_SD bits
        in_block_sep            = reshape(in_block,Nc,N_SYMBOLS_PER_PACKET);
        
        % initialize
        wpcomp_block_sep        = zeros(Nc,N_SYMBOLS_PER_PACKET);
        
        for x = 1 : N_SYMBOLS_PER_PACKET,            
                % compensation of subcarriers
                wpcomp_block_sep(:,x) = in_block_sep(:,x) .* phase_shifts(:,x);
        end                
        
        % combine blocks of N_SD bits to so_block
        wpcomp_block            = reshape(wpcomp_block_sep,1,length(in_block));
        
end



