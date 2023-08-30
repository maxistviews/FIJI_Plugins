// Opens a lif file, gets all tilescan merges and closes the single files,
// then saves a tiff with all channels and tiffs of the individual green and red channels.

// Importer for Files with several series such as Leica .lif files. Copied from openLifTilescans.ijm
// The script opens all series and then closes all images that are not TileScan merges

// Create a prompt window to select the file

loggerSanitize = false;
logger = true;

Dialog.create("Browse file");
	Dialog.addFile("File:","\\\\mesawest/Old Photo/TEPASS LAB/2023 Screen/aPKC RNAi/2023 05 May aPKC 4 GFP.lif");
	Dialog.addMessage("Please name the channels. Only the channels in your file will be named.");
	Dialog.addString("Channel 1 Name:","DAPI");
	Dialog.addString("Channel 2 Name:","GFP");
	Dialog.addString("Channel 3 Name:","RFP");
	Dialog.addString("Channel 4 Name:","YFP");
//  Dialog.addFile("File:","G:/2023 Screen/aPKC RNAi/2023 05 May aPKC 4 GFP.lif");
  // Dialog.addDirectory("Save to:","G:/2023 Screen/aPKC RNAi/2023 05 May aPKC 4 GFP");
	Dialog.show();

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
				print("File not found. Creating."
				print("directory+indexedBaseName:"+directory + indexedBaseName);
			}
            return indexedBaseName;
        }
    }
    // If we reach here, we have more than 99 incremented files. Handle appropriately.
    return null;
}

function sanitizeFileName(fileName) {
//	newname = fileName+"TEST";
//	return newname;
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

file = Dialog.getString();
channelNames = newArray(4);
for (i=0; i < 4; i++) {
    // This assumes that you've prompted the user for channel names via Dialog boxes.
    channelNames[i] = Dialog.getString();
}


setBatchMode(false);
    
run("Bio-Formats Importer", "open=["+file+"] color_mode=Composite open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");



dir = getInfo("image.directory");
lifFileName = getInfo("image.filename");
print("lifFileName:" + lifFileName);
// name of file = foldername
//folderName = sanitizeFileName(substring(lifFileName , 0, indexOf(lifFileName, ".lif")));
folderNameDirty = substring(lifFileName , 0, indexOf(lifFileName, ".lif"));

print("folderNameDirty: " +folderNameDirty);
folderName = sanitizeFileName(folderNameDirty);
print("Debug: folderName is " + folderName);
exportDir = dir+folderName+"\\";

if (!File.isDirectory(exportDir)) { 
	File.makeDirectory(exportDir); 
}


listMerges = getList("image.titles");
print(listMerges.length + " stacks found:");
for (list=0; list<listMerges.length; list++){
	print("  -- 	--" + listMerges[list]);
}


for (i=0; i<listMerges.length; i++) {
	print("i ="+i+"/"+ listMerges.length +" looking at "+listMerges[i]);
	selectWindow(listMerges[i]);
	
	imageWholeTitle = getInfo("image.title"); //"2023 05 May aPKC 4 GFP.lif - TileScan 2/Position 2"
	lastDash = lastIndexOf(imageWholeTitle, "-");
	
	if (lastDash != -1) {
		isolatedImageName = trim(imageWholeTitle.substring(lastDash + 1)); // trim to remove any extra spaces
		//isolatedImageName = "TileScan 2/Position 2"
	} else {
		print("PROBLEM WITH FINDING IMAGE NAME!");
		isolatedImageName = imageWholeTitle;
	}
	
	// fileName = listMerges[i];
	print("Isolated Image Name: " + isolatedImageName);
		
	cleanImageName = sanitizeFileName(isolatedImageName);
	

	print("cleanImageName:" + cleanImageName);

	selectWindow(listMerges[i]);
	channelNumber = getChannelNumber();
	print("channelNumber: " + channelNumber);
	
	//Make the folder where the file will be located
	fullDirImageName = exportDir+folderName+" - "+cleanImageName;
	print("fullDirImageName :" + fullDirImageName);
	
	if (!File.isDirectory(fullDirImageName +".tif")) { 
		saveAs("Tiff", fullDirImageName +".tif");
		indexedBaseName = folderName+" - "+cleanImageName;
	} else {
		indexedBaseName = folderName+" - "+getIncrementedBaseName(isolatedImageName, exportDir);
		
	}
	// real name = "C2-2023 05 May aPKC 4 GFP - TileScan 2_Position 1.tif
	// channeltitle = "C1-2023 05 May aPKC 4 GFP - TileScan 2_Position 1"
	selectImage(indexedBaseName +".tif");
	run("Split Channels");
	
	print("Split channels for  " + indexedBaseName + " With "+channelNumber+ " channels.");

	for (j=1; j<=channelNumber; j++) {
		print("Starting looking at Channel " + j);
		channelTitle = "C"+j+"-"+indexedBaseName+".tif";
		print("Looking for: " + channelTitle);
		selectImage(channelTitle);
		saveAs("Tiff", fullDirImageName + "- C" + j + " "+ channelNames[j-1] + ".tif");
		
		if (logger) { print("Saved: " + fullDirImageName + "- C" + j + " "+ channelNames[j-1] + ".tif");}
		close();
	}
	print("Trying to close: " + listMerges[i]);
	
//	close();

}
print("Done!");