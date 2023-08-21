# FIJI Plugins

## How to Install the Macros:
Copy the `.ijm` files to your macros folder:

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
