

% --- Configuration ---
projectDir = '/Users/eebiggs/Documents/PROJECTS/ReactExt_MRI/2. Data/MRI/CONN analysis/conn_ReactExtMRI/results/firstlevel/gPPI_01/';
subjects = 1:29;
conditions = 6:17;
numROIs = 6;
% 30 directional connections (6*6 - 6 diagonal)
numConnections = numROIs * numROIs - numROIs; 

overview = struct();

for c_idx = 1:length(conditions)
    cond = conditions(c_idx);
    condFieldName = sprintf('Condition%03d', cond);
    
    % Matrix: 29 Subjects x 30 Connections
    subjData = zeros(length(subjects), numConnections);
    
    for s_idx = 1:length(subjects)
        sub = subjects(s_idx);
        filename = fullfile(projectDir, sprintf('resultsROI_Subject%03d_Condition%03d.mat', sub, cond));
        
        if isfile(filename)
            data = load(filename);
            
            % Extract the 6x6 regression coefficient matrix
            Z_matrix = data.Z(1:numROIs, 1:numROIs);
            
            % Remove diagonal elements and flatten
            % We create a mask for all elements EXCEPT the diagonal
            mask = ~eye(numROIs); 
            
            % Extracting via the mask flattens the matrix column-wise:
            % (Row2,Col1), (Row3,Col1)... (Row1,Col2), (Row3,Col2)...
            directionalValues = Z_matrix(mask);
            
            subjData(s_idx, :) = directionalValues';
        else
            subjData(s_idx, :) = NaN;
        end
    end
    
    overview.(condFieldName) = subjData;
end

% Get names for mapping
if exist('data','var')
    overview.roi_labels = data.names(1:numROIs);
end

disp('Restructuring complete for directional (non-symmetrical) coefficients.');


conns = 1:30;

% EXT
for i = 1:length(conns)
    EXT(:,i) = [   overview.Condition010(:,conns(i)); ...
                    overview.Condition011(:,conns(i)); ...
                    overview.Condition012(:,conns(i)); ...
                    overview.Condition013(:,conns(i)); ...
                    ];
end

% EXTRE
for i = 1:length(conns)
    EXTRE(:,i) = [   overview.Condition006(:,conns(i)); ...
                    overview.Condition007(:,conns(i)); ...
                    overview.Condition008(:,conns(i)); ...
                    overview.Condition009(:,conns(i)); ...
                    ];
end

% REN
for i = 1:length(conns)
    REN(:,i) = [   overview.Condition014(:,conns(i)); ...
                    overview.Condition015(:,conns(i)); ...
                    overview.Condition016(:,conns(i)); ...
                    overview.Condition017(:,conns(i)); ...
                    ];
end