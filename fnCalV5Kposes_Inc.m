function [tv,tid] = fnCalV5Kposes_Inc(nPoseNew, nPoseOld, ...
    nPoses, nPts, nIMUdata, ImuTimestamps, nIMUrate, ...
    x, dtIMU, dp, dv, g0, bf0, imufulldata)    
    
    global InertialDelta_options
    
    %idend = 0;
    %tv = zeros(3*(nIMUdata+1), 1);
    tid = 0
    tv = repmat( struct( 'xyz', zeros(3, 1)), 1, 1);
    
    if(InertialDelta_options.bPreInt == 1)   
        if(nPoseOld == 1)
            % The velocity of the first pose.
            %idstart = idend + 1;
            %idend = idend + 3;
            %tv(idstart:idend, 1) = (x(4:6,1)-0.5*dtIMU(2)*dtIMU(2)*g0-dp(:,2))/(dtIMU(2)); 
            tid = tid + 1;
            tv(tid).xyz = (x.pose(1).trans - 0.5*dtIMU(2)*dtIMU(2)*g0 - dp(:,2))/(dtIMU(2));
        end
        
        pid_start = nPoseOld+1;           
        pid_end = nPoseNew-1;
        for(pid=pid_start:pid_end)
          %idstart = idend + 1;
          %idend = idend + 3;
          %Ri = fnR5ABG(x(6*(pid-2)+1),x(6*(pid-2)+2),x(6*(pid-2)+3));
          tid = tid + 1;
          Ri = fnR5ABG( x.pose(pid-1).ang(1), x.pose(pid-1).ang(2), x.pose(pid-1).ang(3) );
          %tv(idstart:idend, 1) = (x((6*(pid-1)+4):(6*(pid-1)+6), 1) - x((6*(pid-2)+4):(6*(pid-2)+6), 1)-0.5*dtIMU(pid+1)...
          %    *dtIMU(pid+1)*g0-Ri'*dp(:,(pid+1)))/(dtIMU(pid+1));%(x(((pid-1)+4):((pid-1)+6)) - x(((pid-2)+4):((pid-2)+6)))/dtIMU(pid);              
          tv(tid).xyz = ( x.pose(pid).trans - x.pose(pid-1).trans - 0.5*dtIMU(pid+1) ...
              *dtIMU(pid+1)*g0 - Ri' * dp(:, (pid+1))) / dtIMU(pid+1);
        end
        % The velocity of the last pose.
        %idstart = idend + 1;
        %idend = idend + 3;
        tid = tid + 1;
        %Ri = fnR5ABG(x(6*(nPoseNew-2)+1),x(6*(nPoseNew-2)+2),x(6*(nPoseNew-2)+3));
        Ri = fnR5ABG( x.pose(nPoseNew-1).ang(1), x.pose(nPoseNew-1).ang(2), x.pose(nPoseNew-1).ang(3));
        if (tid > 1)
        %if(idstart > 3)
            %tv(idstart:idend) = tv((idstart-3):(idend-3), 1)+dtIMU(nPoseNew)*g0...
            %    +Ri'*dv(:,nPoseNew);             
            tv(tid).xyz = tv(tid-1).xyz + dtIMU(nPoseNew) * g0 + Ri' * dv(:,nPoseNew);
        else
           %idx = 6*(nPoseNew-1)+3*nPts+3*(nPoseNew-2);
           %tv(idstart:idend) = x((idx+1):(idx+3), 1)+dtIMU(nPoseNew)*g0...
           %    +Ri'*dv(:,nPoseNew);    
           %tv(nPoseNew).xyz = x((idx+1):(idx+3), 1)+dtIMU(nPoseNew)*g0...
           %    +Ri'*dv(:,nPoseNew);    
           tv(tid).xyz = x.velocity(nPoseNew - 1).xyz + dtIMU(nPoseNew) * g0...
                                + Ri' * dv(:,nPoseNew);    
        end
    else
        dt = 1.0/nIMUrate;
        % The velocity of the first pose.IMUparking6L
        if(bDinuka == 1)
            imufulldata = [imufulldata(:,1), imufulldata(:,5:7), imufulldata(:,2:4)];% ts, fb, wb
        end
        if(nPoseOld == 1)
            idstart = idend + 1;
            idend = idend + 3; 
            tv(idstart:idend, 1) = (x(4:6,1)-0.5*dt*dt*g0-0.5*dt*dt*((imufulldata(ImuTimestamps(1), 2:4))'-bf0))/dt; 
        end
        nIMUdata_Old = ImuTimestamps(nPoseOld) - ImuTimestamps(1)+1;
        pid_start = nIMUdata_Old+1;
        pid_end = nIMUdata;
        for(pid=pid_start:pid_end)
          idstart = idend + 1;
          idend = idend + 3;
          Ri = fnR5ABG(x(6*(pid-2)+1),x(6*(pid-2)+2),x(6*(pid-2)+3));
          tv(idstart:idend, 1) = (x((6*(pid-1)+4):(6*(pid-1)+6), 1) - x((6*(pid-2)+4):(6*(pid-2)+6), 1)-0.5*dt...
              *dt*g0-Ri'*0.5*dt*dt*((imufulldata(ImuTimestamps(1)+pid, 2:4))'-bf0))/dt;%(x(((pid-1)+4):((pid-1)+6)) - x(((pid-2)+4):((pid-2)+6)))/dtIMU(pid);              
        end
        % The velocity of the last pose.
        idstart = idend + 1;
        idend = idend + 3;
        Ri = fnR5ABG(x(6*(nIMUdata-2)+1),x(6*(nIMUdata-2)+2),x(6*(nIMUdata-2)+3));
        tv(idstart:idend) = tv((idstart-3):(idend-3), 1)+dt*g0+Ri'*dt*((imufulldata(ImuTimestamps(1)+nIMUdata, 2:4))'-bf0);            
    end       
    %tv = tv(1:idend);