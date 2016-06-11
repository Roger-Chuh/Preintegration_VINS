function [ FeatureObs, Feature3D ] = Feature_Obs_Define( nPts )
    global PreIntegration_options Data_config

    
    %%%%%%%%%%%%%%
    % camera observations  
    %%%%%%%%%%%%%%
    % Define data structure for camera observation
    Observation_Def = struct( ...
        'pid', [], ...
        'uv',  zeros(1,2) ...
        );
    FeatureInfo_Def = struct( ...
        'fid',  [], ...
        'nObs', 0, ...
        'obsv', Observation_Def ... % array of observations, size will grow
        );
    FeatureObs = repmat( FeatureInfo_Def, nPts, 1); % will expand
    
    %fids = mat2cell( 1:nPts, 1, ones(1, nPts)); 
    fids = num2cell( 1:nPts );
    [FeatureObs(:).fid] = fids{:};        
    
    % Define data structure for Feature3D
    TriangulateInfo_Def = struct( ...
        'pid1', [], ...
        'pid2', [], ...
        'p3D',  zeros(3,1) ...  % 3D co-ordinates (x, y, z)
        );
    Feature3DInfo_Def = struct( ...
        'fid',  [], ...
        'numTriangs', 0, ...
        'triangs', TriangulateInfo_Def ... % is array of triangulates, size will grow
        );
    Feature3D = repmat( Feature3DInfo_Def, nPts, 1); % will expand
    fids = num2cell( 1:nPts );
    [Feature3D(:).fid] = fids{:};        
