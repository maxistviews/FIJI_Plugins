// Opens a lif file, gets all tilescan merges and closes the single files,
// then saves a tiff with all channels and tiffs of the individual green and red channels.

// Importer for Files with several series such as Leica .lif files. Copied from openLifTilescans.ijm
// The script opens all series and then closes all images that are not TileScan merges

// Create a prompt window to select the file

loggerSanitize = false;
logger = false;
DEFAULT_DIR = "J:/2023 Screen/";
DEFAULT_CHANNELS = true;
DEFAULT_NAMES = false;

BATCH_MODE = true;

Dialog.create("Browse .lif file");
	Dialog.addFile("File:", DEFAULT_DIR);
	//  Dialog.addFile("File:","G:/2023 Screen/aPKC RNAi/2023 05 May aPKC 4 GFP.lif");
  	// Dialog.addDirectory("Save to:","G:/2023 Screen/aPKC RNAi/2023 05 May aPKC 4 GFP");
	//Dialog.addFile("File:","\\\\mesawest/Old Photo/TEPASS LAB/2023 Screen/aPKC RNAi/2023 05 May aPKC 4 GFP.lif");
	Dialog.addMessage("OPTIONAL:");
	Dialog.addCheckbox("Save Channels Seperately", DEFAULT_CHANNELS);
	Dialog.addCheckbox("Custom Channel Names:", DEFAULT_NAMES);
	Dialog.addMessage("Channels will be named automatically after LUTs used, but you can change them here:");
	Dialog.addString("Channel 1 Name:","DAPI");
	Dialog.addString("Channel 2 Name:","GFP");
	Dialog.addString("Channel 3 Name:","RFP");
	Dialog.addString("Channel 4 Name:","YFP");
	Dialog.show();

dialogFile = Dialog.getString();
dialogOptionSeperateChannels = Dialog.getCheckbox();
dialogOptionCustomChannelNames = Dialog.getCheckbox();
channelNames = newArray(4);

for (i=0; i < 4; i++) {
    channelNames[i] = Dialog.getString();
}

function getIncrementedBaseName(baseName, directory) {
    // Check for incremented base names, starting from 01
    for (i = 1; i <= 99; i++) { // Assuming a max of 99 incremented files
        // Format the number with a leading zero if needed
        if (i < 10) {num = "0" + i;} else {num = "" + i;}
        indexedBaseName = baseName + "-" + num;
        if (logger){
			print("num:" + num);
			print("indexedBaseName:" + indexedBaseName);
		}
        if (!File.exists(directory + indexedBaseName)) {
			if (logger){
				print("File not found. Creating.");
				print("directory+indexedBaseName:"+directory + indexedBaseName);
			}
            return indexedBaseName;
        }
    }
    // If we reach here, we have more than 99 incremented files. Handle appropriately.
    return null;
}

function sanitizeFileName(fileName) {
    if (loggerSanitize) {
        print("sanitizeFileName has been called.");
        print("Initial fileName: " + fileName);
    }

    illegalChars = "<>:\"/\\|?*";
    for (i = 0; i < illegalChars.length(); i++) {
        char = substring(illegalChars, i, i+1);  // Use substring instead of charAt
        fileName = replace(fileName, char, "_");  // Replace without checking, it's ok for short strings
        if (loggerSanitize) {print("Replaced (if present) " + char + " with _. New fileName: " + fileName);}
    }
    
    if (loggerSanitize) {print("Final sanitized fileName: " + fileName);}
    print("Returning from sanitizeFileName: " + fileName);
	return fileName;
}

function getChannelNumber() {
	var channelNumber = Property.getNumber(" SizeC");
	if (isNaN(channelNumber)) { 
		var width, height, channels, slices, frames;
		getDimensions(width, height, channels, slices, frames);
		channelNumber = channels;
	}
	number = toString(channelNumber);
	return number;
}

function saveChannelTiffs(channelNumber, indexedBaseName, fullDirImageName, channelNames) {
	// TODO: DAPI is 4th somehow GFP is 3rd - "red". Red is green 2nd and yellow is blue.
	for (j=1; j<=channelNumber; j++) {
		if (logger) { print("Starting looking at Channel " + j);}
		// channelTitle = "C"+j+"-"+indexedBaseName + ".tif";
		channelTitle = "C"+j+"-"+indexedBaseName;


		if (logger) { print("Looking for: " + channelTitle); }
		if (isOpen(channelTitle)){
			selectImage(channelTitle);
		}
		else{
			print("Image: " + channelTitle + " not found!");
			Dialog.createNonBlocking("Image not found!");
				Dialog.addMessage("Image: " + channelTitle + " not found!");
				Dialog.addImageChoice("Find *Channel " + j + " Image", channelTitle+"*");
				Dialog.show();
			channelTitle = Dialog.getImageChoice();
			selectImage(channelTitle);
		}

		LUTNameVar = isolatedImageName + " Image #0|ChannelDescription #" + (j-1) +"|LUTName";

		if (logger) {print("LUTNAME = " + LUTNameVar);}

		LUTName = getInfo(LUTNameVar);
		// print("Wavelength: " + wavelength +"\n LUTname: " + LUTName);

		// fullDirImageSaveName = fullDirImageName + " - C" + j + " "+ channelNames[j-1] + ".tif";
		// fullDirImageSaveName = fullDirImageName + " - C" + j + " "+ LUTName + " " + wavelength + ".tif";
		
		// Override LUTName with channelNames if dialogOptionCustomChannelNames is true
        if (dialogOptionCustomChannelNames) {
            LUTName = channelNames[j-1];
        }
		fullDirImageSaveName = fullDirImageName + " - C" + j + " "+ LUTName + ".tif";
		saveAs("Tiff", fullDirImageSaveName);
		
		if (logger) { print("Saved: " + fullDirImageSaveName);}
		close();
	}
}



