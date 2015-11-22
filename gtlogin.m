% Vineet Tiruvadi
% vtiruvadi3
% ECE8823 Final Project
% 2010 by Georgia Institute of Technology. All rights reserved.

%% Initialization

% function [h]=gtlogin()
% @return controllers Cel of 6 handles to the 6 controllers used between 
%                     the waypoints
% @return guards Cel of 6 handles to the 6 guards between the waypoints
%
% This function returns handles to the 6 controllers used for clearing each
% of the 6 waypoints.
%
% DO NOT CHANGE THIS FUNCTION!!!
function [controllers,guards]=gtlogin()
    controllers = {@controller1, @controller2, @controller3, @controller4, @controller5, @controller6};
    guards = {@guard1,@guard2,@guard3,@guard4,@guard5,@guard6};
end

%% Waypoint 1  

% function [u,saveData]=controller1(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
% @param uid The unique identifier of the current robot (1 is leader)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector.  For the leader robot, contains the 
%               relative displacement between the leader (uid = 1) and the 
%               current wp.  For follower robots, value is [0; 0].
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param missionData Used to pass misc. data that is specific for the
%                    scenario. See mission documentation for details.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @param firstCall Takes value 1 if it is the first time that the robot is 
%                  executing this controller.  Used for initialization.
% @return u A (2 x 1) vector giving the velocity control of the robot.
% @return saveData The updated storage memory contents for the robot.  Will
%                  be passed to the robot again the next time it executes a
%                  controller.
%
% This function impl ements the decentralized controller that all robots use 
% for clearing waypoint 1.
function [u,saveData]=controller1(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
    u = [0;0]; % Give no control for now, 
               % this is for you to implement
    r = 15;
    connted = 0;
    
    M = size(nbrData(:,1));
    if(M(1) == 5)
        connted = 1;
    end
    
    if(uid == 1 && connted)
        u = 10*wpData;
    elseif(uid ~= 1)
        M = size(nbrData(:,1));
        M = M(1);
        
        m = 200;
        
        d = sqrt(nbrData(:,1) .^ 2 + nbrData(:,2) .^ 2);
        c = repmat(2 * r,M,1);
        E0 = ones(size(nbrData(:,1:2)));
        E1 = 20 * (d - 7*r) ./ (d);
        %u = sum(repmat(E4,1,2) .* nbrData(:,1:2)');
        for ii = 1:M
            u = u + E1(ii) * nbrData(ii,1:2)';
        end
    end
end

% function [guardCleared]=guard1(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector containing the relative displacement 
%               between the leader and the current wp.  
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @return guardCleared The value 1 if the user-defined guard (evaluated bys
%                      the leader robot) is cleared, and 0 otherwise.  
%
% This function implements the guard condition that the leader robot uses  
% for clearing waypoint 1.
function [guardCleared]=guard1(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
    % Set guardCleared to 1 to not impose any additional 
    % conditions on the mode switches
    guardCleared = 1;
end

%% Waypoint 2

% function [u,saveData]=controller2(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
% @param uid The unique identifier of the current robot (1 is leader)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector.  For the leader robot, contains the 
%               relative displacement between the leader (uid = 1) and the 
%               current wp.  For follower robots, value is [0; 0].
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param missionData Used to pass misc. data that is specific for the
%                    scenario. See mission documentation for details.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @param firstCall Takes value 1 if it is the first time that the robot is 
%                  executing this controller.  Used for initialization.
% @return u A (2 x 1) vector giving the velocity control of the robot.
% @return saveData The updated storage memory contents for the robot.  Will
%                  be passed to the robot again the next time it executes a
%                  controller.
%
% This function implements the decentralized controller that all robots use 
% for clearing waypoint 2.

function E_d = dist_energy(nbrData,dist_multi)
    Ms = size(nbrData);
    r = 15;
    
    for ii = 1:Ms(1)
        dist(ii) = norm(nbrData(ii,1:2));
    end
    if Ms(1) ~= 0
        E_d = 20 * (dist - dist_multi*r) ./ dist;
    else
        E_d = 1;
    end
end

function a = proj_W_O(w,o)
    w0 = abs(dot(w,o)) * o ./ norm(o);
    a = w - w0';
end

function [safeVect,gain] = closest_obst(obD)
    sensAngl = (2*pi*(0:15)./16);
    
    %Find the closest obstacle vector and only use that
    [O_dist,O_angle] = min(obD);
    
    %Find the weighted average of the obstacle vectors
    
    
    if O_dist < 0.5

        O_vect = [O_dist .* cos(sensAngl(O_angle)), O_dist .* sin(sensAngl(O_angle))]';

        safeVect = -O_vect;
        gain = 500 ./ norm(safeVect);
    else
        safeVect = [1;1];
        gain = 0;
    end
end

function [O_dir,gain] = all_obst(obD)
    sensAngl = (2*pi*(0:15)./16);
    
    %Find the weighted average of the obstacle vectors
    for ii = 1:16
        if isfinite(obD(ii))
            O_dirs(ii,:) = (1/obD(ii)) * [cos(sensAngl(ii)),sin(sensAngl(ii))];
        else
            O_dirs(ii,:) = [0,0];
        end
    end
    O_dir = -mean(O_dirs,1)';
    if norm(O_dir) ~= 0
        O_dir = O_dir / norm(O_dir);
    end
    
    gain = 1;
end

function [u,saveData]=controller2(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
    u = [0;0];Ms = size(nbrData);
    nu = [0;0];
    p = 0.44;g = 500;
    
    AA_E = dist_energy(nbrData,6);
    
    for ii = 1:Ms(1)
        distData(ii,1) = norm(nbrData(ii,1:2));
        distData(ii,2) = nbrData(ii,3);
    end
        
    %Compute obstacle energies    
    %[O_V, O_gain] = closest_obst(obstacleData./delta);
    
    [O_V] = all_obst(obstacleData);
        
    %Remap agents and their lead neighbors they go
    remap_neig = [2,1;3,4;4,2;5,3;6,5];

    nei = remap_neig(remap_neig(:,1) == uid,2);
    if uid ~= 1
        a = find(nbrData(:,3) == nei);       
        
        
        AA_E(AA_E > 0) = 0;
        
        for ii=1:Ms(1)
            p = 0.3;
            nu = nu + AA_E(ii) * nbrData(ii,1:2)';

        end
        nu = nu + 1 * nbrData(a,1:2)';
        
        res_vect = (p * O_V + (1-p) * nu/norm(nu));
        u = g * res_vect ./ norm(res_vect);
    elseif uid == 1
        
        res_vect = (p * O_V + (1-p) * wpData/norm(wpData))
        u = g * res_vect ./ norm(res_vect);
    end
    disp(['Agent done: ' num2str(uid) ' with norm u as ' num2str(norm(u))]);
end

% function [guardCleared]=guard2(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector containing the relative displacement 
%               between the leader and the current wp.  
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @return guardCleared The value 1 if the user-defined guard (evaluated by
%                      the leader robot) is cleared, and 0 otherwise.  
%
% This function implements the guard condition that the leader robot uses  
% for clearing waypoint 2.
function [guardCleared]=guard2(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
    % Set guardCleared to 1 to not impose any additional 
    % conditions on the mode switches
    guardCleared = 0;
end

%% Waypoint 3

% function [u,saveData]=controller3(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
% @param uid The unique identifier of the current robot (1 is leader)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector.  For the leader robot, contains the 
%               relative displacement between the leader (uid = 1) and the 
%               current wp.  For follower robots, value is [0; 0].
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param missionData Used to pass misc. data that is specific for the
%                    scenario. See mission documentation for details.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @param firstCall Takes value 1 if it is the first time that the robot is 
%                  executing this controller.  Used for initialization.
% @return u A (2 x 1) vector giving the velocity control of the robot.
% @return saveData The updated storage memory contents for the robot.  Will
%                  be passed to the robot again the next time it executes a
%                  controller.
%
% This function implements the decentralized controller that all robots use 
% for clearing waypoint 3.
function [u,saveData]=controller3(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
u = [0;0];Ms = size(nbrData);
    nu = [0;0];
    p = 0.44;g = 500;
    
    AA_E = dist_energy(nbrData,6);
    
    for ii = 1:Ms(1)
        distData(ii,1) = norm(nbrData(ii,1:2));
        %distData(ii,2) = nbrData(ii,3);
    end
        
    %Compute obstacle energies    
    %[O_V, O_gain] = closest_obst(obstacleData./delta);
    
    [O_V] = all_obst(obstacleData);
        
    %Remap agents and their lead neighbors they go
    remap_neig = [2,1;3,4;4,2;5,3;6,1];

    nei = remap_neig(remap_neig(:,1) == uid,2);
    if uid ~= 1
        a = find(nbrData(:,3) == nei);       
        
        if isempty(a)
            %Find the nearest neighbor
            G = sortrows([nbrData,distData],4);
            a = find(nbrData(:,3) == G(1,3));
        end
        
        AA_E(AA_E > 0) = 0;
        
        for ii=1:Ms(1)
            p = 0.3;
            nu = nu + AA_E(ii) * nbrData(ii,1:2)';

        end
        nu = nu + 1 * nbrData(a,1:2)';
        
        res_vect = (p * O_V + (1-p) * nu/norm(nu));
        u = g * res_vect ./ norm(res_vect);
    elseif uid == 1
        
        res_vect = (p * O_V + (1-p) * wpData/norm(wpData))
        u = g * res_vect ./ norm(res_vect);
    end
    
    
end

% function [guardCleared]=guard3(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector containing the relative displacement 
%               between the leader and the current wp.  
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @return guardCleared The value 1 if the user-defined guard (evaluated by
%                      the leader robot) is cleared, and 0 otherwise.  
%
% This function implements the guard condition that the leader robot uses  
% for clearing waypoint 3.
function [guardCleared]=guard3(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
    % Set guardCleared to 1 to not impose any additional 
    % conditions on the mode switches
    guardCleared = 1;
end

%% Waypoint 4

% function [u,saveData]=controller4(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
% @param uid The unique identifier of the current robot (1 is leader)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector.  For the leader robot, contains the 
%               relative displacement between the leader (uid = 1) and the 
%               current wp.  For follower robots, value is [0; 0].
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param missionData Used to pass misc. data that is specific for the
%                    scenario. See mission documentation for details.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @param firstCall Takes value 1 if it is the first time that the robot is 
%                  executing this controller.  Used for initialization.
% @return u A (2 x 1) vector giving the velocity control of the robot.
% @return saveData The updated storage memory contents for the robot.  Will
%                  be passed to the robot again the next time it executes a
%                  controller.
%
% This function implements the decentralized controller that all robots use 
% for clearing waypoint 4.
function [u,saveData]=controller4(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
    u = [0;0]; % Give no control for now, 
               % this is for you to implement
end

% function [guardCleared]=guard4(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector containing the relative displacement 
%               between the leader and the current wp.  
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @return guardCleared The value 1 if the user-defined guard (evaluated by
%                      the leader robot) is cleared, and 0 otherwise.  
%
% This function implements the guard condition that the leader robot uses  
% for clearing waypoint 4.
function [guardCleared]=guard4(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
    % Set guardCleared to 1 to not impose any additional 
    % conditions on the mode switches
    guardCleared = 1;
end

%% Waypoint 5

% function [u,saveData]=controller5(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
% @param uid The unique identifier of the current robot (1 is leader)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector.  For the leader robot, contains the 
%               relative displacement between the leader (uid = 1) and the 
%               current wp.  For follower robots, value is [0; 0].
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param missionData Used to pass misc. data that is specific for the
%                    scenario. See mission documentation for details.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @param firstCall Takes value 1 if it is the first time that the robot is 
%                  executing this controller.  Used for initialization.
% @return u A (2 x 1) vector giving the velocity control of the robot.
% @return saveData The updated storage memory contents for the robot.  Will
%                  be passed to the robot again the next time it executes a
%                  controller.
%
% This function implements the decentralized controller that all robots use 
% for clearing waypoint 5.
function [u,saveData]=controller5(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
    u = [0;0]; % Give no control for now, 
               % this is for you to implement
end

% function [guardCleared]=guard5(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector containing the relative displacement 
%               between the leader and the current wp.  
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @return guardCleared The value 1 if the user-defined guard (evaluated by
%                      the leader robot) is cleared, and 0 otherwise.  
%
% This function implements the guard condition that the leader robot uses  
% for clearing waypoint 5.
function [guardCleared]=guard5(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
    % Set guardCleared to 1 to not impose any additional 
    % conditions on the mode switches
    guardCleared = 1;
end

%% Waypoint 6

% function [u,saveData]=controller6(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
% @param uid The unique identifier of the current robot (1 is leader)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector.  For the leader robot, contains the 
%               relative displacement between the leader (uid = 1) and the 
%               current wp.  For follower robots, value is [0; 0].
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param missionData Used to pass misc. data that is specific for the
%                    scenario. See mission documentation for details.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @param firstCall Takes value 1 if it is the first time that the robot is 
%                  executing this controller.  Used for initialization.
% @return u A (2 x 1) vector giving the velocity control of the robot.
% @return saveData The updated storage memory contents for the robot.  Will
%                  be passed to the robot again the next time it executes a
%                  controller.
%
% This function implements the decentralized controller that all robots use 
% for clearing waypoint 6.
function [u,saveData]=controller6(uid,nbrData,wpData,obstacleData,missionData,saveData,delta,agentRadius,firstCall)
    u = [0;0]; % Give no control for now, 
               % this is for you to implement
end

% function [guardCleared]=guard6(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
% @param nbrData A (M x 3) matrix of sensed data from neighbors.
%                Each row contains the relative displacement and UID of a
%                sensed neighbor in the format: [relativeX relativeY uid]
% @param wpData A (2 x 1) vector containing the relative displacement 
%               between the leader and the current wp.  
% @param obstacleData A (16 x 1) vector containing the relative distance 
%                     measurements for obstacles around the robot.
% @param saveData A (10 x 1) vector of storage memory for the robot.  Can
%                 be used to store anything, as long as it fits.
% @param delta The furthest away that the robot can sense anything.
% @param agentRadius The radius of the robot, used for obstacle evasion.
% @return guardCleared The value 1 if the user-defined guard (evaluated by
%                      the leader robot) is cleared, and 0 otherwise.  
%
% This function implements the guard condition that the leader robot uses  
% for clearing waypoint 6.
function [guardCleared]=guard6(nbrData,wpData,obstacleData,saveData,delta,agentRadius)
    % Set guardCleared to 1 to not impose any additional 
    % conditions on the mode switches
    guardCleared = 1;
end