% -------------------------------------------------------------------------
% This is the trial loop, called from the main script calc_kin_rt_mt.m
% -------------------------------------------------------------------------

% Functions and scripts called from within here:
% 1. movement_onset
% 2. movement_var


for t = trialstart_num:length(raw) % trial loop which goes through all 3 decisions

    early = 0; % set early-start-flag to 0 at beginning of each trial

    % CHECK "early start"-column in Excel (early_release_A1/A2/Coll == 1).
    % CHECK additionally if RT is implausibly small (< 100 ms).
    % If any of this is true, then exclude the entire trial!
    if (any([raw{t,end-2:end}])) || (blue_rt(t)<rt_min) || (yell_rt(t)<rt_min) || (Coll_rt(t)<rt_min)
        early = 1;
        early_count = early_count+1; % increase counter
    end

    % Who is taking the first decision in current trial t?
    % Note: this step is done only to create the "switch" column below
    if at1stDec(t) == 'B'
        FirstDec(t) = blue_Dec(t);
    else
        FirstDec(t) = yell_Dec(t);
    end
    % Did the first agent change her mind when taking the coll. decision?
    if FirstDec(t) == Coll_Dec(t)
        changeMind(t) = 0;
    else
        changeMind(t) = 1;
    end
    
    % Check who is the executing agent for each decision
    agentExec1    = lower(at1stDec(t));
    agentExec2    = lower(at2ndDec(t));
    agentExecColl = lower(atCollDec(t));
    % Assign RT to 1st, 2nd, and collective accordingly
    if at1stDec(t) == 'B'
        FirstRT = blue_rt(t);
        SecRT   = yell_rt(t);
    else
        FirstRT = yell_rt(t);
        SecRT   = blue_rt(t);
    end
    CollRT      = Coll_rt(t);

    % SANITY CHECK: Do 1st and 2nd agent differ? (they have to)
    if at1stDec(t) == at2ndDec(t)
        warning('Agents taking 1st and 2nd decisions are the same! Aaargh #!@*&%');
    end


    %% CALL FUNCTIONS TO COMPUTE TRIAL START/END and KIN. VARIABLES

    % AGENT ACTING FIRST --------------------------------------------------
    
    label_agent = 'FIRSTDecision';

    % 1. call movement_onset.m
    if not(early)
        [startFrame1,tmove1,rt_final1,dt_final1,mt_final1,endFrame1] = ...
            movement_onset(sMarkers,faa,SUBJECTS,p,agentExec1,label_agent, ...
            FirstRT,trial_plot,figurepath);
    end
    % 2. call movement_var.m
    % only if start frame exists and start button was NOT pressed too early
    if not(isnan(startFrame1)) && not(early)
        [tindex1,tulna1,sindex1,sulna1,sdindex1, ...
            time_traj_index1,time_traj_ulna1,spa_traj_index1,spa_traj_ulna1] = ...
            movement_var(sMarkers,faa,SUBJECTS,p,agentExec1,startFrame1,endFrame1,flag_bin);
    else % otherwise fill with NaN
        tindex1          = [NaN NaN NaN];
        tulna1           = [NaN NaN NaN];
        sindex1          = [NaN NaN NaN NaN];
        sulna1           = [NaN NaN NaN NaN];
        sdindex1         = [NaN NaN NaN NaN];
        time_traj_index1 = ones(100,3)*NaN;
        time_traj_ulna1  = ones(100,3)*NaN;
        spa_traj_index1  = ones(100,3)*NaN;
        spa_traj_ulna1   = ones(100,3)*NaN;
    end

    if flag_bin % only if we want to bin/normalize trajectories

        if at1stDec(t) == 'B' % blue takes first decision
            all_time_traj_index_b(:,:,t) = time_traj_index1;
            all_time_traj_ulna_b(:,:,t)  = time_traj_ulna1;
            all_spa_traj_index_b(:,:,t)  = spa_traj_index1;
            all_spa_traj_ulna_b(:,:,t)   = spa_traj_ulna1;
        else % yellow takes first decision
            all_time_traj_index_y(:,:,t) = time_traj_index1;
            all_time_traj_ulna_y(:,:,t)  = time_traj_ulna1;
            all_spa_traj_index_y(:,:,t)  = spa_traj_index1;
            all_spa_traj_ulna_y(:,:,t)   = spa_traj_ulna1;
        end

    else % only if we DO NOT bin/normalize trajectories
        
        % Note: we currently exclude trials that are too long
        % -> check setting of "max_samples" in calc_kin_init.m
        if length(time_traj_index1) > max_samples
            if at1stDec(t) == 'B' % blue takes first decision
                all_time_traj_index_b(:,:,t) = NaN*ones(max_samples,3);
                all_time_traj_ulna_b(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_index_b(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_ulna_b(:,:,t)   = NaN*ones(max_samples,3);
            else % yellow takes first decision
                all_time_traj_index_y(:,:,t) = NaN*ones(max_samples,3);
                all_time_traj_ulna_y(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_index_y(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_ulna_y(:,:,t)   = NaN*ones(max_samples,3);
            end
        else % for all trials with samples < max_samples (usual case)
            if at1stDec(t) == 'B' % blue takes first decision
                all_time_traj_index_b(:,:,t) = [time_traj_index1;NaN*ones((max_samples-length(time_traj_index1)),3)];
                all_time_traj_ulna_b(:,:,t)  = [time_traj_ulna1;NaN*ones((max_samples-length(time_traj_ulna1)),3)];
                all_spa_traj_index_b(:,:,t)  = [spa_traj_index1;NaN*ones((max_samples-length(spa_traj_index1)),3)];
                all_spa_traj_ulna_b(:,:,t)   = [spa_traj_ulna1;NaN*ones((max_samples-length(spa_traj_ulna1)),3)];
            else % yellow takes first decision
                all_time_traj_index_y(:,:,t) = [time_traj_index1;NaN*ones((max_samples-length(time_traj_index1)),3)];
                all_time_traj_ulna_y(:,:,t)  = [time_traj_ulna1;NaN*ones((max_samples-length(time_traj_ulna1)),3)];
                all_spa_traj_index_y(:,:,t)  = [spa_traj_index1;NaN*ones((max_samples-length(spa_traj_index1)),3)];
                all_spa_traj_ulna_y(:,:,t)   = [spa_traj_ulna1;NaN*ones((max_samples-length(spa_traj_ulna1)),3)];
            end
        end
    end

    faa = faa + 3; % increase decision counter
    % ---------------------------------------------------------------------

    % AGENT ACTING SECOND -------------------------------------------------
    
    label_agent = 'SECONDDecision';

    % 1. call movement_onset.m
    if not(early)
        [startFrame2,tmove2,rt_final2,dt_final2,mt_final2,endFrame2] = ...
            movement_onset(sMarkers,saa,SUBJECTS,p,agentExec2,label_agent, ...
            SecRT,trial_plot,figurepath);
    end
    % 2. call movement_var.m
    % only if start frame exists and start button was NOT pressed too early
    if not(isnan(startFrame2)) && not(early)
        [tindex2,tulna2,sindex2,sulna2,sdindex2, ...
            time_traj_index2,time_traj_ulna2,spa_traj_index2,spa_traj_ulna2] = ...
            movement_var(sMarkers,saa,SUBJECTS,p,agentExec2,startFrame2,endFrame2,flag_bin);
    else % otherwise fill with NaN
        tindex2          = [NaN NaN NaN];
        tulna2           = [NaN NaN NaN];
        sindex2          = [NaN NaN NaN NaN];
        sulna2           = [NaN NaN NaN NaN];
        sdindex2         = [NaN NaN NaN NaN];
        time_traj_index2 = ones(100,3)*NaN;
        time_traj_ulna2  = ones(100,3)*NaN;
        spa_traj_index2  = ones(100,3)*NaN;
        spa_traj_ulna2   = ones(100,3)*NaN;
    end

    if flag_bin % only if we want to bin/normalize trajectories
        
        if at2ndDec(t) == 'B' % blue takes second decision
            all_time_traj_index_b(:,:,t) = time_traj_index2;
            all_time_traj_ulna_b(:,:,t)  = time_traj_ulna2;
            all_spa_traj_index_b(:,:,t)  = spa_traj_index2;
            all_spa_traj_ulna_b(:,:,t)   = spa_traj_ulna2;
        else % yellow takes second decision
            all_time_traj_index_y(:,:,t) = time_traj_index2;
            all_time_traj_ulna_y(:,:,t)  = time_traj_ulna2;
            all_spa_traj_index_y(:,:,t)  = spa_traj_index2;
            all_spa_traj_ulna_y(:,:,t)   = spa_traj_ulna2;
        end

    else % only if we DO NOT bin/normalize trajectories
        
        % Note: we currently exclude trials that are too long -> see
        % calc_kin_init and check setting of max_samples
        if length(time_traj_index2) > max_samples
            if at2ndDec(t) == 'B' % blue takes second decision
                all_time_traj_index_b(:,:,t) = NaN*ones(max_samples,3);
                all_time_traj_ulna_b(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_index_b(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_ulna_b(:,:,t)   = NaN*ones(max_samples,3);
            else % yellow takes second decision
                all_time_traj_index_y(:,:,t) = NaN*ones(max_samples,3);
                all_time_traj_ulna_y(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_index_y(:,:,t)  = NaN*ones(max_samples,3);
                all_spa_traj_ulna_y(:,:,t)   = NaN*ones(max_samples,3);
            end
        else % for all trials with samples < max_samples (usual case)
            if at2ndDec(t) == 'B' % blue takes second decision
                all_time_traj_index_b(:,:,t) = [time_traj_index2;NaN*ones((max_samples-length(time_traj_index2)),3)];
                all_time_traj_ulna_b(:,:,t)  = [time_traj_ulna2;NaN*ones((max_samples-length(time_traj_ulna2)),3)];
                all_spa_traj_index_b(:,:,t)  = [spa_traj_index2;NaN*ones((max_samples-length(spa_traj_index2)),3)];
                all_spa_traj_ulna_b(:,:,t)   = [spa_traj_ulna2;NaN*ones((max_samples-length(spa_traj_ulna2)),3)];
            else % yellow takes second decision
                all_time_traj_index_y(:,:,t) = [time_traj_index2;NaN*ones((max_samples-length(time_traj_index2)),3)];
                all_time_traj_ulna_y(:,:,t)  = [time_traj_ulna2;NaN*ones((max_samples-length(time_traj_ulna2)),3)];
                all_spa_traj_index_y(:,:,t)  = [spa_traj_index2;NaN*ones((max_samples-length(spa_traj_index2)),3)];
                all_spa_traj_ulna_y(:,:,t)   = [spa_traj_ulna2;NaN*ones((max_samples-length(spa_traj_ulna2)),3)];
            end
        end
    end

    saa = saa + 3; % increase decision counter
    % ---------------------------------------------------------------------

    % Collective decision -------------------------------------------------
    % Note: We currently DO NOT prepare the trajectory plots (with all
    % trials for the collective decision (with all_time/spa_ data).

    label_agent = 'COLLECTIVEDecision';

    % 1. call movement_onset.m
    if not(early)
        [startFrameColl,tmoveColl,rt_finalColl,dt_finalColl,mt_finalColl,endFrameColl] = ...
            movement_onset(sMarkers,caa,SUBJECTS,p,agentExecColl,label_agent, ...
            CollRT,trial_plot,figurepath);
    end
    % 2. call movement_var.m
    % if start frame exists and start button was NOT pressed too early
    if not(isnan(startFrameColl)) && not(early)
        [tindexColl,tulnaColl,sindexColl,sulnaColl,sdindexColl, ...
            time_traj_indexColl,time_traj_ulnaColl,spa_traj_indexColl,spa_traj_ulnaColl] = ...
            movement_var(sMarkers,caa,SUBJECTS,p,agentExecColl,startFrameColl,endFrameColl,flag_bin);
    else % otherwise fill with NaN
        tindexColl          = [NaN NaN NaN];
        tulnaColl           = [NaN NaN NaN];
        sindexColl          = [NaN NaN NaN NaN];
        sulnaColl           = [NaN NaN NaN NaN];
        sdindexColl         = [NaN NaN NaN NaN];
        time_traj_indexColl = ones(100,3)*NaN;
        time_traj_ulnaColl  = ones(100,3)*NaN;
        spa_traj_indexColl  = ones(100,3)*NaN;
        spa_traj_ulnaColl   = ones(100,3)*NaN;
    end

    caa = caa +3; % increase decision counter
    % -----------------------------------------------------------------

    %% Create new data set
    % Now we add the newly computed parameters to the original Excel file
    % and create a new Excel file (a much bigger one): expData_xxx_kin_model
    
    if flag_bin % write the new Excel file ONLY FOR binned data

        % size of old header (from original Excel file)
        ol                         = size(txt_or);
        
        % ADD TIME VARIABLES (i.e., append to end of original Excel file)
        % -> variables are added for current trial t
        data{t,ol(2)+1:ol(2)+10}   = [changeMind(t) rt_final1 rt_final2 rt_finalColl ...
                                                    dt_final1 dt_final2 dt_finalColl ...
                                                    mt_final1 mt_final2 mt_finalColl];
        % ADD KINEMATIC DATA
        % -> normalized 100 samples for index and ulna: ONLY 2nd DECISION
        data{t,ol(2)+11:ol(2)+719} = [time_traj_index2(:,1)' time_traj_index2(:,2)' time_traj_index2(:,3)' ...
                                      time_traj_ulna2(:,1)' time_traj_ulna2(:,2)' time_traj_ulna2(:,3)' ...
                                      spa_traj_index2(:,3)' spa_traj_ulna2(:,3)'...
                                      startFrame1 tmove1 endFrame1 ...
                                      startFrame2 tmove2 endFrame2 ...
                                      startFrameColl tmoveColl endFrameColl];
        
        % Assign new header (created in calc_kin_rt_mt.m)
        data.Properties.VariableNames = txt;
        
        % -----------------------------------------------------------------
        % Note: The above does not work if started from backup; then you
        % need to combine the bkp-data and the new data manually afterwards
        if str2double(crash)
            data(1:trialstart_num-1,:) = data_bkp(1:trialstart_num-1,:);
            crash = '0';
        end % -------------------------------------------------------------

        % write the Excel file
        writetable(data,fullfile(path_kin,['expData_' SUBJECTS{p}(2:end) '_kin_model.xlsx']));

    end % end of adding data to Excel file

end % end of trial loop (i.e., all trials for one pair were completed)

% script version: 1 Nov 2023