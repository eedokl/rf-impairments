function compare(tx_data_field_data_mod,amplitude,phase)
% phase in degree

plot(add_iq_imbalance(tx_data_field_data_mod,1,amplitude,phase),'o'); grid on; axis([-1 1 -1 1]*2); axis square;
hold on;

plot(add_iq_imbalance_ld(tx_data_field_data_mod,1,amplitude,phase),'rx'); grid on; axis([-1 1 -1 1]*2); axis square;

g = (-amplitude*1.5+1)

plot(add_iq_imbalance_fw(tx_data_field_data_mod,1,g,phase),'b*'); grid on; axis([-1 1 -1 1]*2); axis square;

plot(tx_data_field_data_mod,'gd');

hold off;

legend('OFDM Book, Literature','Lund Matlab','Fredrick, Elias, Fettweiss','undisturbed');

% Note: The definition from literature which is
% in correspondance to Simulink chain is that
% first we have gain imbalance and then phase imbalance.
%
% The definition from Lund (Elias/Fredrick) is
% first phase imbalance and amplitude imbalance
% afterwards