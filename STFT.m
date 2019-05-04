function X = STFT(x,M,Zp,R,Win)
n = 0;
rows = ceil((1+M*Zp)/2); % the number of frequency bins
R = round(R); % For #3 Phase Vocoder part: needs to be an integer
nframes = round((length(x)-M)/R); % the number of columns
    for m=1:nframes
        xt = x(n+1:n+M,1); % take one window length
        xt = xt .* Win; % window the signal
        xt_z = [xt; zeros((Zp-1)*length(xt),1)]; % zero padding
        temp = fft(xt_z,M*Zp); % take fft of zero padded windowed signal with M*Zp points
        X(:,m) = temp(1:rows); % put "rows" frequency bins in a column 
        n = n + R; % move the index by the hop size
    end
end
