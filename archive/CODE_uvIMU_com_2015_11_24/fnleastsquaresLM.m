
function [x,Reason,Info] = fnleastsquaresLM(nUV, K, x, nPoses, nPts, Jd, ...
    CovMatrixInv, nIMUrate, nIMUdata, ImuTimestamps, dtIMU, RptFeatureObs, ...
    bUVonly, bPreInt, bAddZg, bAddZau2c, bAddZtu2c, bAddZbf,bAddZbw, bVarBias)
%nMaxIter, fLowerbound_ferr, fLowerbound_dx, 
%% Initialize related parameters.
    nMaxIter = 5000;
    v = 2;
    tao = 1e-3;
    ferr1 = 1e-12;
    ferr2 = 1e-20;%50;%100;%1e-12;
    ferr3 = 1e-12;
    ferr4 = 0;
    bStop = 0;
    Reason = 0;
    k = 0;

%% Calculate indices for Jacobians
    [idRow, idCol, nJacs] = fnFndJacobianID(nIMUdata, bUVonly, bPreInt, nPoses, RptFeatureObs, ImuTimestamps);
    if(bUVonly == 1)% UVonly, add Au2c,Tu2c and Z2
        idx_au2c = (nPoses-1)*6+nPts*3;
        uidRow = [1,2,3,1,2,3,1,2,3, ... %Au2c
                  4,5,6,4,5,6,4,5,6, ... %Tu2c
                  7 ... % Z2
                  ];                  
        uidCol = [idx_au2c+1,idx_au2c+1,idx_au2c+1, ... 
                  idx_au2c+2,idx_au2c+2,idx_au2c+2, ... 
                  idx_au2c+3,idx_au2c+3,idx_au2c+3, ... %Au2c
                  idx_au2c+4,idx_au2c+4,idx_au2c+4, ... 
                  idx_au2c+5,idx_au2c+5,idx_au2c+5, ... 
                  idx_au2c+6,idx_au2c+6,idx_au2c+6, ... %Tu2c
                  4 ... %6
                 ]; 
        unJacs = 3*3*2+1; 
    else%if(bPreInt == 1)
        [uidRow, uidCol, unJacs] = fnFndJacIDimu(ImuTimestamps, nIMUdata, bUVonly, nPoses, nPts, bAddZg, ...
            bAddZau2c, bAddZtu2c, bAddZbf, bAddZbw, bVarBias, bPreInt);        
    end

%% Pre-calculate Errors
    [ferr] = fnCnUPredErr_lsqnonlin_general(x);
    chi2 = 2*ferr'*CovMatrixInv*ferr/nUV;
    [maxe, id] = max(abs(ferr));
    fprintf('Iteration 0: chi2=%0.8f, maxE = %f, id=%d ', chi2, maxe, id);

    
%% Pre-check exiting condition 1   
    fErrorPre = chi2;
    %% Calculate Jacobians
    % UV part
    [J] = fnJduvd_CnU_gq(nJacs, idRow, idCol, K, x, nPoses, nPts, nIMUdata, ImuTimestamps, ...
        RptFeatureObs, bUVonly, bPreInt, nUV, bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, ...
        bAddZbw, bVarBias);
    % IMU part
    if((bUVonly == 1) || (bPreInt == 1))
        J((nUV+1):end,:) = fnJddpvphi_IMU_gq(uidRow, uidCol, unJacs, nUV, bUVonly, dtIMU, Jd, nPoses, nPts, x, ...
                bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, bAddZbw, bVarBias);
    else
        J((nUV+1):end,:) = fnJdaw0_IMU_gq(uidRow, uidCol, unJacs, nUV, nPts, x, nIMUrate, nIMUdata, ...
            bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, bAddZbw, bVarBias, nPoses);    
    end    
    % End of calculation of Jacobians
    
%     G = J'*ferr;
    E = -J'*CovMatrixInv*ferr;
    g = max(abs(E));
    if(g <= ferr1)
        bStop = 1;
        Reason = 1;
    end;
    
