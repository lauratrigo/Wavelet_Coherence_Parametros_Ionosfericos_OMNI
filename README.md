# 🔗 Wavelet Coherence entre Parâmetros Ionosféricos — Dados OMNI

Este repositório contém um script MATLAB desenvolvido para calcular e visualizar a **Coerência Wavelet (Wavelet Coherence – WCOH)** entre pares de parâmetros físicos do banco de dados OMNI (com resolução de 5 minutos).  
A análise permite identificar relações espectro-temporais entre grandezas relacionadas ao vento solar e ao campo geomagnético.

## 🛠 Tecnologias Utilizadas

- **MATLAB**
- Arquivo tabulado `dados_Omni_Tratados.txt` contendo dados OMNI pré-processados

![MATLAB Badge](https://img.shields.io/badge/MATLAB-R2019b-red)

---

## 💡 Objetivo

Avaliar a coerência entre diferentes parâmetros solares e geomagnéticos ao longo do tempo, identificando:

- periodicidades comuns  
- correlações espectrais variáveis  
- possíveis relações dinâmicas entre parâmetros do vento solar e índices geomagnéticos  

Os pares analisados incluem, por exemplo:

- Bz × Velocidade (Vsw)  
- Densidade × Ey  
- AE × SYM/H  
- entre outras combinações possíveis

---

## 🚀 Funcionalidades

- Leitura automática dos dados OMNI em formato tabulado  
- Conversão da data/hora para `datetime`  
- Interpolação dos dados para uma grade temporal regular de 5 minutos  
- Tratamento de NaNs e extensão espelhada para reduzir bordas na análise  
- Aplicação da **Coerência Wavelet (WCOH)** com `cwtfilterbank` customizado  
- Geração de gráficos espectro-temporais da coerência entre todos os pares possíveis  
- Eixo Y em períodos (dias), com escala log2  
- Eixo X formatado com datas a cada 2 dias  

---

## 📦 Como Executar o Projeto

### **1️⃣ Preparar o arquivo de dados**

Antes de rodar o script, verifique se o arquivo **dados_Omni_Tratados.txt** está na mesma pasta e contém as colunas:

1. Dia (DD)  
2. Mês (MM)  
3. Ano (YYYY)  
4. Hora:Min  
5. Bz (nT, GSM)  
6. Velocidade Vsw (km/s)  
7. Densidade de prótons (n/cc)  
8. Campo elétrico Ey (mV/m)  
9. Índice AE (nT)  
10. Índice SYM/H (nT)

### **2️⃣ Rodar o script**

No MATLAB:

```matlab
run wavelet_coherence_omni.m
```
O script irá gerar gráficos para todas as combinações possíveis entre as 6 variáveis OMNI (15 gráficos no total).

## 🔧 Detalhes Técnicos da Implementação

- Frequência de amostragem utilizada: **1 ponto a cada 300 s (5 min)**  
- Intervalo temporal analisado: **01/08/2017 a 01/09/2017**  
- Interpolação linear para alinhar os dados à grade fixa  
- Extensão espelhada (*mirror padding*) para reduzir distorções na análise wavelet  
- Uso de:

```matlab
wcoherence(sig1_ext, sig2_ext, seconds(dt), 'FilterBank', fb)
```

- Coerência recortada apenas na região correspondente aos dados originais  
- Normalização dos períodos e uso de `log2(period)` para o eixo Y  
- Máscara de NaN aplicada à coerência para garantir consistência visual  

## 📂 Estrutura do Repositório
```
wavelet_coherence_omni/
├── dados_Omni_Tratados.txt       # Arquivo de entrada com dados OMNI
├── wavelet_coherence_omni.m      # Script MATLAB principal
└── README.md                     # Documentação do projeto
```
## 📊 Exemplo de Resultados

Abaixo seguem exemplos ilustrativos das figuras de coerência entre alguns pares de parâmetros:

<div align="center">
  <h4><strong>Figura 1: Coerência Wavelet — Bz × Velocidade Solar</strong></h4>
  <img src="images/image_bz_vsw.png" alt="Bz x Vsw" style="width:80%; max-width:900px;">
</div>

<br>

<div align="center">
  <h4><strong>Figura 2: Coerência Wavelet — Densidade × Ey</strong></h4>
  <img src="images/image_density_ey.png" alt="Density x Ey" style="width:80%; max-width:900px;">
</div>

<br>

<div align="center">
  <h4><strong>Figura 3: Coerência Wavelet — AE × SYM/H</strong></h4>
  <img src="images/image_ae_symh.png" alt="AE x SYM/H" style="width:80%; max-width:900px;">
</div>

## 🤝 Agradecimentos

Este projeto auxilia pesquisadores em Física Espacial e Geomagnetismo na análise de relações dinâmicas entre parâmetros solares e magnetosféricos, oferecendo uma ferramenta robusta de análise espectral temporal cruzada.

## 📜 Licença

Este projeto está licenciado sob a MIT License. Consulte o arquivo LICENSE para mais detalhes.
