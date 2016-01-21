%% auto deplyment
clc
fprintf('\n Welcome to the auto-deployment script: \n   Just press and deploy into Px4 \n');

%% Detect simulink files and check if project exist

fprintf(' \n Select the simulink model to be deployed as DBX FCS \n');

% inp = input('What is the original value? ','s');
[FileName,PathName] = uigetfile('*.slx',' Select the simulink model to be deploy as DBX FCS');

curr = pwd;

try
    cd C:\px4\Firmware\src\Modules
catch
    errordlg(sprintf([' No Px4 development files detected:\n',...
        '    Please ensure that you installed Px4 files in C:/px4/Firmware \n']),' No Px4 development files detected')
end
clear files
files = dir;

if ~sum( strcmp(FileName(1:end-4),{files(:).name}) )
    cd(curr)
    errordlg(sprintf([' You have NOT created a Px4 app for this Simulink proyect:\n',...
        '    * The app FOLDER in Px4 should have the same name as Simulink model\n',...
        '    * Once deployed, the app will be called dbx_control\n',...
        '    * Create the appropiate app folder and the appropiate Wrapper for this simulink Model!\n',...
        '    * Configure the Px4 Makefiles to compile this new app with name as the Simunlk model \n']),'NO Px4 app file detected')
    return
end

%% Rename, move and codegen
new_dir = ['C:\px4\Firmware\src\Modules\',FileName(1:end-4)];
cd(new_dir)
if exist('dbx_control.slx', 'file')==4
  delete('dbx_control.slx');
end
pause(0.5)
copyfile([PathName,FileName],[new_dir,'\dbx_control.slx'])
pause(0.5)

slbuild('dbx_control')

%% Deployment



try
    cd('C:\px4\toolchain\msys\1.0')
    delete('px4_Simulink_deploy.sh')
catch
    errordlg('You dont have the appropiate toolchain installed')
    return
end


SH = ['C:\px4\toolchain\msys\1.0\px4_Simulink_deploy.sh'];
copyfile([curr,'\px4_Simulink_deploy.sh'],SH)

system('.\bin\sh.exe --login -i C:\px4\toolchain\msys\1.0\px4_Simulink_deploy.sh')

cd(curr)

