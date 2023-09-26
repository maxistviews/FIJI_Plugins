// Created by Max Shcherbina 2023
// You can pick your own 
dicomPath = Property.get("Location");
imageInfo = getMetadata("Info");
//originalTitle = getTitle();
// print(imageInfo);
//imageInfo2 = Property.getList(); //This did nothing
// print("-----------------------NEXT--------------------------");
//print(imageInfo2);
// firstSlice = 1;
// endSlice = Property.getNumber(" SizeZ");
// print("SizeZ: " + endSlice);
// depthInfo = Property.get("Depth");
// print("Depth: " + depthInfo);

sliceLabel = Property.getSliceLabel();
// print("Slice Label: " + sliceLabel);

endSlice = replace(sliceLabel, ".*z:\\d+/([\\d]+).*", "$1");
endSlice = parseInt(endSlice);

// print("SizeZ: " + endSlice);

projection_type = newArray("Average Intensity","Max Intensity","Min Intensity","Sum Slices","Standard Deviation","Median");

Dialog.createNonBlocking("Z Projection (new)");
    Dialog.addMessage("Pick you stack and click OK when ready to proceed.");

    Dialog.addNumber("Start Slice:", 1);
    Dialog.addNumber("End Slice:", endSlice);
    Dialog.addChoice("Projection Type:", projection_type , "Max Intensity");
    Dialog.addMessage("Average Intensity -- projection outputs an image wherein each pixel stores average intensity over all images in stack at corresponding pixel location.\nMaximum Intensity --  projection (MIP[?]) creates an output image each of whose pixels contains the maximum value over all images in the stack at the particular pixel location.\nSum Slices -- projection creates a real image that is the sum of the slices in the stack.\nStandard Deviation -- projection creates a real image containing the standard deviation of the slices. \n Median -- projection outputs an image wherein each pixel stores median intensity over all images in stack at corresponding pixel location.");
    Dialog.setLocation(400,50);
    Dialog.show();


start = Dialog.getNumber();
end = Dialog.getNumber();
projection = Dialog.getChoice();


run("Z Project...", "start=" +start+" stop="+end+" projection=["+projection+"]");
zProjectlTitle = getTitle();
setMetadata("Info", imageInfo);
Property.set("OriginalDirectory", dicomPath);
// print(imageInfo);
// Property.set("TestDir", dicomPath);
// dicomPath2 = Property.get("TestDir");
// print("New dicomPath: " + dicomPath2);
dir = Property.get("OriginalDirectory");
if (logger) {print("dir: " + dir);}
rename(zProjectlTitle + " [z" + start + "-" + end+"]");
