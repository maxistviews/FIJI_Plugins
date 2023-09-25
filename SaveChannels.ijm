//Created by Max Shcherbina 2023
macro "Save Channels"{
    // USER SETTINGS:
    // Indicate which channel combinations to save as composites:
    channelIndex = newArray("1100","0101");

    // DEBUG SETTINGS:
    logger = true;
    loggerSanitize = true;
    loggercreateComposite = true;

    

    if (logger){print("----------------------------\n Starting Save Channels macro...");}

    function getIncrementedBaseName(baseName, directory) {
        // Check for incremented base names, starting from 01
        for (i = 1; i <= 99; i++) { // Assuming a max of 99 incremented files
            // Format the number with a leading zero if needed
            if (i < 10) {num = "0" + i;} else {num = "" + i;}
            indexedBaseName = baseName + "-" + num;
            // if (logger){
            //     print("num:" + num);
            //     print("indexedBaseName:" + indexedBaseName);
            // }
            if (!File.exists(directory + indexedBaseName + "- Composite.tif")) {
                return indexedBaseName;
            }
        }
        // If we reach here, we have more than 99 incremented files. Handle appropriately.
        return null;
    }
    function printCharacters(str) {
        for (i = 0; i < str.length(); i++) {
            char = str.charAt(i);
            if (char == "/") {
                print("Found forward slash at position: " + i);
            } else {
                print("Character at position " + i + " is: " + char);
            }
        }
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
        return fileName;
    }

    // If macro cant see the active window, it will try to find it with this.
    function handleImageSelectionError() {
        waitForUser("Image Selection Needed", "Please select the image you want to proceed with and then click OK.");
        activeImageID = getImageID(); // update the active image ID after user selection
    }

    function createComposite(indexedBaseName, channelIndex, saveDir) {
        // Generate the new image title based on channels
        
        if (loggercreateComposite) {print("(createComposite) Entering createComposite function...");}
    
    // Check the length of channelIndex
        if (channelIndex.length() != 4) {
            error("(createComposite) ChannelIndex passed is not 4 numbers long. It is: " + channelIndex.length());
        }
        if (loggercreateComposite) {
            print("(createComposite) indexedBaseName: " + indexedBaseName);
            print("(createComposite) channelIndex: " + channelIndex);
            print("(createComposite) channelIndex.length(): " + channelIndex.length());
            print("(createComposite) saveDir: " + saveDir);
        }
        
        // Check if "ChannelImageComposite" is open
        if (isOpen("ChannelImageComposite")) {
            selectImage("ChannelImageComposite");
        } else {
            exit("Couldn't find ChannelImageComposite");
        }

        if (!isOpen("ChannelImageCompositeWorking")) {
            // Duplicate the image for working
            run("Duplicate...", "title=[ChannelImageCompositeWorking] duplicate");
        }

        selectImage("ChannelImageCompositeWorking");

        newImageTitle = "";
        for (i = 0; i < channelIndex.length(); i++) {
            if (substring(channelIndex, i, i+1) == "1") {
                if (newImageTitle != "") { newImageTitle = newImageTitle + "+"; }
                // The first channel to be caught. Add it to the newImageTitle
                // i+1 because channel numbers start from 1
                newImageTitle = newImageTitle + (i + 1);
                if (loggercreateComposite) {print("(createComposite) Updated newImageTitle: " + newImageTitle);}
            } else {
                if (loggercreateComposite) {print("(createComposite) Skipping channel " + (i + 1));}
            }
        }

        newImageTitle = indexedBaseName + "- Channel " + newImageTitle + " Composite.tif";
        if (loggercreateComposite) {print("(createComposite) Final newImageTitle: " + newImageTitle);}

        // Create the composite
        // selectImage(imageTitle);
        // run("Duplicate...", "title=[" + newImageTitle + "] duplicate");
        Stack.setActiveChannels(channelIndex);
        run("Flatten"); // Flatten makes a copy of the image
        
        // Save the composite as Tiff
        saveAs("Tiff", saveDir + newImageTitle);
        if (loggercreateComposite) {print("(createComposite) Saved as Tiff: " + saveDir + newImageTitle);}
        close(newImageTitle);
        if (isOpen(saveDir + newImageTitle)) {
            waitForUser("Error", "(createComposite) Couldn't close the composite image.");
        }
        if (loggercreateComposite) {print("(createComposite) Exiting createComposite function...");}
    }


    originalTitle = getTitle(); //Returns the title of the current image.
    sanitizedOriginalTitle = sanitizeFileName(originalTitle);
    originalImageID = getImageID();
    
    dir = getDir("image"); //getDir("image") - Returns the path to the directory that the active image was loaded from.
    if (logger){print("dir line 90: " + dir);}

    if (dir == "null" || dir == "") {
        dir = Property.get("Location");
        if (dir == "null" || dir == "") {
            dir = Property.get("OriginalDirectory");
            if (dir == "null" || dir == "") {
                dir = getDir("Choose a Directory to save your images to");
                dirUserSelected = true;
            }
        }
    }

    if (logger){print("dir line 100: " + dir);}
    //We now for sure have the full file path.
    // dir line 100: \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock\2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16.lif

    baseFolder = substring(dir, 0, lastIndexOf(dir, "\\"));
    // baseFolder = \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock\

    if (endsWith(dir, ".lif")) {
        baseFolderName = substring(dir, lastIndexOf(dir, "\\")+1, indexOf(dir, ".lif"));
        // baseFolderName: 2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16
    } else if (endsWith(dir, ".tif")) {
        baseFolderName = substring(dir, lastIndexOf(dir, "\\")+1, indexOf(dir, ".tif"));
    } else {
        // Assume it doesnt have a file extension and just use it as the path.
        baseFolderName = substring(dir, lastIndexOf(dir, "\\")+1);
    }

    // Extract the name of the image from the filepath dir.
    // baseFolderName = substring(dir, lastIndexOf(dir, "\\")+1, indexOf(dir, ".lif"));
    // dir line 100 should show be: 2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16

    originalFileName = getInfo("image.filename"); //Gives nothing with a zStack?

    // originalFileName2 = getMetadata("Location");
    // originalFileName2 = Property.get("Location");
    // print("orginalFileName2:" + originalFileName2);
    // baseFolderName = substring(originalFileName2, 0, indexOf(originalFileName2, ".lif"));

    if (originalFileName == "") {
        print("originalFileName is empty string");
        print("originalFileName:" + originalFileName);
        print("originalTitle:" + originalTitle);
        originalFileName = originalTitle;
    }

    if (logger){print("originalFileName:" + originalFileName);}


    // Need to change this so that it is either .lif or .tif depending on what the file is.
    //baseFolderName = substring(originalFileName, 0, indexOf(originalFileName, ".lif"));
    // if (indexOf(originalFileName, ".lif") != -1) {
    //     baseFolderName = substring(originalFileName, 0, indexOf(originalFileName, ".lif"));
    // } else if (indexOf(originalFileName, ".tif") != -1) {
    //     baseFolderName = substring(originalFileName, 0, indexOf(originalFileName, ".tif"));
    // } else {
    //     print("Unsupported file extension. Expected .lif or .tif.");
    //     exit(); // Exit the macro if neither extension is found
    // }
    
    // Error handling for directory retrieval
    if (dir == "null" || originalFileName == "null") {
        showMessage("Error", "Unable to determine image directory. Choose where the image came from.");
        print("ERROR HANDLING RUN");
        dir = getDir("Choose a Directory");
        
        Dialog.create("Select Image");
            Dialog.addImageChoice("Select Channel " + i + " Image", channelImageName);
            Dialog.show();
        originalFileName = Dialog.getImageChoice();
    }

    
    // Confirm with user
    // waitForUser("Confirmation", "Adjust the image as needed and click OK when ready to proceed.");
    Dialog.createNonBlocking("Save Channel Options");
        Dialog.addMessage("Adjust the image as needed and click OK when ready to proceed.")
        Dialog.addCheckbox("Close original file at the end", false);  // Default unchecked
        Dialog.addCheckbox("Count Cells with MorphoLibJ (Pablo Sanchez Bosch's Scripts)", false);  // Default unchecked
        Dialog.setLocation(400,50);
        Dialog.show();

    closeOriginal = Dialog.getCheckbox();
    countCells = Dialog.getCheckbox();
    

    activeImageID = getImageID();

    // Assuming user confirmed the Z projection, this will now be the MAX_"title".
    //activeImageTitle = getInfo("window.title");

    // If no image is currently selected, prompt the user to select one
    if (nImages == 0 || !isOpen(activeImageID)) {
        waitForUser("No image selected", "Please select the image you want to proceed with and click OK.");
        activeImageID = getImageID();
    } else {
        activeImageID = getImageID();
    }

    selectImage(activeImageID);

    // Create the other windows for later.
    // run("Duplicate...", "title=[Quantification] duplicate");
	run("Duplicate...", "title=[ChannelImage] duplicate");
    print("This is dir before newFolder: " + dir);
    // Ensure folder exists (creating it if it doesn't)
    newFolder = baseFolder + "\\" + baseFolderName + "\\";
    if (logger) { print("newFolder location: " + newFolder);}
    // dir = \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock\2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16.lif
    // baseFolder = \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock\
    // baseFolderName = 2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16
    // newFolder = \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock\2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16.lif\MAX_2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16 - Series004 - All Channels\
    print("Line 217 newFolder: "+newFolder);

    if (!File.exists(newFolder)) {
        File.makeDirectory(newFolder);
    }

    // Get indexed base name
    indexedBaseName = getIncrementedBaseName(sanitizedOriginalTitle, newFolder);
    if (logger) {    
        print("indexedBaseName: " + indexedBaseName);
    }
    if (indexedBaseName == "null") {
        showMessage("Error", "Too many incremented files. Please check the directory and clean up if necessary.");
        exit();
    }

    //We now have three files - the original name, the quantification file and the channelImage file.
	//original - flatten this image and save two shots - one without the bar and one with.
    // For the composite image
    // selectImage(activeImageTitle);

    selectImage(activeImageID);


	run("Flatten");
    saveAs("Tiff", newFolder + indexedBaseName + "- Composite");
    
    var pixelUnit, pixelWidth, pixelHeight;
    getPixelSize(pixelUnit, pixelWidth, pixelHeight);
    
    // we need to be using a diff. variable, for merged images, this doesnt work as a good scale bar. too small. 
    // Voxel size: 0.3788x0.3788x1.9999 micron^3
    // Width:  720.8333 microns (1903)
    if (pixelWidth >= 0.400) { 
        scalebarWidth = 100;
    } else if (pixelWidth <= 0.399 && pixelWidth >= 0.100){
        scalebarWidth = 20;
    } else if (pixelWidth <= 0.099 && pixelWidth >= 0.020){
        scalebarWidth = 5;
    } else {
        scalebarWidth = 1;
    }

    // Create, save and close the scalebar image
    run("Scale Bar...", "width=" + scalebarWidth + " height=20 font=20 horizontal bold overlay");
    run("Flatten");
    //saveAs("jpeg", newFolder + indexedBaseName + "- Composite Scalebar");
    saveAs("Tiff", newFolder + indexedBaseName + "- Composite Scalebar");
    selectImage(indexedBaseName + "- Composite Scalebar.tif");
    close(indexedBaseName + "- Composite Scalebar.tif");

    // Now Deal with ChannelImage
    selectImage("ChannelImage");
    // Get the number of channels
    var width, height, channels, slices, frames;
    getDimensions(width, height, channels, slices, frames);
    numChannels = channels;
    print("Channels = " + numChannels);

    run("Duplicate...", "title=[ChannelImageComposite] duplicate");

    if (channelIndex[0] != "null") {
        // For each of the channel indexes, call the createComposite formula and add them to a closeComposite array, so that we can close them later one by one.
        closeComposite = newArray();
        for (i = 0; i < channelIndex.length; i++) {
            createComposite(indexedBaseName, channelIndex[i], newFolder);
            //indexedBaseName:  MAX_2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16 - Series004 - All Channels.tif z12-14-08
            //channelIndex:     1100
            //newFolder:        \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock\2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16\

            // // Need to check if the channelIndex has a 1 in the last 2 digits, it means the image must have 3-4 channels.
            // if (substring(channelIndex[i], 2, 3) == "1" || substring(channelIndex[i], 3, 4) == "1") {
            //     if (numChannels > 2) {
            //         // closeComposite[i] = createComposite(indexedBaseName, channelIndex[i], newFolder, activeimageTitle);
            //         print("This is before createComposite, baseFolderName:"+ baseFolderName);
            //         print("Newfolder:"+ newFolder);
            //         createComposite(indexedBaseName, channelIndex[i], newFolder);
            //     }
            //     else {
            //         print("Not enough channels to create composite for: " + channelIndex[i]);
            //     }
            // }
            // else {
            //     // closeComposite[i] = createComposite(indexedBaseName, channelIndex[i], newFolder, activeimageTitle);
            //     createComposite(indexedBaseName, channelIndex[i], newFolder);
            // }
        }
    }
// Saved as Tiff: \\192.168.11.13\Old Photo\TEPASS LAB\2023 A1 Heatshock2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16\MAX_2023 08 21 hsFLP x Crb p35 July11 1430 July14 200PM Dissect July 16 - Series004 - All Channels.tif z12-14-03- Channel 2+4 Composite.tif

    // createComposite(indexedBaseName, "1100", newFolder);
    // if numChannels >= 4 {
    //     createComposite(indexedBaseName, "0101", newFolder);
    // }
    
    // selectImage("ChannelImage");
    // print("RUNNING THE COMP");
    // run("Duplicate...", "title=[Channel12ImageComp] duplicate");
    // Stack.setActiveChannels("1100");
    // run("Flatten");
    // saveAs("Tiff", newFolder + indexedBaseName + "- Channel 1 + 2 Composite.tif");

    selectImage("ChannelImage");
    // Split the channels
    run("Split Channels");

    // For the channels
    for (i=1; i<=numChannels; i++) {
        channelTitle = "C" + i + "-ChannelImage";
        selectImage(channelTitle);
        saveAs("Tiff", newFolder + indexedBaseName + "- Channel " + i + ".tif");
        if (logger) { print("Saved: " + indexedBaseName + "- Channel " + i + ".tif");}
    }

    // Closing all open images
    close("*- Channel *");
    close("*ChannelImageComposite*");
    close("*- Composite*");
    //close("Channel12ImageComp");
    // for (i = 0; i < closeComposite.length; i++) {
    //     if (closeComposite[i] != null) {
    //         close(closeComposite[i]);
    //     }
    // }
    
    // selectImage(activeImageID);
    // activeImageTitle = getInfo("window.title");
    // close(activeImageTitle);
    // close(activeImageTitle);
    

    if (countCells) {
        selectImage(originalImageID);
        run("Duplicate...", "title=[Quantification] duplicate");
        run("Split Channels");
        
        // For the channels
        for (i=1; i<=numChannels; i++) {
            channelTitle = "C" + i + "-Quantification";
            selectImage(channelTitle);
            runMacro("DAPI_counts with MorphoLibJ.ijm");
            if (logger) {
                print("Counting Cells");
            }
        }
        
        close("*Quantification*");
    }

        if (closeOriginal) {
        selectImage(originalImageID);
        close();
    }

}
