% Boyd & Vandenberghe, "Convex Optimization"
% Jo�lle Skaf - 08/23/05
%
% Solved a QCQP with 3 inequalities:
%           minimize    1/2 x'*P0*x + q0'*r + r0
%               s.t.    1/2 x'*Pi*x + qi'*r + ri <= 0   for i=1,2,3
% and verifies that strong duality holds.

%% Initialization
% Listen for requests
clear all;
ch = zmq('reply', 'ipc', 'armopt');
%while 1
raw = struct([]);
optimized = struct([]);
stop = 0;
%% Main loop
while stop==0
    p = zmq('poll', 1000);
    if numel(p)>0
        %% Load new plan
        tmpfile = zmq('receive', ch);
        tmpfile = char(tmpfile);
        fprintf(1, 'Optimizing %s\n', tmpfile);
        load(char(tmpfile));
        
        %% Reformat the Data
        % Original Path
        qw0 = [qwPath{:}]';
        % Task Space target
        vw0 = [vwPath{:}]';
        % Task Space effective
        vw = [vwEffective{:}]';
        
        %% Save the results
        raw(i_optimizations).qw0 = qw0;
        raw(i_optimizations).vw0 = vw0;
        raw(i_optimizations).vw = vw;
        
        %% Run the optimizer
        if stop==0
            if exist('qWaistArmGuess', 'var')
                disp('Using a guess');
                qwStar = qWaistArmGuess';
            else
                disp('Using the endpoint!');
                qwStar = qw0(end, :);
            end
            % Save results to be opened
            if kind==1
                % Subspace Optimization
                [qLambda, dt_opt_lambda] = ...
                    optimize_armplan_lambda(qw0, vw0, nulls, Js, qwStar);
                optimized(i_optimizations).qLambda = qLambda;
                optimized(i_optimizations).dt_opt_lambda = dt_opt_lambda;
                optimized(i_optimizations).dt_opt = sum(dt_opt_lambda, 1);
                save(tmpfile, 'qLambda');
            else
                % Regular Optimization
                [qw, dt_opt] = ...
                    optimize_armplan(qw0, vw0, nulls, Js, qwStar);
                optimized(i_optimizations).qw = qw;
                optimized(i_optimizations).dt_opt = dt_opt;
                save(tmpfile, 'qw');
            end
        end
        
        y = zmq('send', ch, tmpfile);
        show_armplan;
    end
    
end

%% Finish with a plot

%end