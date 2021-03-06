%% NOTE

% Total runtime for this code was about 3 hours on the computer used by
% the original researcher (for 1000 run average of 3 different adherence
% values).
% This runtime is expected to vary from device to device, and is being used
% here to obtain a general comparison for runtime for the different
% models. It is not for a universal runtime value

% When run, this code does not display anything at the beginning. However,
% it will produce 2 graphs for each P_adh value every 1 hour approx.

%% Documentation

% n             size of each dimension of our square cellular automata grid
% P_HIV         fraction (probability) of cells initially infected by virus
% P_i           probability of a healthy cell becoming infected if its
%               neighborhood contains 1 I1 cell or X I2 cells
% P_v           probability of a healthy cell becoming infected by coming
%               in contact with a virus randomly (not from its
%               neighborhood)
% P_RH          Probability of a dead cell becoming replaced by a healthy
%               cell
% P_RI          Probability of a dead cell becoming replaced by an infected
%               cell
% P_T1          Probability of a healthy cell receiving therapy
% P_infT         Probability of a healthy cell receiving therapy of becoming
%               infected
% X             Number of I2 cells in the neighborhood of an H cell that
%               can cause it to become infected
% tau1          tau1 is the number of timesteps it takes for an acute
%               infected cell to become latent.
% tau2          tau2 is the number of timesteps it takes for a latent
%               infected cell to become dead.
% totalsteps    totalsteps is the total number of steps of the CA (the
%               total number of weeks of simulations)
% grid          our cellular automata (CA) grid
% tempgrid      tempgrid is a temporary grid full of random numbers that is
%               used to randomly add different states to our CA grid.
% taugrid       taugrid is a grid the same size as our CA grid that stores
%               the number of timesteps that a cell has been in state I_1.
%               If the number reaches tau1, then the state changes to I_2.
% state         state is a [7 x totalsteps] size matrix that stores
%               the total number of cells in each state at each timestep
%               and the last 2 rows store total healthy and total infected
%               cells
% timestep      each simulation step of the cellular automata
%               1 timestep = 1 week of time in the real world
% nextgrid      nextgrid is a temporary grid. It is a copy of the CA grid
%               from the previous simulation. It stores all the CA rule
%               updates of the current timestep and stores it all back to
%               the grid to display.

%% Clean-up

clc;            % clears command window
clear all;      % clears workspace and deletes all variables
close all;      % closes all open figures

%% Parameters

n = 100;            % meaning that our grid will have the dimensions n x n
P_HIV = 0.05;       % initial grid will have P_hiv acute infected cells
P_i = 0.997;        % probability of infection by neighbors
P_v = 0.00001;      % probability of infection by random viral contact
P_RH = 0.99;        % probability of dead cell being replaced by healthy
P_RI = 0.00001;     % probability of dead cell being replaced by infected
X = 4;              % there must be at least X I_2 neighbors to infect cell
tau1 = 4;           % time delay for I_1 cell to become I_2 cell
tau2 = 1;           % time delay for I_2 cell to become D cell
P_T = 0.70;         % probability of cell receiving therapy 1
P_infT = 0.07;        % probability of infection of healthy with therapy 1
totalsteps = 600;   % total number of weeks of simulation to be performed
T_start = 20;       % The medication therapy will start on week T_start
totalruns = 1000;   % total number of times to run the simulation to get an
% average

%% States

% State 1: H:       Healthy                 (Color- Green)
% State 2: H_T1:    Healthy with Therapy    (Color- Red)
% State 3: I_1:     Active Infected         (Color- Cyan)
% State 4: I_2:     Latent Infected         (Color- Blue)
% State 5: D:       Dead                    (Color- Black)

%% Simulation

