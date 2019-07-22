macro "Holly Boxer Action Tool - B44C000T0408HT6408B" {
	
	/*
	 * This tool was made by Jacob Smith at MCRI in December 2018 to aid the user is counting cells in large 
	 * numbers of histological sections. This tool breaks down the image into a smaller random section. The
	 * user then counts the number of cells and the next image is loaded. The macro then calculates the cell
	 * density and total cells per images and saves the output as a csv file for data analysis.
	 */
	
	setOption("ExpandableArrays", true);

	//Prompt use to choose some options
	Dialog.create("Options");
	Dialog.addCheckbox("Would you like to save the output?", false);
	Dialog.addCheckbox("Would you like to specify the count area?", false);
	Dialog.addCheckbox("Would you like to record cell numbers?", false);
	
	Dialog.show();
	saveCheck = Dialog.getCheckbox();
	manual = Dialog.getCheckbox();
	record = Dialog.getCheckbox();

	//Asks the user to define the size of the crop area in um
	if (manual == true){
		Dialog.create("Insert dimensions");
		Dialog.addNumber("Width", 0);
		Dialog.addNumber("Height", 0);
		Dialog.show();
		manualWidth = Dialog.getNumber();
		manualHeight = Dialog.getNumber();
	}

	//Prompts the user to define the save location for cropped images or cell count .csv file
	if (saveCheck == true){
		savePath = getDirectory("Choose a Directory to save");
	}

	if (record == true){
		if (saveCheck == true){
			savePathCounts = savePath;
		}
		else {
			savePathCounts = getDirectory("Choose a Directory to save cell counts");
		}
	}

	//Define some variables
	imageDir = newArray();
	imageDir = getDirectory("Choose a Directory");
	FileList = newArray();
	FileList = getFileList(imageDir); //Adds all filenames to the array in the selected folder
	cellCountList = newArray();
	

	//Enter the main loop of the macro which allows it to open all the images in the selected folder
	for (i = 0; i < FileList.length; i++){
		
		open(FileList[i]);
		if (i == 0){ // first run
			//image is 345.48um x 259.11um (for Holly's images  at least)
			run("Set Scale...", "distance=370.5 known=50 pixel=1 unit=um global");
			fullWidth = getWidth();
			fullHeight = getHeight();
			if (manual == true){
				manualWidth = manualWidth * (370.5/50);
				manualHeight = manualHeight * (370.5/50);
			}
		}
		
		randCrop(); //Runs the random crop function to randomly crop the desired image
		
		if (record == true){ //Prompts the user to input the number of counted cells
			Dialog.create("Insert cell count");
			Dialog.addNumber("Number", 0);
			Dialog.show();
			cellCount = Dialog.getNumber();

		}
		while (!isKeyDown("space")) { //This allows the user to take time while counting
		    wait(10);
		}

		//Runs some calculations to determine total cells
		if (record == true){
			if (manual == true){
				cellDensity = cellCount / ((manualWidth/(370.5/50)) * (manualHeight/(370.5/50)));
				totalCells = cellDensity * ((fullWidth /(370.5/50)) * (fullHeight /(370.5/50)));
			}
			else {
				cellDensity = cellCount / ((fullWidth/2)/(370.5/50) * (fullHeight/2)/(370.5/50));
				totalCells = cellDensity * ((fullWidth/(370.5/50)) * (fullHeight/(370.5/50)));
			}
			
			setResult("Image Name", i, FileList[i]);
			setResult("Amount Counted", i, cellCount);
			setResult("Total Cells", i, totalCells);
			setResult("Cell Density", i, cellDensity);
			updateResults();
		}
		if (saveCheck == true){
			close(FileList[i]+" cropped.tiff");
			close(FileList[i]);
		}
		else {
			close(FileList[i]);
		}
	}

	//Saves the calculated results
	if (record == true){
		saveAs("Results", savePathCounts + "Cell Count Results.csv");
	}
}

function randCrop(){
	//If the user didn't select a manual area, the macro crops to 1/4 of the image
	if (manual == false){
		makeRectangle(random*(fullWidth/2), random*(fullHeight/2), fullWidth/2, fullHeight/2);
	}
	//If manual is selected, the macro must take the floor of the random region division to stop 
	//the region being selected being outside the image itself
	else if(manual == true) {
		calcWidth = fullWidth-manualWidth;
		calcHeight = fullHeight-manualHeight;
		makeRectangle(floor(random*calcWidth), floor(random*calcHeight), manualWidth, manualHeight);
	}
	
	run("Crop");

	//Saves each cropped section if desired (for later analysis / validation)
	if (saveCheck == true){
		saveAs("tiff",savePath+FileList[i]+" cropped.tiff");
	}
} 