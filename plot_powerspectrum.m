function plot_powerspectrum(signal, fs)

L = length(signal); % Length of signal 
xdft = fft(signal);
Pxx = 1/(L*fs)*abs(xdft(1:length(signal)/2+1)).^2;
freq = 0:fs/L:fs/2;

figure
plot(freq,10*log10(Pxx));
xlabel('Hz'); ylabel('dB/Hz');

end