for P_adh = 0.5:0.2:0.9
    
    state1 = zeros(totalruns,totalsteps);
    state2 = zeros(totalruns,totalsteps);
    state3 = zeros(totalruns,totalsteps);
    state4 = zeros(totalruns,totalsteps);
    state5 = zeros(totalruns,totalsteps);
    
    for run = 1:totalruns
        
        grid = ones(n);     % creates our initial n x n matrix and fills all cells
        % with value 1 (meaning H state - Healthy cell)
        tempgrid = rand(n); % creates a grid of random values of the same size as
        % our CA grid. Used to randomly add I_1 state to our grid
        grid(tempgrid(:,:)<=P_HIV) = 3;  % I_1 state added with probability  P_HIV
        
        % The following sets the edge values of the grid to H state
        grid(:,[1 n]) = 1;   % to set every value in the first and last column to 1
        grid([1 n],:) = 1;   % to set every value in the first and last row to 1
        
        % NOTE: Our CA only simulates from rows 2 to n-1, and columns 2 to n-1.
        %       This is to prevent the edge row and column cells from having an
        %       out-of-bounds error when checking the neighbors around them.
        %       The edge values are all set to H state so that it does not affect
        %       Rule 1 of the CA for cells next to them
        
        taugrid = zeros(n); % to initially set number of timesteps that a cell has
        % been in state 2 to zero for every cell
        timestep = 1;
        
        while timestep<=totalsteps
            nextgrid = grid;
            for x=2:n-1
                for y=2:n-1
                    
                    % Rule 1
                    % If the cell is in H state, it can become H_T1 or I_1
                    if(grid(x,y)==1)
                        random1=rand;
                        random2=rand;
                        % Rule 1. a  It can become H_T1 state with probability P_T1
                        if(random1 <= P_T && timestep >= T_start && random2 <= P_adh)
                            nextgrid(x,y) = 2;
                            continue;
                            
                            % Rule 1. b Otherwise, it can become I_1 if the neighbor
                            % condition is met with probability P_i
                        elseif(((random1 <= P_i) && ...
                                (grid(x-1,y-1)==3 || grid(x-1,y)==3 || ...
                                grid(x-1,y+1)==3 || grid(x,y-1)==3 || ...
                                grid(x,y+1)==3 || grid(x+1,y-1)==3 || ...
                                grid(x+1,y)==3 || grid(x+1,y+1)==3 || ...
                                ((grid(x-1,y-1)==4) + (grid(x-1,y)==4) + ...
                                (grid(x-1,y+1)==4) + (grid(x,y-1)==4) + ...
                                (grid(x,y+1)==4) + (grid(x+1,y-1)==4) + ...
                                (grid(x+1,y)==4) + (grid(x+1,y+1)==4))>=X )) ...
                                || (random2 <= P_v) )
                            nextgrid(x,y) = 3;
                        end
                        continue;
                    end
                    
                    % Rule 2
                    % If the cell is in state H_T1, it can become I_1 or H
                    if(grid(x,y) == 2)
                        random1=rand;
                        random2=rand;
                        % Rule 2. a
                        % It can become I_1 with probability P_infT if neighbor
                        % condition is met
                        if((random1 <= P_infT) && (((random2 <= P_i) && ...
                                (grid(x-1,y-1)==3 || grid(x-1,y)==3 || ...
                                grid(x-1,y+1)==3 || grid(x,y-1)==3 || ...
                                grid(x,y+1)==3 || grid(x+1,y-1)==3 || ...
                                grid(x+1,y)==3 || grid(x+1,y+1)==3 || ...
                                ((grid(x-1,y-1)==4) + (grid(x-1,y)==4) + ...
                                (grid(x-1,y+1)==4) + (grid(x,y-1)==4) + ...
                                (grid(x,y+1)==4) + (grid(x+1,y-1)==4) + ...
                                (grid(x+1,y)==4) + (grid(x+1,y+1)==4))>=X )) ...
                                || (random2 <= P_v) ) )
                            nextgrid(x,y) = 3;
                            continue;
                            
                            % Rule 2. b
                            % or become H in the absence of probability P_T1
                        elseif(random1 > P_T || random2 > P_adh)
                            nextgrid(x,y) = 1;
                        end
                        continue;
                    end
                    
                    % Rule 3
                    % If the cell is in state I_1, and has been in this state for
                    % tau1 timesteps, the cell becomes I_2 state (latent infected)
                    if((grid(x,y)==3))
                        taugrid(x,y) = taugrid(x,y)+1;
                        if(taugrid(x,y)==tau1)
                            nextgrid(x,y)=4;
                            taugrid(x,y)=0;
                        end
                        continue;
                    end
                    
                    % Rule 4
                    % If the cell is in I_2 state, and has been in this state for
                    % tau2 timesteps, the cell becomes D state (dead)
                    % Since tau2=1, this rule is implemented every timestep
                    if((grid(x,y)==4))
                        nextgrid(x,y)=5;
                        continue;
                    end
                    
                    % Rule 5
                    % If the cell is in D state, it can be replaced by a
                    % healthy cell with probability P_RH (5.a), and then
                    % the replaced cell can be furthe replaced by an I_1
                    %infected cell with probability P_RI (5.b)
                    if(grid(x,y)==5 && rand<=P_RH)
                        if(rand<=P_RI)
                            nextgrid(x,y)=3;
                            continue;
                        else
                            nextgrid(x,y)=1;
                        end
                    end
                    
                end
            end
            grid=nextgrid;      % to assign the updates of this timestep in
            % nextgrid back to our grid
            
            state1(run,timestep) = sum(sum(grid(2:n-1,2:n-1)==1)); % H
            state2(run,timestep) = sum(sum(grid(2:n-1,2:n-1)==2)); % H_T
            state3(run,timestep) = sum(sum(grid(2:n-1,2:n-1)==3)); % I_1
            state4(run,timestep) = sum(sum(grid(2:n-1,2:n-1)==4)); % I_2
            state5(run,timestep) = sum(sum(grid(2:n-1,2:n-1)==5)); % D
            
            timestep=timestep+1;    % to move to the next timestep
        end
    end
    
    state1dev = std(state1);
    state2dev = std(state2);
    state3dev = std(state3);
    state4dev = std(state4);
    state5dev = std(state5);
    state6dev = state1dev + state2dev;
    state7dev = state3dev + state4dev;
    
    state1mean = mean(state1);
    state2mean = mean(state2);
    state3mean = mean(state3);
    state4mean = mean(state4);
    state5mean = mean(state5);
    state6mean = state1mean + state2mean;
    state7mean = state3mean + state4mean;
    
    % The following lines of code are to display a graph of each state of
    % cells during simulation
    set(figure, 'OuterPosition', [200 100 700 500]) % sets figure window size
    plot( 1:totalsteps , state1mean, 'g', ...
        1:totalsteps , state2mean, 'r', ...
        1:totalsteps , state3mean, 'c', ...
        1:totalsteps , state4mean, 'b', ...
        1:totalsteps , state5mean, 'k' , 'linewidth', 2 );
    hold on;
    gridxy(20,'Color',[0.8 0.5 0.0],'linewidth',5) ;
    errorbar( 1:15:totalsteps , state1mean(1:15:totalsteps), state1dev(1:15:totalsteps), 'g');
    errorbar( 1:15:totalsteps , state2mean(1:15:totalsteps), state2dev(1:15:totalsteps), 'r');
    errorbar( 1:15:totalsteps , state3mean(1:15:totalsteps), state3dev(1:15:totalsteps), 'c');
    errorbar( 1:15:totalsteps , state4mean(1:15:totalsteps), state4dev(1:15:totalsteps), 'b');
    errorbar( 1:15:totalsteps , state5mean(1:15:totalsteps), state5dev(1:15:totalsteps), 'k');
    legend( 'Therapy start week', 'Healthy', 'Healthy with Therapy', 'Acute Infected', 'Latent Infected', ...
        'Dead', 'Location' ,'NorthEast' );
    saveas(gcf,strcat('Model2withAdherencePadh',num2str(P_adh*100),'Graph1.pdf'));
    
    
    % The following lines of code are to display a graph of each state of
    % cells during simulation
    set(figure, 'OuterPosition', [200 100 700 500]) % sets figure window size
    plot( 1:totalsteps , state6mean, 'g', ...
        1:totalsteps , state7mean, 'b', ...
        1:totalsteps , state5mean, 'k' , 'linewidth', 2 );
    hold on;
    gridxy(20,'Color',[0.8 0.5 0.0],'linewidth',5) ;
    errorbar( 1:15:totalsteps , state6mean(1:15:totalsteps), state6dev(1:15:totalsteps), 'g');
    errorbar( 1:15:totalsteps , state7mean(1:15:totalsteps), state7dev(1:15:totalsteps), 'b');
    errorbar( 1:15:totalsteps , state5mean(1:15:totalsteps), state5dev(1:15:totalsteps), 'k');
    legend( 'Therapy start week', 'Healthy', 'Infected', 'Dead', ...
        'Location' ,'NorthEast' );
    saveas(gcf,strcat('Model2withAdherencePadh',num2str(P_adh*100),'Graph2.pdf'));
    
end
