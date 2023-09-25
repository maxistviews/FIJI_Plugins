# FIJI Plugins

## How to Install the Macros:
Download the `.ijm` file to your macros folder:

`FIJIINSTALL_FOLDER\Fiji.app\macros`

For example:
`C:\Users\[YOUR_USERNAME]\Documents\FIJI\Fiji.app\macros`


## Add the Macro to the default Macro list:

Once you have done that, find the `StartupMacros.fiji.ijm` and scroll to the bottom.

Add this line:

```java
macro "Z Project New [F1]" {
	runMacro("ZProjectNew.ijm");
}
```

| Code  | Explanation |
| ------------- | ------------- |
| Z Project New  | Just a name, can be anything.  |
| F1  | A shortcut. You can put any F# or letter, or numberpad(n#)  |
| ZProjectNew.ijm | The filename of the macro you installed. |

## Available Macros
### openLifAndSaveTiffs
![image](https://github.com/maxistviews/FIJI_Timesavers/assets/17325179/be6d5d54-34c0-4aa1-92ea-663782e83b70)

Do you ask yourself: "Which of these .lif files has that one image?" and then have to ruffle through different .lif files to find the right imaage?
Well this macro is for you. 

It takes a lif file and saves the images inside as .tif files in a folder. This happens automatically.
Do you want to save seperate channels as .tif files too? There's a checkbox for that!
The macro will even look through the metadata and try to find the name of the LUT you used, so youll know "Channel 1 Blue" is your blue channel.
You can even name the channels whatever you want with the check of a button!


### ZProjectNew
![image](https://github.com/maxistviews/FIJI_Timesavers/assets/17325179/cdcd8705-dc64-4ae2-9d34-e221e40f0e2b)

Changes the default ZProject into a more robust implimentation which keeps the metadata of the original file and renames the Zprojection to include the frames of the Z stack. No more second guessing which slices you chose!



### SaveChannels
![image](https://github.com/maxistviews/FIJI_Timesavers/assets/17325179/8b8a7007-adc6-47e2-95d4-10aa1ca69154)

After creating a Z Project, you may want to save your image in multiple ways - all channels compositied together, with a scale bar, each channel seperately... etc.
The scalebar also adjusts based on the width and height of your image.

This plugin will automatically save your ZProject as:
* Composite (All Channels)
* Composite Scalebar
* Each channel seperately
* Extras:
- Composite 1+2 Channels (Example: DAPI + GFP)
- Composite 2+4 Channels
- More can be added in the macro code. Just adjust this: `channelIndex = newArray("1100","0101");`




## Refresh FIJI's Macros:

FIJI needs to be refreshed before it can read the macros. Click on the red arrows as shown in the photo, and select "Restore Startup tools":

![image](https://github.com/maxistviews/FIJI_Plugins/assets/17325179/b9fb9133-719e-4ebc-a2e7-52e9a689707f)