// Script start running here
setBatchMode(BATCH_MODE);

    
run("Bio-Formats Importer", "open=["+dialogFile+"] color_mode=Composite open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");



dir = getInfo("image.directory");
lifFileName = getInfo("image.filename");
// name of file = foldername
//folderName = sanitizeFileName(substring(lifFileName , 0, indexOf(lifFileName, ".lif")));

//folderNameDirty Removes the .lif from the folder name
folderNameDirty = substring(lifFileName , 0, indexOf(lifFileName, ".lif"));


//Cleans the foldername from illegal characters
folderName = sanitizeFileName(folderNameDirty);
// folderName:2023 09 15 Xpd x Crb DAPI phal

exportDir = dir+folderName+"\\";

	if (logger) {
		print("lifFileName:" + lifFileName);
		print("folderNameDirty: " +folderNameDirty);
		print("folderName:" + folderName);
	}

if (!File.isDirectory(exportDir)) { 
	File.makeDirectory(exportDir); 
}

// get a list of all files open
// Will print the list out here
listMerges = getList("image.titles");
print(listMerges.length + " stacks found:");
for (list=0; list<listMerges.length; list++){
	print("  ---" + listMerges[list]);
}


for (i=0; i<listMerges.length; i++) {
		if (logger) {print("i ="+(i+1)+"/"+ listMerges.length +" looking at "+listMerges[i]);}
	selectWindow(listMerges[i]);
	
	//Gives the whole title: "2023 05 May aPKC 4 GFP.lif - TileScan 2/Position 2"
	imageWholeTitle = getInfo("image.title");
	// Get everything after the last dash in the title: "TileScan 2/Position 2"
	lastDash = lastIndexOf(imageWholeTitle, "-");
	
	if (lastDash != -1) {
		isolatedImageName = trim(imageWholeTitle.substring(lastDash + 1)); // trim to remove any extra spaces
		//isolatedImageName = "TileScan 2/Position 2"
	} else {
		print("PROBLEM WITH FINDING IMAGE NAME!");
		isolatedImageName = imageWholeTitle;
	}

	//If isolatedImageName has some illegal characters, get rid of those.
	cleanImageName = sanitizeFileName(isolatedImageName);
	
	selectWindow(listMerges[i]);
	channelNumber = getChannelNumber();
	
	//Make the folder where the file will be located
	fullDirImageName = exportDir+folderName+" - "+cleanImageName;

	if (logger) {
		print("Isolated Image Name: " + isolatedImageName);
		print("cleanImageName:" + cleanImageName);
		print("channelNumber: " + channelNumber);
		print("fullDirImageName :" + fullDirImageName);
		// 	Isolated Image Name: Series002
		// 	cleanImageName:Series002
		// 	channelNumber: 3
		// 	fullDirImageName :Z:\TEPASS LAB\2023 Screen\Xpd RNAi\2023 09 15 Xpd x Crb DAPI phal\2023 09 15 Xpd x Crb DAPI phal - Series002
	}
	
	// Save the file that has all channels?
	if (!File.isDirectory(fullDirImageName +".tif")) {

		saveAs("Tiff", fullDirImageName +" - All Channels.tif");
		savedAllChannelTitle = getTitle();
		if (logger) {print("Saved: " + savedAllChannelTitle);}

		indexedBaseName = folderName+" - "+cleanImageName; // "2023 09 15 Xpd x Crb DAPI phal"+" - "+"Series002" = "2023 09 15 Xpd x Crb DAPI phal - Series002"
		selectImage(savedAllChannelTitle);
		rename(indexedBaseName);
	} else {
		indexedBaseName = folderName+" - "+getIncrementedBaseName(isolatedImageName, exportDir); //
		rename(indexedBaseName);
		
	}
	// real name = "C2-2023 05 May aPKC 4 GFP - TileScan 2_Position 1.tif
	// channeltitle = "C1-2023 05 May aPKC 4 GFP - TileScan 2_Position 1"
	selectImage(indexedBaseName);
	//run("Split Channels");

	if (channelNumber > 1) {
		runMacro("SplitChannels.ijm","false");
		print("Split channels for  " + indexedBaseName + " With "+channelNumber+ " channels.");
		if (dialogOptionSeperateChannels == true) {
			saveChannelTiffs(channelNumber, indexedBaseName, fullDirImageName, channelNames);
		}
	} else {
		close();
	}

	print("Trying to close: " + listMerges[i]);
	
//	close();

}
print("Done!");
