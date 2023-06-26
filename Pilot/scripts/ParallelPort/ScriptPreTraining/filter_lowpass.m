function SignalF = filter_lowpass(x,y) 

% x = EMG Data
% y = cutoff frequency

% Signal features
                fs                 = single(200);
                fnyq               = fs/2;
 % Lowpass filter
                order_lp           = 2;
                fco_lp             = y; %cutoff frequency to have the envelop and study the contraction
                w_lp               = fco_lp/double(fnyq);
                
                [b_lp,a_lp]  = butter(order_lp,w_lp,'low');
                SignalF   = filtfilt(b_lp,a_lp,double(x));
                
end