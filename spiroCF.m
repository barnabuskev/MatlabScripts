function spiroCF
% Function to obtain data from the datalab2000 spirometer as well as experiment metadata
% 
% VERSION FOR CLAIR FARAGHER
% 
% version v2016
% 2016 K Brownhill
% config values
% ~~~~~~~~~~~~~
% sample rate
sr = 100;
% probability of repeating
prbrep = 0.15;
% Experiment conditions - first col is condition name, 2nd col is key (in capitals)
conds = {'Fashion bra','F';'Sports bra','S';'T shirt','T'};
% ~~~~~~~~~~~~~
%set up apparatus
rdy = input('\n Press ''Return'' when the spirometer is set up and plugged in... '); %#ok<NASGU>
chn = [];
wrg = true;
while wrg
    rdy = input('\n What channel is the amplifier in? (0 - 15)  ');
    if rdy>=0 && rdy<=15
        wrg = false;
        chn = rdy;
    else
        sprintf('%s','You have entered an incorrect channel number. Try again... ')
    end
end
%get directory to store data
datdir = uigetdir(pwd,'Get directory where readings will be stored... ');
if datdir == 0
    sprintf('%s','No directory chosen! Quitting ''spiroCF''')
    return
end
cd(datdir)
disp('Please wait...')
% %set up AI
AI = analoginput('nidaq','Dev1');
addchannel(AI,chn);
set(AI,'SampleRate',sr);
set(AI,'TriggerType','Immediate');
set(AI,'SamplesPerTrigger',inf);
set(AI,'InputType','SingleEnded')
% keep getting subject data
sbjcnt = 1;
while true
    %calibrate spirometer if necessary
    if sbjcnt==1
        sprintf('%s','Spirometer needs to be calibrated...');
        smpls = 200;
        set(AI,'SamplesPerTrigger',smpls);
        input('Set spirometer to zero litre mark and hold. Press ''Return'' when ready... ');
        start(AI);
        wait(AI,smpls/sr+1);
        tmp = getdata(AI);
        zeromu = mean(tmp);
        input('Set spirometer to 10L mark and hold. Press ''Return'' when ready... ');
        start(AI);
        wait(AI,smpls/sr+1);
        tmp = getdata(AI);
        tenmu = mean(tmp);
        set(AI,'SamplesPerTrigger',inf)
    end
    %get subject code
    sprintf('\n');
    sbj = input('Enter subject code (press ''Return'' to exit)... ','s');
    if isempty(sbj)
        disp('spiro is exiting');
        delete(AI)
        return
    end
    %get which phase of experiment...
    %empty string to store experiment phase (conditions)
    phs = '';
    % set delimiter
    delimatm = {', ',' = '};
    % make delimiter longer if more than 2 conditions
    repstr = repmat(delimatm, 1, size(conds,1) - 1);
    % make conds flat and then insert delimiters
    condstr = strjoin(reshape(conds',1,numel(conds)),[{' = '},repstr]);
    while isempty(phs)
        % get user choice
        phs = input(['Which phase of the experiment is this? ',condstr,'  '],'s');
        if ~any(strcmpi(phs,conds(:,2)))
            sprintf('%s','Incorrect option chosen');
            phs = '';
        end
    end
    % Get data
    % which row chosen?
    [I,J] = find(strcmpi(conds,phs)); %#ok<NASGU>
    % print message
    sprintf('%s',[conds{I,1},' chosen']);
    spirodat = obtdat(AI,zeromu,tenmu); %#ok<NASGU>
    save([datdir,filesep,'data','_',sbj,'_',conds{I,1}],'spirodat');
    if prbrep > rand(1,1)
        sprintf('\n')
        disp('Do this measurement again for reliability estimation');
        spirodat = obtdat(AI,zeromu,tenmu); %#ok<NASGU>
        save([datdir,filesep,'data','_',sbj,'_',conds{I,1},'_','rep'],'spirodat');
    end
    sbjcnt = sbjcnt + 1;
end

function out = obtdat(aiobj,zeromu,tenmu)
%get data of single breath
getmore = true;
while getmore
    input('Press ''Return'' when ready to record data');
    start(aiobj);
    input('Press ''Return'' to stop recording data');
    stop(aiobj);
    smpavl = get(aiobj,'SamplesAvailable');
    [dat,tme] = getdata(aiobj,smpavl);
    dat = (dat-zeromu)/(tenmu-zeromu)*10;
    plot(tme,dat);
    xlabel('Time (seconds)')
    ylabel('Volume (litres)')
    yn = '';
    while isempty(yn)
        yn = input('Is this data ok? (Y or N)... ','s');
        if ~any(strcmp(yn,{'Y','y','N','n'}))
            sprintf('%s','Incorrect option chosen');
            yn = '';
        end
    end
    close(gcf)
    if strcmpi(yn,'Y')
        out = [dat,tme];
        getmore = false;
    end
end
