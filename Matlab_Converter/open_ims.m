%IMS to AVI file converter v1.3 20190410
%Written by Jacob Smith at MCRI
%Added ability to open files in different folders, and save the output in a
%different folder. Also delete the .tif images generated in the process. 
%Removed need to specify the path each time.
%Added parallel processing to improve speed

clear;

%Add the folder containing the .ims conversion script to the path
addpath('ImarisReader-master');

%Select the open and save locations and add to path
location = uigetdir('Select a folder');
addpath(location);

saveLocation = uigetdir('Select a folder to save');
addpath(saveLocation);

%Open the desired .ims and save its frame length to z
files = dir(fullfile(location, '*.ims')); %use files.name to access the file names

%Loop through all the .ims in the folder (using parallel processing)
parfor j = 1: 1: length(files)
    
    fileObj = ImarisReader(files(j).name);
    %Extract number of frames in the .ims file
    z = fileObj.DataSet.SizeT;

    %Loop through all the frames in the ims file
    for i = 1: 1:z-1
        %Extract the pixel data for one frame, and transpose it to fit the
        %correct orrientation
        vol = fileObj.DataSet.GetDataSlice(0, 0 ,i);
        vol = vol.';
        %Convert the matrix to a greyscale image, and resize 
        I = mat2gray(double(vol));
        resized = imresize(I, [640 540]); %640 by 540 pixels
        %Save the image to a tif, then add to the tif sequence
        saveName = extractBefore(files(j).name, '.ims');
        
        %Add leading zeros to the file name to make it work with the Dyno software
        %Above 9999 files will not add leading zeros
        if (j < 10)
            zeros = '000';
        elseif (j >= 10 && j < 100)
            zeros = '00';
        elseif (j >= 100 && j < 1000)
            zeros = '0';
        else
            zeros = '';
        end
        saveNameZeros = strcat(zeros, num2str(j));
        
        saveNameTif = strcat(saveNameZeros, '.tif');
        if (i == 1)
            imwrite(resized, saveNameTif);
        else
            imwrite(resized, saveNameTif, 'WriteMode', 'append')
        end

    end

    %Generate an avi file
    saveNameAvi = strcat(saveNameZeros, '.avi');
    saveNameAviLoc = strcat(saveLocation, '\', saveNameZeros);
    avi = VideoWriter(saveNameAviLoc , 'Uncompressed AVI');
    avi.FrameRate = 50;
    open(avi);

    %Save each tif image to the avi file
    for k=1:z-1
        writeVideo(avi,imread(saveNameTif,k));
    end
    close(avi);
    %Delete the working .tif image afterwards
    delete (saveNameTif);
end
