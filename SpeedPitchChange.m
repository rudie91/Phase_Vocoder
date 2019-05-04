function y = SpeedPitchChange(x, fs, alpha, beta)
% 1. resampling
x_re= resample(x,1*100,round(beta*100));

W_Hann = hann(1024,'periodic');
M = 1024; Zp = 4; R = 256;
% 2. Calculate the Spectrogram of the resampled audio
Y_re = STFT(x_re,M,Zp,R,W_Hann);
nframes = size(Y_re,2);
nframes_Y = round(size(Y_re,2)*1/alpha); % change the frames of Y according to factors
ymag = 0;
yphase = 0;
for n = 1:nframes_Y
    if n == 1||n == nframes_Y %first and the last frame
        Y(:,n) = Y_re(:,n);
    else
        % calculate correspoding t1, t, t2
        t(n) = round(nframes*n/nframes_Y);
        t1 = t(n)-1;
        t2 = t(n)+1;
        % compute lambda
        lambda = (t(n)-t1)/(t2-t1);
        % magnitude interpolation
        ymag = (1-lambda)*abs(Y_re(:,t1))+lambda*abs(Y_re(:,t2));
        % phase interpolation
        yphase = angle(Y_re(:,t2))-angle(Y_re(:,t1))+angle(Y_re(:,n));
    end
    % update each frame
    Y(:,n) = ymag .*exp(1j*yphase);
end
% convert to time domain:OLA method
nframes = size(Y,2);
time_y = nframes*R+M;
y = zeros(time_y,1);
n = 1;
for m = 1:nframes
    Y_temp = Y(:,m);
    Y_temp = [Y_temp;conj(Y_temp(end-1:-1:2))];
    y_temp = real(ifft(Y_temp));
    y_temp = y_temp(1:M);
    y(n:(n+M-1)) = y(n:(n+M-1))+(y_temp.*W_Hann);
    n = n+R;
end
y = y*2/3;