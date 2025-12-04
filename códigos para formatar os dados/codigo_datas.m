% Lê os dados do arquivo original
dados = readmatrix('teste.dat');  % Altere para o nome correto do seu arquivo

% Pré-aloca uma célula para permitir mistura de texto (hora:minuto) e números
dadosCorrigidos = cell(size(dados,1), size(dados,2));  % Menos uma coluna (removendo DOY), somando "hora:minuto"

for i = 1:size(dados,1)
    ano = dados(i,1);
    doy = dados(i,2);
    hora = dados(i,3);
    minuto = dados(i,4);
    
    % Converte DOY para data real
    data = datetime(ano,1,1) + days(doy - 1);
    dia = day(data);
    mes = month(data);
    
    % Formata hora:minuto como string "HH:MM"
    horaMinStr = sprintf('%02d:%02d', hora, minuto);
    
    % Remove DOY (segunda coluna) e hora/minuto (colunas 3 e 4)
    dadosRestantes = dados(i,5:end);
    
    % Monta linha: {dia, mês, ano, 'hora:minuto', ...dados restantes...}
    dadosCorrigidos(i,:) = [{dia, mes, ano, horaMinStr}, num2cell(dadosRestantes)];
end

% Salvar como TXT (ou CSV) com separador de tabulação
writecell(dadosCorrigidos, 'dados_finais_formatados.dat', 'Delimiter', 'tab');
