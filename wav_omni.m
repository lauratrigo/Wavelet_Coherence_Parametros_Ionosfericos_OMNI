% ==============================
% Wavelet Coherence entre parâmetros do OMNI
% ==============================
clc; clear; close all;

% --- 1) Ler arquivo OMNI ---
fid = fopen('dados_Omni_Tratados.txt');
data = textscan(fid, '%d %d %d %s %f %f %f %f %f %f', 'Delimiter', '\t', 'CollectOutput', false);
fclose(fid);

dia = data{1};
mes = data{2};
ano = data{3};
hora_str = data{4};
hora_min = split(hora_str, ':');
HR = str2double(hora_min(:,1));
MN = str2double(hora_min(:,2));
omni_time = datetime(ano, mes, dia, HR, MN, zeros(length(dia),1));

% --- Colunas do arquivo ---
% 5: Bz, 6: Vsw, 7: Density, 8: Ey, 9: AE, 10: SYM/H
omni_data = [data{5}, data{6}, data{7}, data{8}, data{9}, data{10}];
omni_names = {'Bz', 'Vsw', 'Density', 'Ey', 'AE', 'SYM_H'};

% --- 2) Interpolação para grade regular (5 min) ---
start_time = datetime(2017,8,1,0,0,0);
end_time = datetime(2017,9,1,0,0,0);
iono_time = (start_time:minutes(5):end_time)';  

x_omni = datenum(omni_time);
xq = datenum(iono_time);

omni_interp = NaN(length(xq), size(omni_data,2));
for i = 1:size(omni_data,2)
    omni_interp(:,i) = interp1(x_omni, omni_data(:,i), xq, 'linear', NaN);
end

% --- 3) Parâmetros da wavelet ---
fs = 1/300;   % 1 amostra a cada 300 s = 5 min
dt = 300;     % passo temporal em segundos

% Criar pasta 'images' se não existir
output_folder = fullfile(pwd, 'images');  % garante caminho absoluto
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% --- 5) Loop de comparações entre pares de variáveis ---
nvars = size(omni_interp,2);

for i = 1:nvars-1
    for j = i+1:nvars
        sig1 = omni_interp(:,i);
        sig2 = omni_interp(:,j);
        name1 = omni_names{i};
        name2 = omni_names{j};

        fprintf('>> Comparando %s × %s ...\n', name1, name2);

        % --- Limpar NaNs ---
        mask_nan = isnan(sig1) | isnan(sig2);
        sig1_clean = sig1; sig2_clean = sig2;
        sig1_clean(mask_nan) = 0;
        sig2_clean(mask_nan) = 0;

        % --- Extensão espelhada ---
        left1 = flipud(sig1_clean);
        sig1_ext = [left1; left1; sig1_clean; left1; left1];
        left2 = flipud(sig2_clean);
        sig2_ext = [left2; left2; sig2_clean; left2; left2];

        % --- Filtro wavelet ---
        fb = cwtfilterbank('SignalLength', numel(sig2_ext), ...
                           'SamplingFrequency', fs, ...
                           'FrequencyLimits', [1e-7 1e-4]);

        [WCOH,~,period,coi] = wcoherence(sig1_ext, sig2_ext, seconds(dt), 'FilterBank', fb);

        % --- Recorte central ---
        n = length(sig1_clean);
        try
            wcoh_central = WCOH(62:147, 2*n+1:3*n);
            period_sel   = period(62:147,1);
        catch
            wcoh_central = WCOH(:, 2*n+1:3*n);
            period_sel   = period(:,1);
        end

        wcoh_central(:, mask_nan) = NaN;
        period_days = days(period_sel);
        period_log_inv = flipud(log2(period_days));
        wcoh_central = flipud(wcoh_central);

        % --- Plot ---
        figure('Name', sprintf('WCOH: %s × %s', name1, name2), 'NumberTitle', 'off');
        h = pcolor(datenum(iono_time), period_log_inv, wcoh_central);
        set(h, 'EdgeColor', 'none', 'AlphaData', ~isnan(wcoh_central));
        colormap jet;
        c = colorbar;
        c.Limits = [0 1];
        c.Ticks = 0.1:0.1:0.9;
        c.TickLabels = string(c.Ticks);
        set(gca, 'Color', 'w');

        ax = gca;
        ax.YDir = 'normal';
        ax.FontSize = 14;
        xlabel('Time (days)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Period (days)', 'FontSize', 14, 'FontWeight', 'bold');
        title(sprintf('Wavelet Coherence: %s × %s', name1, name2), 'FontSize', 16, 'FontWeight', 'bold');

        % --- Eixos ---
        xticks_custom = datenum(datetime(2017,8,1):days(2):datetime(2017,8,31));
        ax.XTick = xticks_custom;
        ax.XTickLabel = datestr(xticks_custom, 'dd');
        ax.XTickLabelRotation = 90;
        xlim([datenum(datetime(2017,8,1)) datenum(datetime(2017,9,1))]);

        periods2 = [0.25 0.5 1 2 4 8 16 31];
        ax.YTick = log2(periods2);
        ax.YTickLabel = string(periods2);

        drawnow;

        % --- SALVAR FIGURA AUTOMATICAMENTE ---
        safe_name1 = regexprep(name1, '[^a-zA-Z0-9]', '_');
        safe_name2 = regexprep(name2, '[^a-zA-Z0-9]', '_');
        filename = fullfile(output_folder, sprintf('image_%s_%s.png', safe_name1, safe_name2));
        print(gcf, filename, '-dpng', '-r300');       % imprime a figura como PNG 300 dpi
    end
end

disp('>>> Todas as comparações concluídas.');
