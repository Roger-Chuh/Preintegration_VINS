function [idRow, idCol, nJacs] = fnFndJacIDimu(ImuTimestamps, nIMUdata, bUVonly, ...
    nPoses, nPts, bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, bAddZbw, ...
    bVarBias, bPreInt)

%% Find Jacobian for dp, dv and dphi
%% 1. dp = Ru1 * (Tu2-Tu1-v1*dt-0.5*g*dt*dt) - ddpdbf*dbf - ddpdbw*dbw;
%% 2. dv = Ru1 * (v2-v1-g*dt) - ddvdbf*dbf - ddvdbw*dbw;
%% [a,b,g] = fnABG5R(Ru2*(Ru1)');
%% 3. dphi = [a;b;g] - ddphidbw*dbw;
% K: camera model
% p3d0: 3D points at the first camera pose
% x: current estimate of the states (alpha, beta, gamma, T)

idRow = [];
idCol = [];
nJacs = 0;

if(bPreInt == 1)
    idVbase = 6*(nPoses-1)+3*nPts;
    idGbase = 6*(nPoses-1)+3*nPts+3*nPoses;
    idAu2cbase = 6*(nPoses-1)+3*nPts+3*nPoses+3;
    idBfbase0 = 6*(nPoses-1)+3*nPts+3*nPoses+3*3;
else
    idVbase = 6*nIMUdata+3*nPts;
    idGbase = idVbase + 3*(nIMUdata+1);
    idAu2cbase = idGbase + 3;
    idBfbase0 = idGbase + 3*3;
end

if(bUVonly == 0)
    idBfbase = idBfbase0;
    if(bPreInt == 1)
        for(pid=2:nPoses) 
            if(bVarBias == 1)
                idBfbase = idBfbase0 + 6*(pid-2);
            end            
            if(pid > 2)            
                idRow = [idRow,...%% 1. dp = Ru1 * (Tu2-Tu1-v1*dt-0.5*g*dt*dt) - ddpdbf*dbf - ddpdbw*dbw        
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% a
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,... % b
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% g --Ru1 
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% Tu1
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% Tu2
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% v1
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% g
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% bf
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% bw %% 2. dv = Ru1 * (v2-v1-g*dt) - ddvdbf*dbf - ddvdbw*dbw;        
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% Ru1
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% v1
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% v2
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% g
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,....% bf
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% bw  %% 3. dphi = [a;b;g] - ddphidbw*dbw; [a,b,g] = fnABG5R(Ru2*(Ru1)');       
                    9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...% Ru1
                    9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...% Ru2
                    9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9 % bw
                    ];
                idCol = [idCol, ... %% 1. dp = Ru1 * (Tu2-Tu1-v1*dt-0.5*g*dt*dt) - ddpdbf*dbf - ddpdbw*dbw                   
                     6*(pid-3)+1, 6*(pid-3)+1, 6*(pid-3)+1,...
                        6*(pid-3)+2, 6*(pid-3)+2, 6*(pid-3)+2, ...
                        6*(pid-3)+3, 6*(pid-3)+3, 6*(pid-3)+3,...% Ru1 
                     6*(pid-3)+4, 6*(pid-3)+4, 6*(pid-3)+4, ...
                        6*(pid-3)+5, 6*(pid-3)+5, 6*(pid-3)+5,...
                        6*(pid-3)+6, 6*(pid-3)+6, 6*(pid-3)+6,...% Tu1
                     6*(pid-2)+4, 6*(pid-2)+4, 6*(pid-2)+4, ...
                        6*(pid-2)+5, 6*(pid-2)+5, 6*(pid-2)+5, ...
                        6*(pid-2)+6, 6*(pid-2)+6, 6*(pid-2)+6, ...% Tu2
                     idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,...
                        idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,...
                        idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,...%v1
                     idGbase+1,idGbase+1,idGbase+1,...
                        idGbase+2,idGbase+2,idGbase+2,...
                        idGbase+3,idGbase+3,idGbase+3,...% g   
                     idBfbase+1,idBfbase+1,idBfbase+1,...
                        idBfbase+2,idBfbase+2,idBfbase+2,...
                        idBfbase+3,idBfbase+3,idBfbase+3,...% bf
                     idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6,...% bw   %% 2. dv = Ru1 * (v2-v1-g*dt) - ddvdbf*dbf - ddvdbw*dbw;      
                     6*(pid-3)+1, 6*(pid-3)+1, 6*(pid-3)+1,...
                        6*(pid-3)+2, 6*(pid-3)+2, 6*(pid-3)+2, ...
                        6*(pid-3)+3, 6*(pid-3)+3, 6*(pid-3)+3,...% Ru1 
                     idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,...
                        idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,...
                        idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,...%v1
                     idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,...
                        idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,...
                        idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,...%v2
                     idGbase+1,idGbase+1,idGbase+1,...
                        idGbase+2,idGbase+2,idGbase+2,...
                        idGbase+3,idGbase+3,idGbase+3,...% g   
                     idBfbase+1,idBfbase+1,idBfbase+1,...
                        idBfbase+2,idBfbase+2,idBfbase+2,...
                        idBfbase+3,idBfbase+3,idBfbase+3,...% bf
                     idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6,...% bw %% 3. dphi = [a;b;g] - ddphidbw*dbw; [a,b,g] = fnABG5R(Ru2*(Ru1)');       
                     6*(pid-3)+1, 6*(pid-3)+1, 6*(pid-3)+1,...
                        6*(pid-3)+2, 6*(pid-3)+2, 6*(pid-3)+2, ...
                        6*(pid-3)+3, 6*(pid-3)+3, 6*(pid-3)+3,...% Ru1
                     6*(pid-2)+1, 6*(pid-2)+1, 6*(pid-2)+1,...
                        6*(pid-2)+2, 6*(pid-2)+2, 6*(pid-2)+2, ...
                        6*(pid-2)+3, 6*(pid-2)+3, 6*(pid-2)+3,...% Ru2                    
                     idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6 % bw                    
                    ];
                nJacs = nJacs + 3*3*(7 + 6 + 3);
            else
                idRow = [idRow,... %% 1. dp = Ru1 * (Tu2-Tu1-v1*dt-0.5*g*dt*dt) - ddpdbf*dbf - ddpdbw*dbw       
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% Tu2
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% v1
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% g
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% bf
                     9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...
                        9*(pid-2)+1, 9*(pid-2)+2, 9*(pid-2)+3,...% bw %% 2. dv = Ru1 * (v2-v1-g*dt) - ddvdbf*dbf - ddvdbw*dbw;
                     9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% v1
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% v2
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% g
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,....% bf
                    9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...
                        9*(pid-2)+4, 9*(pid-2)+5, 9*(pid-2)+6,...% bw  %% 3. dphi = [a;b;g] - ddphidbw*dbw; [a,b,g] = fnABG5R(Ru2*(Ru1)');
                    9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...% Ru2
                    9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9,...
                        9*(pid-2)+7, 9*(pid-2)+8, 9*(pid-2)+9 % bw
                    ];
                idCol = [idCol, ...%% 1. dp = Ru1 * (Tu2-Tu1-v1*dt-0.5*g*dt*dt) - ddpdbf*dbf - ddpdbw*dbw                    
                        6*(pid-2)+4, 6*(pid-2)+4, 6*(pid-2)+4, ...
                        6*(pid-2)+5, 6*(pid-2)+5, 6*(pid-2)+5, ...
                        6*(pid-2)+6, 6*(pid-2)+6, 6*(pid-2)+6, ...% Tu2
                        idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,...
                        idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,...
                        idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,...%v1
                        idGbase+1,idGbase+1,idGbase+1,...
                        idGbase+2,idGbase+2,idGbase+2,...
                        idGbase+3,idGbase+3,idGbase+3,...% g   
                        idBfbase+1,idBfbase+1,idBfbase+1,...
                        idBfbase+2,idBfbase+2,idBfbase+2,...
                        idBfbase+3,idBfbase+3,idBfbase+3,...% bf
                        idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6,...% bw  %% 2. dv = Ru1 * (v2-v1-g*dt) - ddvdbf*dbf - ddvdbw*dbw;        
                        idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,idVbase+3*(pid-2)+1,...
                        idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,idVbase+3*(pid-2)+2,...
                        idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,idVbase+3*(pid-2)+3,...%v1
                        idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,...
                        idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,...
                        idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,...%v2
                        idGbase+1,idGbase+1,idGbase+1,...
                        idGbase+2,idGbase+2,idGbase+2,...
                        idGbase+3,idGbase+3,idGbase+3,...% g   
                        idBfbase+1,idBfbase+1,idBfbase+1,...
                        idBfbase+2,idBfbase+2,idBfbase+2,...
                        idBfbase+3,idBfbase+3,idBfbase+3,...% bf
                        idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6,...% bw %% 3. dphi = [a;b;g] - ddphidbw*dbw; [a,b,g] = fnABG5R(Ru2*(Ru1)');
                        6*(pid-2)+1, 6*(pid-2)+1, 6*(pid-2)+1,...
                        6*(pid-2)+2, 6*(pid-2)+2, 6*(pid-2)+2, ...
                        6*(pid-2)+3, 6*(pid-2)+3, 6*(pid-2)+3,...% Ru2                    
                        idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6 % bw                    
                    ];
                nJacs = nJacs + 3*3*(5 + 5 + 2);            
            end
        end
    else%bPreInt == 0 case
        cid = 1;
        for(pid=1:nIMUdata)   
            if(bVarBias == 1)
               if(pid >= (ImuTimestamps(cid+1)-ImuTimestamps(1)+1)) 
                    cid = cid + 1;
                    idBfbase = idBfbase0 + 6*(cid-1);
               end
            end
            if(pid > 1)            
                idRow = [idRow,...%% 1. wi = Ei*(phii1-phii)/dt+bw;        
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...  
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...% phii 
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...% phii1
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...% bw %% 2. ai = Ri*((vi1-vi)/dt-g)-bf;       
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% phii
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% vi
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% vi1
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% g
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% bf  %% 3. bzero = Ti1-Ti-vi*dt;       
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...% Ti
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...% Ti1
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9    % vi
                    ];
                idCol = [idCol, ... %% 1. wi = Ei*(phii1-phii)/dt+bw;                   
                        6*(pid-2)+1, 6*(pid-2)+1, 6*(pid-2)+1,...
                        6*(pid-2)+2, 6*(pid-2)+2, 6*(pid-2)+2, ...
                        6*(pid-2)+3, 6*(pid-2)+3, 6*(pid-2)+3,...% phii 
                        6*(pid-1)+1, 6*(pid-1)+1, 6*(pid-1)+1, ...
                        6*(pid-1)+2, 6*(pid-1)+2, 6*(pid-1)+2,...
                        6*(pid-1)+3, 6*(pid-1)+3, 6*(pid-1)+3,...% phii1
                        idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6,...     % bw  %% 2. ai = Ri*((vi1-vi)/dt-g)-bf;      
                        6*(pid-2)+1, 6*(pid-2)+1, 6*(pid-2)+1,...
                        6*(pid-2)+2, 6*(pid-2)+2, 6*(pid-2)+2, ...
                        6*(pid-2)+3, 6*(pid-2)+3, 6*(pid-2)+3,...% phii
                        idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,...
                        idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,...
                        idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,...%vi
                        idVbase+3*(pid)+1,idVbase+3*(pid)+1,idVbase+3*(pid)+1,...
                        idVbase+3*(pid)+2,idVbase+3*(pid)+2,idVbase+3*(pid)+2,...
                        idVbase+3*(pid)+3,idVbase+3*(pid)+3,idVbase+3*(pid)+3,...%vi1
                        idGbase+1,idGbase+1,idGbase+1,...
                        idGbase+2,idGbase+2,idGbase+2,...
                        idGbase+3,idGbase+3,idGbase+3,...% g   
                        idBfbase+1,idBfbase+1,idBfbase+1,...
                        idBfbase+2,idBfbase+2,idBfbase+2,...
                        idBfbase+3,idBfbase+3,idBfbase+3,...% bf %% 3. bzero = Ti1-Ti-vi*dt;       
                        6*(pid-2)+4, 6*(pid-2)+4, 6*(pid-2)+4,...
                        6*(pid-2)+5, 6*(pid-2)+5, 6*(pid-2)+5, ...
                        6*(pid-2)+6, 6*(pid-2)+6, 6*(pid-2)+6,...% Ti
                        6*(pid-1)+4, 6*(pid-1)+4, 6*(pid-1)+4,...
                        6*(pid-1)+5, 6*(pid-1)+5, 6*(pid-1)+5, ...
                        6*(pid-1)+6, 6*(pid-1)+6, 6*(pid-1)+6,...% Ti1                    
                        idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,...
                        idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,...
                        idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3 %vi                    
                    ];
                nJacs = nJacs + 3*3*(3 + 5 + 3);
            else
                idRow = [idRow,... %% 1. wi = Ei*(phii1-phii)/dt+bw;        
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...% phii1
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...
                        9*(pid-1)+1, 9*(pid-1)+2, 9*(pid-1)+3,...% bw %% 2. ai = Ri*((vi1-vi)/dt-g)-bf;       
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% vi
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% vi1
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% g
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...
                        9*(pid-1)+4, 9*(pid-1)+5, 9*(pid-1)+6,...% bf  %% 3. bzero = Ti1-Ti-vi*dt;       
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...% Ti1
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9,...
                        9*(pid-1)+7, 9*(pid-1)+8, 9*(pid-1)+9    % vi
                    ];
                idCol = [idCol, ...%% 1. wi = Ei*(phii1-phii)/dt+bw;                    
                        6*(pid-1)+1, 6*(pid-1)+1, 6*(pid-1)+1, ...
                        6*(pid-1)+2, 6*(pid-1)+2, 6*(pid-1)+2,...
                        6*(pid-1)+3, 6*(pid-1)+3, 6*(pid-1)+3,...% phii1
                        idBfbase+4,idBfbase+4,idBfbase+4,...
                        idBfbase+5,idBfbase+5,idBfbase+5,...
                        idBfbase+6,idBfbase+6,idBfbase+6,...     % bw   %% 2. ai = Ri*((vi1-vi)/dt-g)-bf;      
                        idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,...
                        idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,...
                        idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,...%vi
                        idVbase+3*(pid)+1,idVbase+3*(pid)+1,idVbase+3*(pid)+1,...
                        idVbase+3*(pid)+2,idVbase+3*(pid)+2,idVbase+3*(pid)+2,...
                        idVbase+3*(pid)+3,idVbase+3*(pid)+3,idVbase+3*(pid)+3,...%vi1
                        idGbase+1,idGbase+1,idGbase+1,...
                        idGbase+2,idGbase+2,idGbase+2,...
                        idGbase+3,idGbase+3,idGbase+3,...% g   
                        idBfbase+1,idBfbase+1,idBfbase+1,...
                        idBfbase+2,idBfbase+2,idBfbase+2,...
                        idBfbase+3,idBfbase+3,idBfbase+3,...% bf %% 3. bzero = Ti1-Ti-vi*dt;       
                        6*(pid-1)+4, 6*(pid-1)+4, 6*(pid-1)+4,...
                        6*(pid-1)+5, 6*(pid-1)+5, 6*(pid-1)+5, ...
                        6*(pid-1)+6, 6*(pid-1)+6, 6*(pid-1)+6,...% Ti1                    
                        idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,idVbase+3*(pid-1)+1,...
                        idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,idVbase+3*(pid-1)+2,...
                        idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3,idVbase+3*(pid-1)+3 %vi                  
                    ];
                nJacs = nJacs + 3*3*(2 + 4 + 2);            
            end
        end     
    end
    
    if(bPreInt == 1)
        idZbase = 9*(nPoses - 1);
    else
        idZbase = 9*(nIMUdata);
    end
    
    if(bAddZg == 1)
        idRow = [idRow, idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3        
            ];
        idCol = [idCol, idGbase+1,idGbase+1,idGbase+1,...
                    idGbase+2,idGbase+2,idGbase+2,...
                    idGbase+3,idGbase+3,idGbase+3];
        idZbase = idZbase + 3;
    end
else
  idZbase = 0;  
end

idBfbase = idBfbase0;
if(bAddZau2c == 1)
    idRow = [idRow, idZbase+1, idZbase+2, idZbase+3,...
        idZbase+1, idZbase+2, idZbase+3,...
        idZbase+1, idZbase+2, idZbase+3        
        ];
    idCol = [idCol, idAu2cbase+1,idAu2cbase+1,idAu2cbase+1,...
        idAu2cbase+2,idAu2cbase+2,idAu2cbase+2,...
        idAu2cbase+3,idAu2cbase+3,idAu2cbase+3]; 
    idZbase = idZbase + 3;
end

if(bAddZtu2c == 1)
    idRow = [idRow, idZbase+1, idZbase+2, idZbase+3,...
        idZbase+1, idZbase+2, idZbase+3,...
        idZbase+1, idZbase+2, idZbase+3        
        ];
    idCol = [idCol, idAu2cbase+4,idAu2cbase+4,idAu2cbase+4,...
        idAu2cbase+5,idAu2cbase+5,idAu2cbase+5,...
        idAu2cbase+6,idAu2cbase+6,idAu2cbase+6]; 
    idZbase = idZbase + 3;
end

if(bUVonly == 1)
    %% dz2 %     
    idRow = [idRow, idZbase+1];
    idCol = [idCol, 6];
    idZbase = idZbase + 1;
elseif(bVarBias == 0)
    if(bAddZbf == 1)
        %% dbf % 
        idRow = [idRow, idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3        
            ];
        idCol = [idCol, idBfbase+1,idBfbase+1,idBfbase+1,...
            idBfbase+2,idBfbase+2,idBfbase+2,...
            idBfbase+3,idBfbase+3,idBfbase+3]; 
        idZbase = idZbase + 3;   
    end
    if(bAddZbw == 1)
        %% dbw % 
        idRow = [idRow, idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3        
            ];
        idCol = [idCol, idBfbase+4,idBfbase+4,idBfbase+4,...
            idBfbase+5,idBfbase+5,idBfbase+5,...
            idBfbase+6,idBfbase+6,idBfbase+6]; 
        idZbase = idZbase + 3;     
    end
else
    for(pid=2:(nPoses-1))
        idRow = [idRow, idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...% dbfi
            idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...
            idZbase+1, idZbase+2, idZbase+3,...% dbfi1
            idZbase+4, idZbase+5, idZbase+6,...
            idZbase+4, idZbase+5, idZbase+6,...
            idZbase+4, idZbase+5, idZbase+6,...% dbwi
            idZbase+4, idZbase+5, idZbase+6,...
            idZbase+4, idZbase+5, idZbase+6,...
            idZbase+4, idZbase+5, idZbase+6 % dbw1
            ];
        idCol = [idCol, idBfbase+(pid-2)*6+1,idBfbase+(pid-2)*6+1,idBfbase+(pid-2)*6+1,...
            idBfbase+(pid-2)*6+2,idBfbase+(pid-2)*6+2,idBfbase+(pid-2)*6+2,...
            idBfbase+(pid-2)*6+3,idBfbase+(pid-2)*6+3,idBfbase+(pid-2)*6+3,...%dbfi
            idBfbase+(pid-2)*6+7,idBfbase+(pid-2)*6+7,idBfbase+(pid-2)*6+7,...
            idBfbase+(pid-2)*6+8,idBfbase+(pid-2)*6+8,idBfbase+(pid-2)*6+8,...
            idBfbase+(pid-2)*6+9,idBfbase+(pid-2)*6+9,idBfbase+(pid-2)*6+9,...%dbfi1            
            idBfbase+(pid-2)*6+4,idBfbase+(pid-2)*6+4,idBfbase+(pid-2)*6+4,...
            idBfbase+(pid-2)*6+5,idBfbase+(pid-2)*6+5,idBfbase+(pid-2)*6+5,...
            idBfbase+(pid-2)*6+6,idBfbase+(pid-2)*6+6,idBfbase+(pid-2)*6+6,...%dbwi
            idBfbase+(pid-2)*6+10,idBfbase+(pid-2)*6+10,idBfbase+(pid-2)*6+10,...
            idBfbase+(pid-2)*6+11,idBfbase+(pid-2)*6+11,idBfbase+(pid-2)*6+11,...
            idBfbase+(pid-2)*6+12,idBfbase+(pid-2)*6+12,idBfbase+(pid-2)*6+12    %dbwi1          
            ]; 
        idZbase = idZbase + 6;    
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%
