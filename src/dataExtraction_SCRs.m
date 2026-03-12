%% Calculate SCRs and plot (edited for ReactExt_Beh)
% 1) Convert .acq files to .mat
% 2) Preprocess data (reformat and filter)
% 3) Format for Ledalab
% 4) Batch process with Ledalab (deconvolution analysis)
% 5) Combine output
% 6) Z-transform and calculate averages
% 7) Plot data

%% first convert .acq files to .mat files (run acq2mat)
% addpath('/Users/emmabiggs/Documents/ERC_PROJECT - ReactExt_Beh/2. Data/1. Raw/load_acq')
% cd '/Users/emmabiggs/Desktop/SkinData/Raw/'
% acq2mat

%% preprocess data
outputFolder = '/Volumes/ReactExtMRI/SkinData/Preprocessed/';
dataFolder = '/Volumes/ReactExtMRI/SkinData/Raw/';
fileList = dir([dataFolder '*.mat']);

for currFile = 1:length(fileList)
    
filename = fileList(currFile).name;
load(filename,'data')

origData(:,1) = data(:,1); %skin
origData(:,2) = data(:,2); %cs+r
origData(:,3) = data(:,3); %cs+nr
origData(:,4) = data(:,4); %cs+acq
origData(:,5) = data(:,5); %cs-
origData(:,6) = data(:,6); %US

clear data

% filter
tmp = origData(:,1);
plot(origData(:,1))
hold on

Fs      = 1000;    % Sampling Frequency
N       = 1;       % Order
Fc      = 5;       % Cutoff Frequency
[b,a]   = butter(N,Fc/(Fs/2),'low');
tmp     = filter(b,a,tmp);

plot(tmp)
savefig([outputFolder filename '_filter.fig'])
close all

origData(:,1) = tmp;
clear tmp Fs N Fc b a

origData = origData(100:end,:); % cut out dip induced by filter

save([outputFolder filename '_1000Hz_filter5Hz.mat'],'origData');

disp(['Finished: ' filename])
clear filename origData

end

%% Format files for Ledalab

currDirectory = '/Volumes/ReactExtMRI/SkinData/Preprocessed/';

files = dir([currDirectory 'P*.mat']);
for i = 1:length(files)
    load([currDirectory files(i).name]);

    data(:,1) = [1:length(origData(:,1))]/1000;
    data(:,2) = origData(:,1);

    tmp = zeros([length(data(:,1)),4]);
    tmp((diff(origData(:,2)) > 3),1) = 1; % CS+r
    tmp((diff(origData(:,3)) > 3),2) = 2; % CS+nr
    tmp((diff(origData(:,4)) > 3),3) = 3; % CS+acq
    tmp((diff(origData(:,5)) > 3),4) = 4; % CS-
    tmp((diff(origData(:,6)) > 3),5) = 5; % US

    data(:,3) = sum(tmp,2);

    filename = textscan(files(i).name,'%s%*s%*s','Delimiter','.');
    filename = filename{1}{1};
    newFilename = [currDirectory '/FIR/' filename '_1000Hz_filter1Hz.txt'];
    save(newFilename,'data','-ascii');
    newFilename = [currDirectory '/TIR/' filename '_1000Hz_filter1Hz.txt'];
    save(newFilename,'data','-ascii');
    disp(['Complete: ' filename])

    clear newFilename filename currFile data tmp

end

%% Run Ledalab batch process

% FIR
addpath('/Users/emmabiggs/Documents/MATLAB/ledalab-349/');

dataPath            = '/Volumes/ReactExtMRI/SkinData/Preprocessed/FIR/';
downsampleFactor    = 100;  % downsample from 1000Hz to 10Hz
startWindow         = 1;    % start of response window in seconds
endWindow           = 6;    % end of response window in seconds
threshold           = 0.01; % minimum response size (micro S)
output              = 1;    % output as matlab file

Ledalab(...
    dataPath,'open','text',...
    'downsample',downsampleFactor,...
    'smooth',{'adapt'},...
    'analyze','CDA','optimize',2,...
    'export_era',[startWindow endWindow threshold output]);

