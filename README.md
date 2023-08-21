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

## Refresh FIJI's Macros:

FIJI needs to be refreshed before it can read the macros. Click on the red arrows as shown in the photo, and select "Restore Startup tools":

![image](https://github.com/maxistviews/FIJI_Plugins/assets/17325179/b9fb9133-719e-4ebc-a2e7-52e9a689707f)
