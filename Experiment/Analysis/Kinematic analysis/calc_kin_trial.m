% -------------------------------------------------------------------------
% This is the trial loop, called from the main script calc_kin_rt_mt.m
% -------------------------------------------------------------------------

% Functions and scripts called from within here:
% 1. movement_onset
% 2. movement_var

for t = trialstart_num:length(raw) % trial loop which goes through all 3 decisions
    % NOTE: here, t is the TRIAL number, i.e., 1-160

    early = 0; % set early-start-flag to 0 at beginning of each trial

    % if pair=110 and t=159 ("Trial nr. 478-480), delete trial
    % (we exclude this trial because it was not properly re-constructed
    %  [models switched] and we cannot correct it bc of the trial re-numbering
    %  due to the lost trial... so we count this as "early start" even
    %  though it is actually a technical error)
    if str2double(SUBJECTS{p}(2:end))==110 && t==159
        early = 1;
        early_count = early_count+1; % increase counter
    end

    % CHECK "early start"-column in Excel (early_release_A1/A2 == 1)
    % If early start for any of the 3 decisions, then EXCLUDE ENTIRE trial!
    % Note: this means that these 3 decisions will be "jumped", i.e., we do
    % not compute anything (do not call movement_onset and movement_var)
    if (any([raw{t,end-2:end}]))
        % add following to CHECK additionally if RT is implausibly small (< 100 ms)
        % || (blue_rt(t)<rt_min) || (yell_rt(t)<rt_min) || (Coll_rt(t)<rt_min)
        early = 1;
        early_count = early_count+1; % increase counter
    end

    % Who is taking the first decision in current trial t?
    % Note: this step is done only to create the "switch" column below
    if pairS.at1stDec(t) == 'B'
        FirstDec(t) = pairS.blue_Dec(t);
    else
        FirstDec(t) = pairS.yell_Dec(t);
    end
    % Did the first agent change her mind when taking the coll. decision?
    if FirstDec(t) == pairS.Coll_Dec(t)
        changeMind(t) = 0;
    else
        changeMind(t) = 1;
    end

    % Check who is the executing agent for each decision
    agentExec1    = lower(pairS.at1stDec(t));
    agentExec2    = lower(pairS.at2ndDec(t));
    agentExecColl = lower(pairS.atCollDec(t));
    
    % Assign RT to 1st, 2nd, and collective accordingly
    if pairS.at1stDec(t) == 'B'
        FirstRT = blue_rt(t);
        SecRT   = yell_rt(t);
    else
        FirstRT = yell_rt(t);
        SecRT   = blue_rt(t);
    end
    CollRT      = Coll_rt(t);

    % SANITY CHECK: Do 1st and 2nd agent differ? (they have to)
    if pairS.at1stDec(t) == pairS.at2ndDec(t)
        warning('Agents taking 1st and 2nd decisions are the same! Aaargh #!@*&%');
    end


    %% CALL FUNCTIONS TO COMPUTE TRIAL START/END and KIN. VARIABLES

    % AGENT ACTING FIRST --------------------------------------------------

    label_agent = 'FIRSTdecision';
    fprintf(['\n---------- Trial n. ' num2str(sMarkers{faa}.info.trial_id) ' ----------\n']);
   
    % 1. call movement_onset.m
    if not(early)
        [startFrame1,tmove1,rt_final1,dt_final1,mt_final1,endFrame1,trgChange1,pksInd1,pksUlna1,savemat1,mod1] = ...
            movement_onset(sMarkers,faa,SUBJECTS,p,agentExec1,label_agent, ...
            FirstRT,trial_plot,figurepath);
    else
        startFrame1=NaN;tmove1=NaN;rt_final1=NaN;dt_final1=NaN;mt_final1=NaN;
        endFrame1=NaN;trgChange1=NaN;savemat1=NaN;mod1=NaN;
        pksInd1.peaks_index=NaN;pksInd1.peak_loc_index=NaN;pksInd1.npIndex=NaN;
        pksUlna1.peaks_ulna=NaN;pksUlna1.peak_loc_ulna=NaN;pksUlna1.npUlna=NaN;
    end

    % 2. call movement_var.m
    % only if start frame exists and start button was NOT pressed too early
    % variable info (see movement_var): 
    % tindex/ulna = [va_index aa_index ja_index] -> temp. variables: averages
    % sindex/ulna = [pz_index mz_index za_index az_index] -> spatial variables
    % sdindex = [ard mxd mnd ad] -> spatial deviationv variables (index only)
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
        time_traj_index1 = ones(bin,3)*NaN;
        time_traj_ulna1  = ones(bin,3)*NaN;
        spa_traj_index1  = ones(bin,3)*NaN;
        spa_traj_ulna1   = ones(bin,3)*NaN;
    end


    if flag_bin % only if we want to bin/normalize trajectories

        if pairS.at1stDec(t) == 'B' % blue takes first decision
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
            if pairS.at1stDec(t) == 'B' % blue takes first decision
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
            if pairS.at1stDec(t) == 'B' % blue takes first decision
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

    label_agent = 'SECONDdecision';
    fprintf(['\n---------- Trial n. ' num2str(sMarkers{saa}.info.trial_id) ' ----------\n']);
   
    % 1. call movement_onset.m
    if not(early)
        [startFrame2,tmove2,rt_final2,dt_final2,mt_final2,endFrame2,trgChange2,pksInd2,pksUlna2,savemat2,mod2] = ...
            movement_onset(sMarkers,saa,SUBJECTS,p,agentExec2,label_agent, ...
            SecRT,trial_plot,figurepath);
    else
        startFrame2=NaN;tmove2=NaN;rt_final2=NaN;dt_final2=NaN;mt_final2=NaN;
        endFrame2=NaN;trgChange2=NaN;savemat2=NaN;mod2=NaN;
        pksInd2.peaks_index=NaN;pksInd2.peak_loc_index=NaN;pksInd2.npIndex=NaN;
        pksUlna2.peaks_ulna=NaN;pksUlna2.peak_loc_ulna=NaN;pksUlna2.npUlna=NaN;
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
        time_traj_index2 = ones(bin,3)*NaN;
        time_traj_ulna2  = ones(bin,3)*NaN;
        spa_traj_index2  = ones(bin,3)*NaN;
        spa_traj_ulna2   = ones(bin,3)*NaN;
    end

    if flag_bin % only if we want to bin/normalize trajectories

        if pairS.at2ndDec(t) == 'B' % blue takes second decision
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
            if pairS.at2ndDec(t) == 'B' % blue takes second decision
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
            if pairS.at2ndDec(t) == 'B' % blue takes second decision
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

    % COLLECTIVE DECISION -------------------------------------------------
    
    label_agent = 'COLLECTIVEdecision';
    fprintf(['\n---------- Trial n. ' num2str(sMarkers{caa}.info.trial_id) ' ----------\n']);
   
    % 1. call movement_onset.m
    if not(early)
        [startFrameColl,tmoveColl,rt_finalColl,dt_finalColl,mt_finalColl,endFrameColl,trgChangeColl,pksIndColl,pksUlnaColl,savematColl,modColl] = ...
            movement_onset(sMarkers,caa,SUBJECTS,p,agentExecColl,label_agent, ...
            CollRT,trial_plot,figurepath);
    else
        startFrameColl=NaN;tmoveColl=NaN;rt_finalColl=NaN;dt_finalColl=NaN;mt_finalColl=NaN;
        endFrameColl=NaN;trgChangeColl=NaN;savematColl=NaN;modColl=NaN;
        pksIndColl.peaks_index=NaN;pksIndColl.peak_loc_index=NaN;pksIndColl.npIndex=NaN;
        pksUlnaColl.peaks_ulna=NaN;pksUlnaColl.peak_loc_ulna=NaN;pksUlnaColl.npUlna=NaN;
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
        time_traj_indexColl = ones(bin,3)*NaN;
        time_traj_ulnaColl  = ones(bin,3)*NaN;
        spa_traj_indexColl  = ones(bin,3)*NaN;
        spa_traj_ulnaColl   = ones(bin,3)*NaN;
    end
    
    % NOTE: we put together all collective decision in one matrix; we do not
    % separate per agent
    if flag_bin % only if we want to bin/normalize trajectories

        all_time_traj_index_coll(:,:,t) = time_traj_indexColl;
        all_time_traj_ulna_coll(:,:,t)  = time_traj_ulnaColl;
        all_spa_traj_index_coll(:,:,t)  = spa_traj_indexColl;
        all_spa_traj_ulna_coll(:,:,t)   = spa_traj_ulnaColl;

    else % only if we DO NOT bin/normalize trajectories

        % Note: we currently exclude trials that are too long
        % -> check setting of "max_samples" in calc_kin_init.m
        if length(time_traj_index1) > max_samples
            all_time_traj_index_coll(:,:,t) = NaN*ones(max_samples,3);
            all_time_traj_ulna_coll(:,:,t)  = NaN*ones(max_samples,3);
            all_spa_traj_index_coll(:,:,t)  = NaN*ones(max_samples,3);
            all_spa_traj_ulna_coll(:,:,t)   = NaN*ones(max_samples,3);
        else % for all trials with samples < max_samples (usual case)
            all_time_traj_index_coll(:,:,t) = [time_traj_indexColl;NaN*ones((max_samples-length(time_traj_indexColl)),3)];
            all_time_traj_ulna_coll(:,:,t)  = [time_traj_ulnaColl;NaN*ones((max_samples-length(time_traj_ulnaColl)),3)];
            all_spa_traj_index_coll(:,:,t)  = [spa_traj_indexColl;NaN*ones((max_samples-length(spa_traj_indexColl)),3)];
            all_spa_traj_ulna_coll(:,:,t)   = [spa_traj_ulnaColl;NaN*ones((max_samples-length(spa_traj_ulnaColl)),3)];
        end

    end
  
    caa = caa +3; % increase decision counter
    % -----------------------------------------------------------------

    % Check if 1st or 2nd decision has startFrame==NaN.
    % This means we should exclude the entire trial.
    % Thus: set all variables to NaN for this trial and increase counter.
    if not(early) && (isnan(startFrame1) || isnan(startFrame2) || isnan(startFrameColl))
        
        excl_trial = excl_trial + 1;

        if flag_bin
            startFrame1=NaN; tmove1=NaN; rt_final1=NaN; dt_final1=NaN; mt_final1=NaN; endFrame1=NaN;
            startFrame2=NaN; tmove2=NaN; rt_final2=NaN; dt_final2=NaN; mt_final2=NaN; endFrame2=NaN;
            startFrameColl=NaN; tmoveColl=NaN; rt_finalColl=NaN; dt_finalColl=NaN; mt_finalColl=NaN; endFrameColl=NaN;
            
            tindex1             = [NaN NaN NaN];
            tulna1              = [NaN NaN NaN];
            sindex1             = [NaN NaN NaN NaN];
            sulna1              = [NaN NaN NaN NaN];
            sdindex1            = [NaN NaN NaN NaN];
            time_traj_index1    = ones(bin,3)*NaN;
            time_traj_ulna1     = ones(bin,3)*NaN;
            spa_traj_index1     = ones(bin,3)*NaN;
            spa_traj_ulna1      = ones(bin,3)*NaN;
            tindex2             = [NaN NaN NaN];
            tulna2              = [NaN NaN NaN];
            sindex2             = [NaN NaN NaN NaN];
            sulna2              = [NaN NaN NaN NaN];
            sdindex2            = [NaN NaN NaN NaN];
            time_traj_index2    = ones(bin,3)*NaN;
            time_traj_ulna2     = ones(bin,3)*NaN;
            spa_traj_index2     = ones(bin,3)*NaN;
            spa_traj_ulna2      = ones(bin,3)*NaN;
            tindexColl          = [NaN NaN NaN];
            tulnaColl           = [NaN NaN NaN];
            sindexColl          = [NaN NaN NaN NaN];
            sulnaColl           = [NaN NaN NaN NaN];
            sdindexColl         = [NaN NaN NaN NaN];
            time_traj_indexColl = ones(bin,3)*NaN;
            time_traj_ulnaColl  = ones(bin,3)*NaN;
            spa_traj_indexColl  = ones(bin,3)*NaN;
            spa_traj_ulnaColl   = ones(bin,3)*NaN;

            all_time_traj_index_b(:,:,t)    = NaN*ones(bin,3);
            all_time_traj_ulna_b(:,:,t)     = NaN*ones(bin,3);
            all_spa_traj_index_b(:,:,t)     = NaN*ones(bin,3);
            all_spa_traj_ulna_b(:,:,t)      = NaN*ones(bin,3);
            all_time_traj_index_y(:,:,t)    = NaN*ones(bin,3);
            all_time_traj_ulna_y(:,:,t)     = NaN*ones(bin,3);
            all_spa_traj_index_y(:,:,t)     = NaN*ones(bin,3);
            all_spa_traj_ulna_y(:,:,t)      = NaN*ones(bin,3);
            all_time_traj_index_coll(:,:,t) = NaN*ones(bin,3);
            all_time_traj_ulna_coll(:,:,t)  = NaN*ones(bin,3);
            all_spa_traj_index_coll(:,:,t)  = NaN*ones(bin,3);
            all_spa_traj_ulna_coll(:,:,t)   = NaN*ones(bin,3);
        end
    end

    
    %% Create new data set
    % Now we add the newly computed parameters to the original Excel file
    % and create a new Excel file (a much bigger one): expData_xxx_kin_model

    if flag_bin % write the new Excel file ONLY FOR binned data

        % size of old header (from original Excel file)
        ol                         = size(txt_or);

        % ADD TIME VARIABLES (i.e., append to end of original Excel file)
        % -> variables are added for current trial t
        data{t,ol(2)+1:ol(2)+10}   = [changeMind(t) ...
                                      rt_final1 rt_final2 rt_finalColl ...
                                      dt_final1 dt_final2 dt_finalColl ...
                                      mt_final1 mt_final2 mt_finalColl];
        % ADD KINEMATIC DATA
        % -> normalized 100 samples for index and ulna only for 2nd DEC
        % NOTE: change var counter (1043) if new variables are added!!!
        data{t,ol(2)+11:ol(2)+1031} = [...
            time_traj_index2(:,1)' time_traj_index2(:,2)' time_traj_index2(:,3)' ...
            time_traj_ulna2(:,1)' time_traj_ulna2(:,2)' time_traj_ulna2(:,3)' ...
            spa_traj_index2(:,1)' spa_traj_index2(:,3)' ...
            spa_traj_ulna2(:,1)' spa_traj_ulna2(:,3)' ...
            startFrame1 tmove1 endFrame1 ...
            startFrame2 tmove2 endFrame2 ...
            startFrameColl tmoveColl endFrameColl ...
            trgChange1 trgChange2 trgChangeColl ... % did agent change target on the fly?
            str2double(mod1) str2double(mod2) str2double(modColl) ... % did we change the figure manually?
            pksInd1.npIndex pksInd2.npIndex pksIndColl.npIndex ... % number of velocity peaks index
            pksUlna1.npUlna pksUlna2.npUlna pksUlnaColl.npUlna]; % number of velocity peaks ulna                      
        
        % Now add peak structures (values and locations of velocity peaks)
        data{t,ol(2)+1032:ol(2)+1043} = [...
            {pksInd1.peaks_index'} {pksInd2.peaks_index'} {pksIndColl.peaks_index'}...
            {pksUlna1.peaks_ulna'} {pksUlna2.peaks_ulna'} {pksUlnaColl.peaks_ulna'}...
            {pksInd1.peak_loc_index'} {pksInd2.peak_loc_index'} {pksIndColl.peak_loc_index'}... 
            {pksUlna1.peak_loc_ulna'} {pksUlna2.peak_loc_ulna'} {pksUlnaColl.peak_loc_ulna'}];

        % Assign new header (created in calc_kin_rt_mt.m)
        data.Properties.VariableNames = txt;

        % -----------------------------------------------------------------
        % Here we merge the backup .mat file with the new data table 
        if str2double(crash)
            data(1:trialstart_num-1,:) = data_bkp(1:trialstart_num-1,:);
            crash = '0';
        end % -------------------------------------------------------------

               
        % write the new Excel file
        if flag_write
            overwriteFile = true; % Default to overwriting or creating new file.
            filenameExcel = fullfile(path_kin,['expData_' SUBJECTS{p}(2:end) '_kin_model.xlsx']);
            if exist(filenameExcel,'file') == 2
                % if Excel file already exists, ask user before overwriting
                promptMessage = sprintf('This file already exists:\n%s\nDo you want to overwrite it?', filenameExcel);
                titleBarCaption = 'Overwrite?';
                % ButtonName = questdlg(Question, Title, Btn1, Btn2, DEFAULT);
                buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
                if strcmpi(buttonText, 'No') % User does not want to overwrite.
                    overwriteFile = false;
                end
                if overwriteFile % User wants to overwrite: delete old file and write new file
                    delete(filenameExcel);
                    writetable(data,filenameExcel);
                end
            else
                writetable(data,filenameExcel);
            end
        end

    end % end of adding data to Excel file

    % EXIT and SAVE mat file if user decided to exit early
    % NOTE: data is always saved after 1 full trial, i.e., a loop of 3 decisions
    % (the filename will indicate the last processed trial, e.g., is user
    % exits in trial 9, then the file will be called "_end9")
    if any([savemat1,savemat2,savematColl])
        % CAREFUL: if you re-name this file (the "_end"-part), then the
        % bkp-function will NOT WORK anymore (see userInput, line 41 where the
        % trial number is identified by checking last part of file name)
        save(fullfile(path_kin,[SUBJECTS{p},'_end',num2str(t),'_bkp']));
        disp(['BACKUP MATFILE HAS BEEN SAVED SUCCESSFULLY after trial ', num2str(t), '. Exit now.']); fprintf(1, '\n');
        break
    end

end % end of trial loop (i.e., all trials for one pair were completed)

% script version: 1 Nov 2023