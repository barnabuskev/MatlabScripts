function yogabreath
%function to measure FEV1 and VC for yoga breathing experiment
%2012 K Brownhill
%set up apparatus
rdy = input('\n Press ''Return'' when the spirometer is set up and plugged in... ');
chn = [];
wrg = true;
while wrg
    rdy = input('\n What channel is the amplifier in? (0 - 15)');
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
    sprintf('%s','No directory chosen! Quitting ''yogabreath''')
    return
end
cd(datdir)
% %set up AI
AI = analoginput('nidaq','Dev1');
addchannel(AI,chn);
%samplerate
sr = 100;
set(AI,'SampleRate',sr);
set(AI,'TriggerType','Immediate');
set(AI,'SamplesPerTrigger',inf);
set(AI,'InputType','SingleEnded')
%probability of repeating
prbrep = 0.15;
% keep getting subject data
sbjcnt = 1;
while true
    %calibrate spirometer if necessary
    if sbjcnt==1
        sprintf('%s','Spirometer needs to be calibrated...');
        smpls = 200;
        set(AI,'SamplesPerTrigger',smpls);
        input('Set spirometer to zero and press ''Return'' when ready... ');
        start(AI);
        wait(AI,smpls/sr+1);
        tmp = getdata(AI);
        zeromu = mean(tmp)
        input('Set spirometer to 10 and press ''Return'' when ready... ');
        start(AI);
        wait(AI,smpls/sr+1);
        tmp = getdata(AI);
        tenmu = mean(tmp)
        set(AI,'SamplesPerTrigger',inf)
    end
    %get subject code
    sprintf('\n');
    sbj = input('Enter subject code (press ''Return'' to exit)... ','s');
    if isempty(sbj)
        disp('yogabreath is exiting');
        delete(AI)
        return
    end
    %get which phase of experiment
    phs = '';
    while isempty(phs)
        phs = input('Which phase of the experiment is this? (B=before intervention,A=after intervention)  ','s');
        if ~any(strcmp(phs,{'B','b','A','a'}))
            sprintf('%s','Incorrect option chosen');
            phs = '';
        end
    end
    phs = upper(phs);
    switch phs
        case 'B'
            sprintf('%s','Before intervention chosen');
            Bdat = obtdat(AI,zeromu,tenmu);
            save([datdir,filesep,'data',sbj,'B'],'Bdat');
            if prbrep > rand(1,1)
                sprintf('\n')
                disp('Do this measurement again');
                Bdatrep = obtdat(AI,zeromu,tenmu);
                save([datdir,filesep,'data',sbj,'Brep'],'Bdatrep');
            end
        case 'A'
            sprintf('%s','After intervention chosen');
            Adat = obtdat(AI,zeromu,tenmu);
            save([datdir,filesep,'data',sbj,'A'],'Adat');
            if prbrep > rand(1,1)
                sprintf('\n')
                disp('Do this measurement again');
                Adatrep = obtdat(AI,zeromu,tenmu);
                save([datdir,filesep,'data',sbj,'Arep'],'Adatrep');
            end
    end
    sbjcnt = sbjcnt + 1;
end

function out = obtdat(aiobj,zeromu,tenmu)
%get data
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
    yn = upper(yn);
    close(gcf)
    if strcmp(yn,'Y')
        out = [dat,tme];
        getmore = false;
    end
end