% TIR
addpath('/Users/emmabiggs/Documents/MATLAB/ledalab-349/');

dataPath            = '/Volumes/ReactExtMRI/SkinData/Preprocessed/TIR/';
downsampleFactor    = 100;  % downsample from 1000Hz to 10Hz
startWindow         = 7;    % start of response window in seconds
endWindow           = 11;    % end of response window in seconds
threshold           = 0.01; % minimum response size (micro S)
output              = 1;    % output as matlab file

Ledalab(...
    dataPath,'open','text',...
    'downsample',downsampleFactor,...
    'smooth',{'adapt'},...
    'analyze','CDA','optimize',2,...
    'export_era',[startWindow endWindow threshold output]);

%% Restructure Ledalab output file

outputDirectory = '/Volumes/ReactExtMRI/SkinData/Overview/';
currDirectory = '/Volumes/ReactExtMRI/SkinData/Preprocessed/';
respPhase = {'FIR','TIR'};

for currResp = 1:length(respPhase)

    cd([currDirectory respPhase{currResp} '/'])
    
    avSCR = [];
    blockName = {'Acq','React','Ext','R1','R2'};

    % Loop through each block
    for block = 1:length(blockName)
        % list files for that phase
        fileList = dir(['P*_' blockName{block} '_*_era.mat']);
        % loop through each participant
        for i = 1:length(fileList)
            % import data
            load(fileList(i).name)
            pID = textscan(fileList(i).name,'%s%*s%*s%*s%*s','Delimiter','_');
            pID = str2double(strrep(pID{1}{1},'p',''));

            % if SCR==0 then set phasic response to NaN for missing values
            results.CDA.SCR(results.CDA.SCR==0) = NaN;

            % copy phasic response to avSCR
            try
                avSCR.Phase{block}.CSplusR(pID,:) = results.CDA.SCR(results.Event.nid==1);
                avSCR.Phase{block}.CSplusNR(pID,:) = results.CDA.SCR(results.Event.nid==2);
                avSCR.Phase{block}.CSplusACQ(pID,:) = results.CDA.SCR(results.Event.nid==3);
                avSCR.Phase{block}.CSminus(pID,:) = results.CDA.SCR(results.Event.nid==4);
                avSCR.Phase{block}.US(pID,:) = results.CDA.SCR(results.Event.nid==5);
            catch
                continue
            end

            clear pID results

        end

        clear fileList i

    end

    save([outputDirectory 'SCR_overview_' respPhase{currResp} '.mat'], 'avSCR');

end

%% Z-transform data

outputDirectory = '/Volumes/ReactExtMRI/SkinData/Overview/';
respPhase = {'FIR','TIR'};

for currResp = 1:length(respPhase)

    load([outputDirectory 'SCR_overview_' respPhase{currResp} '.mat'])

    % Calculate mean & SD for acquisition phase
    if currResp == 1 % FIR
        tmp = [avSCR.Phase{1}.CSplusR, avSCR.Phase{1}.CSplusNR, avSCR.Phase{1}.CSminus];
    elseif currResp == 2 % TIR
        tmp = [avSCR.Phase{1}.CSminus];
    end
    acqMean = nanmean(tmp,2);
    acqSD = std(tmp,0,2,'omitnan');
    clear tmp

    % Standardize each phase & exclude outliers(?)
    for block = 1:5
        try
            avSCR_zscore.Phase{block}.CSplusR = (avSCR.Phase{block}.CSplusR - acqMean)./acqSD;
%             avSCR_zscore.Phase{block}.CSplusR(avSCR_zscore.Phase{block}.CSplusR > 3 | avSCR_zscore.Phase{block}.CSplusR < -3) = NaN;
            avSCR_zscore.Phase{block}.CSplusNR = (avSCR.Phase{block}.CSplusNR - acqMean)./acqSD;
%             avSCR_zscore.Phase{block}.CSplusNR(avSCR_zscore.Phase{block}.CSplusNR > 3 | avSCR_zscore.Phase{block}.CSplusNR < -3) = NaN;
            avSCR_zscore.Phase{block}.CSplusACQ = (avSCR.Phase{block}.CSplusACQ - acqMean)./acqSD;
