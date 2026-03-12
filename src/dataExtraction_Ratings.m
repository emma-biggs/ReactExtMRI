%% Import and plot US-expectancy rating (edited for ReactExt_Beh)

%% Import raw data and restructure

% Specify directories
RawDataDirectory = '/Volumes/ReactExtMRI/PsychoPy_files/data/';
OutputDataDirectory = '/Volumes/ReactExtMRI/Ratings/';

% import data for all phases
phases = {'a','r','e','r1','r2'};

% one overview structure for output
allRatings.CSplusR      = NaN([60 5]);
allRatings.CSplusNR     = NaN([60 5]);
allRatings.CSplusACQ    = NaN([60 5]);
allRatings.CSminus      = NaN([60 5]);

% Loop through each folder
cd(RawDataDirectory)
folders = dir('p0*');
for n = 1:length(folders) % update to total number of participants
    cd([RawDataDirectory folders(n).name '/'])
    
    % Loop through each phase
    for currPhase = 1:5
        % Import the rating file
        currFile = dir(['Ratings_*_' phases{currPhase} '_*.txt']);
        if isempty(currFile)
            continue
        end
        fid = fopen(currFile(1).name);
        % Import the ratings
        currRatings = textscan(fid,'%s%s','Delimiter','\t');
        currRatings = str2double(currRatings{2});
        % Find participant ID number from filename
        pID = textscan(currFile(1).name,'%*s%s%*s%*s%*s%*s%*s%*s','Delimiter','_');
        pID = pID{1}{1};
        pIDnum = str2double(strip(pID,'p'));
        
        % headers: CSplusR, CSplusNR, CSplusACQ, CSminus
        allRatings.CSplusR(pIDnum,currPhase)   = currRatings(1);
        allRatings.CSplusNR(pIDnum,currPhase)  = currRatings(2);
        allRatings.CSplusACQ(pIDnum,currPhase) = currRatings(3);
        allRatings.CSminus(pIDnum,currPhase)   = currRatings(4);
        
        if currPhase == 1
            diffCSplusRCSminus = currRatings(1) - currRatings(4);
            diffCSplusNRCSminus = currRatings(2) - currRatings(4);
            if diffCSplusRCSminus && diffCSplusNRCSminus > 0
                disp(['pID: ' pID ' include! CS+r vs. CS- = ' int2str(diffCSplusRCSminus) '; CS+nr vs. CS- = ' int2str(diffCSplusNRCSminus)])
            else
                disp(['pID: ' pID ' EXCLUDE! CS+r vs. CS- = ' int2str(diffCSplusRCSminus) '; CS+nr vs. CS- = ' int2str(diffCSplusNRCSminus)])
            end
        end
        
        clear currRatings
        
    end
end

save([OutputDataDirectory 'AllRatings.mat'],'allRatings')

%% Calculate means and SEs data
OutputDataDirectory = '/Users/emmabiggs/Documents/ERC_PROJECT - ReactExt_Beh/2. Data/2. Preprocessed/Ratings/';
cd(OutputDataDirectory)
load('AllRatings.mat')

% Fix locations on X axis
x_CSplusR   = [1,5,7,12,17];
x_CSplusNR  = [2,8,13,18];
x_CSminus   = [3,9,14,19];
x_CSplusACQ = [10,15,20];

% Calculate means
y_CSplusR   = nanmean(allRatings.CSplusR);
y_CSplusNR  = nanmean(allRatings.CSplusNR);
y_CSplusACQ = nanmean(allRatings.CSplusACQ);
y_CSminus   = nanmean(allRatings.CSminus);

% Calculate SEs
se_CSplusR      = (std(allRatings.CSplusR,0,1,'omitnan'))./sqrt(sum(isnan(allRatings.CSplusR)==0,1));
se_CSplusNR     = (std(allRatings.CSplusNR,0,1,'omitnan'))./sqrt(sum(isnan(allRatings.CSplusNR)==0,1));
se_CSplusACQ    = (std(allRatings.CSplusACQ,0,1,'omitnan'))./sqrt(sum(isnan(allRatings.CSplusACQ)==0,1));
se_CSminus      = (std(allRatings.CSminus,0,1,'omitnan'))./sqrt(sum(isnan(allRatings.CSminus)==0,1));

tmp_y = [y_CSplusR;y_CSplusNR;y_CSminus;y_CSplusACQ];
tmp_se = [se_CSplusR;se_CSplusNR;se_CSminus;se_CSplusACQ];
%% Plot figure
figure('Name','US-expectancy ratings')

% plot bar chart
line_CSplusR    = bar(x_CSplusR,y_CSplusR,'b');
hold on
line_CSplusNR   = bar(x_CSplusNR,y_CSplusNR([1,3,4,5]),'g');
line_CSminus    = bar(x_CSminus,y_CSminus([1,3,4,5]),'r');
line_CSplusACQ  = bar(x_CSplusACQ,y_CSplusACQ([3,4,5]),'y');

% % plot error bars
% errorbar(x_CSplusR,y_CSplusR,se_CSplusR)
% errorbar(x_CSplusR,y_CSplusR,se_CSplusR)
% errorbar(x_CSplusR,y_CSplusR,se_CSplusR)
% errorbar(x_CSplusR,y_CSplusR,se_CSplusR)

% plot options
legend([line_CSplusR,line_CSplusNR,line_CSminus,line_CSplusACQ],{'CS+r','CS+nr','CS-','CS+acq'})
title('US expectancy ratings')