%     A = J'*J;
    Info = J'*CovMatrixInv*J;
    mu = tao*max(diag(Info));
    [nr,nc] = size(Info);

    while((bStop ~= 1) && (k <= nMaxIter))
        k = k+1;
        P = -1;
        j = 0;
        while((bStop ~= 1) && (P <= 0))% && (j <= nMaxIter)) 
            j = j + 1;
    %         [DeltaP,DeltaF,Sum_Delta] = FuncDeltaLMSBA(A,G,mu,PVector,Feature(:,2),FixVa);
    %         P2 = FuncGetP2(PVector,FixVa);
    %         Info = J'*CovMatrixInv*J;
            muI = speye(nr, nc) * mu;
    %         E = -J'*CovMatrixInv*ferr;
            dx = (Info+muI)\E;
            normdx = sqrt(dx'*dx);%
            normx = sqrt(x'*x);%
            if normdx <=ferr2*(normx+ferr2);
                bStop = 1;
                Reason = 2;
            else
      %           [PVector] = FuncUpdate(PVector,DeltaP,DeltaF);
                xnew = x + dx;
       %          [ferr, Sum_ferr]= FuncDiffSBA(xVector,PVector,Feature,K);
       %          Delta = [DeltaP;DeltaF];
                [ferr] = fnCnUPredErr_lsqnonlin_general(xnew);
                chi2 = 2*ferr'*CovMatrixInv*ferr/nUV;                
                % L(0) - L(dx) = 0.5*dx'*(mu*dx + E);
                P = (fErrorPre-chi2)/(0.5*dx'*(mu*dx + E));
                if P>0;
                    x = xnew;%ferr
                    if sqrt(fErrorPre)-sqrt(chi2)<ferr4*sqrt(fErrorPre);
                        bStop = 1;
                        Reason = 3;
                        continue;
                    end;
                    %% Calculate Jacobians
                    % UV part
                    [J] = fnJduvd_CnU_gq(nJacs, idRow, idCol, K, x, nPoses, nPts, nIMUdata, ImuTimestamps, ...
                        RptFeatureObs, bUVonly, bPreInt, nUV, bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, ...
                        bAddZbw, bVarBias);
                    % IMU part
                    if((bUVonly == 1) || (bPreInt == 1))
                        J((nUV+1):end,:) = fnJddpvphi_IMU_gq(uidRow, uidCol, unJacs, nUV, bUVonly, dtIMU, Jd, nPoses, nPts, x, ...
                                bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, bAddZbw, bVarBias);
                    else
                        J((nUV+1):end,:) = fnJdaw0_IMU_gq(uidRow, uidCol, unJacs, nUV, nPts, x, nIMUrate, nIMUdata, ...
                            bAddZg, bAddZau2c, bAddZtu2c, bAddZbf, bAddZbw, bVarBias, nPoses);    
                    end    
                    % End of calculation of Jacobians
            %         A = J'*J;
            %         G = J'*ferr;
                    Info = J'*CovMatrixInv*J;   
                    E = -J'*CovMatrixInv*ferr;
                    
                    g = max(abs(E));
                    if bStop ==1 || g<=ferr1;
                        bStop = 1;
                        Reason = 1;
                        continue;
                    end;
                    mu = mu*max(1/3,1-(2*P-1)^3);
                    v = 2;
                else    
           %          DeltaP = -DeltaP;
           %          DeltaF = -DeltaF;
           %          [PVector] = FuncUpdate(PVector,DeltaP,DeltaF);
                    mu = v*mu;
                    v = v*2;
                end;
            end;
        end;
        if sqrt(chi2)<=ferr3;
            bStop = 1;
            Reason = 4;
        end;
        if P>0;
    %      Sum_ferr2 = Sum_ferr/nUV;Sum_ferr2 Sum_ferr
            [me, id] = max(abs(ferr));
            fprintf('\nIteration %d: chi2=%.8f, maxE = %f, id=%d \t', k, chi2, me, id);
            fErrorPre = chi2;
        end;
    end;
        
    Info = sparse([]);
    if k>0;
        Info = J'*CovMatrixInv*J;%Info = J'*J;
    end;
    
    Reason