%             avSCR_zscore.Phase{block}.CSplusACQ(avSCR_zscore.Phase{block}.CSplusACQ > 3 | avSCR_zscore.Phase{block}.CSplusACQ < -3) = NaN;
            avSCR_zscore.Phase{block}.CSminus = (avSCR.Phase{block}.CSminus - acqMean)./acqSD;
%             avSCR_zscore.Phase{block}.CSminus(avSCR_zscore.Phase{block}.CSminus > 3 | avSCR_zscore.Phase{block}.CSminus < -3) = NaN;
        catch
            continue
        end
    end

    save([outputDirectory 'SCR_overview_' respPhase{currResp} '_zTransformed.mat'], 'avSCR_zscore');

end

%% Plot group average
file = uigetfile('*.mat');
data = load(file);
tmp = fieldnames(data);
data = data.(tmp{1});
clear tmp
figure('Name',['SCRs from: ' file])

titles = {'ACQ','REACT','EXT','EXT-RE','REN'};

for currPhase = 1:5
    subplot(1,5,currPhase)
    title(titles{currPhase})
    hold on
    
    x = 1:size(data.Phase{currPhase}.CSplusR,2);
    
    % plot CSplusR
    yCSplusR = nanmean(data.Phase{currPhase}.CSplusR,1);
    ueCSplusR = yCSplusR + (std(data.Phase{currPhase}.CSplusR,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSplusR),1)));
    leCSplusR = yCSplusR - (std(data.Phase{currPhase}.CSplusR,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSplusR),1)));
    
    line_CSplusR = plot(x,yCSplusR,'-sb');
    patch([x,flip(x)],[leCSplusR,flip(ueCSplusR)],'b','facealpha',0.1,'edgecolor','none');
    
    % plot CSplusNR & CSminus
    if currPhase ~= 2
        yCSplusNR = nanmean(data.Phase{currPhase}.CSplusNR,1);
        ueCSplusNR = yCSplusNR + (std(data.Phase{currPhase}.CSplusNR,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSplusNR),1)));
        leCSplusNR = yCSplusNR - (std(data.Phase{currPhase}.CSplusNR,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSplusNR),1)));
    
        yCSminus = nanmean(data.Phase{currPhase}.CSminus,1);
        ueCSminus = yCSminus + (std(data.Phase{currPhase}.CSminus,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSminus),1)));
        leCSminus = yCSminus - (std(data.Phase{currPhase}.CSminus,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSminus),1)));
    
        line_CSplusNR = plot(x,yCSplusNR,'-sg');
        patch([x,flip(x)],[leCSplusNR,flip(ueCSplusNR)],'g','facealpha',0.1,'edgecolor','none');
        line_CSminus = plot(x,yCSminus,'-sr');
        patch([x,flip(x)],[leCSminus,flip(ueCSminus)],'r','facealpha',0.1,'edgecolor','none');
    end
    
    % plot CSplusACQ
    if currPhase > 2
        yCSplusACQ = nanmean(data.Phase{currPhase}.CSplusACQ,1);
        ueCSplusACQ = yCSplusACQ + (std(data.Phase{currPhase}.CSplusACQ,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSplusACQ),1)));
        leCSplusACQ = yCSplusACQ - (std(data.Phase{currPhase}.CSplusACQ,0,1,'omitnan')/sqrt(sum(isnan(data.Phase{currPhase}.CSplusACQ),1)));
    
        line_CSplusACQ = plot(x,yCSplusACQ,'-sy');
        patch([x,flip(x)],[leCSplusACQ,flip(ueCSplusACQ)],'y','facealpha',0.1,'edgecolor','none');
    end
    
    ylim([-2 2])
    xlim([0 (size(data.Phase{currPhase}.CSplusR,2) + 1)])
    if currPhase == 1
        ylabel('SCR (z-transformed)')
    elseif currPhase == 5
        legend([line_CSplusR, line_CSplusNR, line_CSminus, line_CSplusACQ],{'CSplusR','CSplusNR','CSminus','CSplusACQ'})
    end
    
end
