clc;
clear;
close all;

%% ================= DATASET PARAMETERS =================
symb = 1024;
samples_per_snr = 100;
SNR_dB = -10:2:20;
SNR = 10.^(SNR_dB/10);

M_list = [4 8 16 32 64 128 256 512 1024];
label_list = 10:18;

num_rows = numel(M_list) * numel(SNR_dB) * samples_per_snr;
num_features = 1 + 2*symb + 1;

logn_mqam_dataset = zeros(num_rows, num_features, 'single');
gg_mqam_dataset = zeros(num_rows, num_features, 'single');

column_names = [{'snr'}, ...
    arrayfun(@(idx) sprintf('i%d', idx), 1:symb, 'UniformOutput', false), ...
    arrayfun(@(idx) sprintf('q%d', idx), 1:symb, 'UniformOutput', false), ...
    {'label'}];

%% ================= FSO PARAMETERS =================
Rb = 155e6;
Responsivity = 1;
fmin = 1e9;
Fs = 50*fmin;
t = 0:1/Fs:1/Rb;
samples_symb = numel(t);

Ac = 1;
Mod_index = 1/Ac;

Io = 1;
I_var = 0.5;

alpha = 4.2;
beta  = 1.9;

A0 = 1;
sigma_s = 0.3e-3;
we = 1e-3;

V = 0.5;
lambda = 1550e-9;
L_link = 0.5;
beta_fog = 0.585 * V^(-1/3);
alpha_fog = (3.91/V) * (lambda/550e-9)^(-beta_fog);
A_fog = 10^(-alpha_fog*L_link/10);

%% ================= TRANSMITTER/RECEIVER SETUP =================
fc = fmin;
carrier_I = Ac*cos(2*pi*t*fc);
carrier_Q = Ac*sin(2*pi*t*fc);

f_Rb = Rb*10/Fs;
w_bpf = [2*(fc-Rb)/Fs, 2*(fc+Rb)/Fs];
[B1,A1] = butter(1, w_bpf);
[B2,A2] = butter(2, f_Rb);

demod_I_carrier = 2*Ac*cos(2*pi*t*fc);
demod_Q_carrier = 2*Ac*sin(2*pi*t*fc);

%% ================= DATASET GENERATION =================
row_idx = 1;

for iM = 1:numel(M_list)
    M = M_list(iM);
    label = label_list(iM);

    for iSNR = 1:numel(SNR_dB)
        Noise_var = (Mod_index*Responsivity*A_fog)^2 / SNR(iSNR);
        Noise_SD = sqrt(Noise_var);

        for sample_idx = 1:samples_per_snr
            [Inphase, Quadrature] = Basebandmodulation(M, symb);

            I_Mod_Data = reshape((Inphase(:) * carrier_I).', 1, []);
            Q_Mod_Data = reshape((Quadrature(:) * carrier_Q).', 1, []);
            SCM_Tx = 1 + Mod_index*(I_Mod_Data - Q_Mod_Data);

            Hp = PointingError(symb, A0, sigma_s, we, t);

            I_log = LognormalTurbulence(I_var, symb, Io, t);
            rx_iq_log = ChannelAndReceiver(SCM_Tx, I_log, Hp, A_fog, ...
                Responsivity, Noise_SD, symb, samples_symb, B1, A1, B2, A2, ...
                demod_I_carrier, demod_Q_carrier);

            I_gg = GammaGammaTurbulence(alpha, beta, symb, t);
            rx_iq_gg = ChannelAndReceiver(SCM_Tx, I_gg, Hp, A_fog, ...
                Responsivity, Noise_SD, symb, samples_symb, B1, A1, B2, A2, ...
                demod_I_carrier, demod_Q_carrier);

            logn_mqam_dataset(row_idx,:) = single([SNR_dB(iSNR), ...
                real(rx_iq_log), imag(rx_iq_log), label]);
            gg_mqam_dataset(row_idx,:) = single([SNR_dB(iSNR), ...
                real(rx_iq_gg), imag(rx_iq_gg), label]);

            row_idx = row_idx + 1;
        end

        fprintf('M=%4d QAM | label=%d | SNR=%3d dB | %d samples\n', ...
            M, label, SNR_dB(iSNR), samples_per_snr);
    end
end

save('logn_mqam_dataset.mat', 'logn_mqam_dataset', 'column_names', ...
    'M_list', 'label_list', 'SNR_dB', 'samples_per_snr', 'symb', '-v7.3');

save('gg_mqam_dataset.mat', 'gg_mqam_dataset', 'column_names', ...
    'M_list', 'label_list', 'SNR_dB', 'samples_per_snr', 'symb', '-v7.3');

%% ================= FUNCTIONS =================
function [Inphase, Quadrature] = Basebandmodulation(M, symb)
X = randi([0, M-1], symb, 1);
Y = qammod(X, M, 'gray', 'UnitAveragePower', true);
Inphase = real(Y);
Quadrature = imag(Y);
end

function rx_iq = ChannelAndReceiver(SCM_Tx, I, Hp, A_fog, Responsivity, ...
    Noise_SD, symb, samples_symb, B1, A1, B2, A2, demod_I_carrier, demod_Q_carrier)
H = A_fog .* I .* Hp;
SCM_Rx = Responsivity .* H .* SCM_Tx;
Rx_total = SCM_Rx + Noise_SD .* randn(size(SCM_Tx));
rx_iq = ReceiverDemod(Rx_total, symb, samples_symb, B1, A1, B2, A2, ...
    demod_I_carrier, demod_Q_carrier);
end

function rx_iq = ReceiverDemod(Rx_total, symb, samples_symb, ...
    B1, A1, B2, A2, demod_I_carrier, demod_Q_carrier)
filter_out = filter(B1, A1, Rx_total);
I_symb_end = zeros(1, symb);
Q_symb_end = zeros(1, symb);

for i2 = 1:symb
    a2 = 1 + (i2-1)*samples_symb;
    b2 = i2*samples_symb;

    I_Dem_out = demod_I_carrier .* filter_out(a2:b2);
    Q_Dem_out = demod_Q_carrier .* filter_out(a2:b2);
    I_Demod_out = filter(B2, A2, I_Dem_out);
    Q_Demod_out = filter(B2, A2, Q_Dem_out);
    I_symb_end(i2) = I_Demod_out(end);
    Q_symb_end(i2) = -Q_Demod_out(end);
end

rx_iq = I_symb_end + 1i*Q_symb_end;
end

function I = LognormalTurbulence(Log_Int_var, No_symb, Io, t)
l = sqrt(Log_Int_var).*randn(1, No_symb) - (Log_Int_var/2);
I1 = Io .* exp(l);
I = repmat(I1, numel(t), 1);
I = I(:).';
end

function I = GammaGammaTurbulence(alpha, beta, No_symb, t)
X = gamrnd(alpha, 1/alpha, 1, No_symb);
Y = gamrnd(beta, 1/beta, 1, No_symb);
I1 = X .* Y;
I = repmat(I1, numel(t), 1);
I = I(:).';
end

function Hp = PointingError(No_symb, A0, sigma_s, we, t)
r = sigma_s * randn(1, No_symb);
Hp1 = A0 .* exp(-2*(r.^2)/(we^2));
Hp = repmat(Hp1, numel(t), 1);
Hp = Hp(:).';
end
