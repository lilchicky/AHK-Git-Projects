/*
Automatically grabs and returns (as a String) the path to this library, and creates a new text file [newFile].txt.
If you wish to create files in subfolders at the level of this library, you can precede newFile with further locations
    i.e. [newFile] := "textFolder\textFile"

[newFile]: The name of the text file to be created. ".txt" is automatically ended to the end, so this value should only
    contain the name of the file, and any additional folders before the text file.
*/
createFilePath(newFile) {
    return RegExReplace(A_LineFile, "[^\\]+$", newFile ".txt")
}

/*
Add a single element to a file. Both Strings and Objects are supported, see getFileContentsAsArray() for how they are formatted.

- Does not add blank values to the file. 
- Does not add duplicate values to the file.

Appends values to the end of a file, does not replace the contents. Since it uses FileAppend(), a new file will be created at [path]
if one does not exist. Returns true or false if the item was successfully added.

[item]: The value to add to the file.
[path]: The path to the file to add to.
*/
addItemToFile(item, path) {
    fileContents := getFileContentsAsArray(path)

    if (item == "")
        return false

    if (item is Object) {
        line := ""

        for (id, val in item.OwnProps()) {
            if (id == "" || val == "")
                return false
        
            line .= id ":" val (A_Index >= ObjOwnPropCount(item) ? "" : "|")
        }

        if (inArray(fileContents, line))
            return false
                
        FileAppend(line "`n", path)
        return true
    }
    else {
        if (!inArray(fileContents, item)) {
            FileAppend(item "`n", path, "`n")
            return true
        }
    }
    
    return false
}

/*
Add a full array to a file in one go, instead of needing to iterate inside the hotkey. See addItemToFile() for more details.
Note that this appends a file, and does not replace the contents of it. Supports arrays of objects.

Returns [true] if all elements of the array were added successfully.

[arr]: Array to add to file
[path]: Path to file to add the array to
*/
addListToFile(arr, path) {
    flag := true
    for (item in arr) {
        flag := addItemToFile(item, path) && flag
    }
    return flag
}

/*
Reads the contents of a file at [path] and returns the values as an array. Seperate elements in the text file are defined by line breaks. Objects
can be stored as well, with the stored format id:value|id:value|id:value|.... Returns the array, or a blank array if empty.

If the file does not exist, a new empty file will be created at [path].

[path]: The path to the file to check the contents of
*/
getFileContentsAsArray(path) {
    if (FileExist(path)) {
        items := []
        loop read (path) {
            if (A_LoopReadLine != "")
                ; A line is determined to be an object if it contains '|'.
                if (!InStr(A_LoopReadLine, "|")) {
                    items.Push(A_LoopReadLine)
                }
                else {
                    sets := Object()
                    for (item in StrSplit(A_LoopReadLine, "|")) {
                        ; This assumes correct formatting. A group with more than 1 colon will simply drop any value after the first 2.
                        idset := StrSplit(item, ":")
                        sets := sets.DefineProp(idset[1], {value:idset[2]})
                    }
                    items.Push(sets)
                }
        }
        return items
    }
    else {
        FileOpen(path, "w")
        MsgBox("File at " path " did not exist, so it was created.")
        return []
    }
}

/*
Attempt to delete a full file at [path]. Moves to recycling bin instead of a full deletion, so you can restore it if you need to.

[path]: The path to the file to be deleted
*/
deleteFile(path) {
    if (FileExist(path)) {
        FileRecycle(path)
    }
    else {
        MsgBox("File at " path " does not exist!")
    }
}

/*
Attempt to delete a value in file at [path]. Uses InStr, so you can delete multiple entries at once with generalized keywords.

[item]: The value to be deleted
[path]: The path to the file to be checked
*/
deleteFileEntry(item, path) {
    if (FileExist(path)) {
        temp := A_Temp "\temp.txt"
        numRemoved := 0

        try FileDelete(temp)

        loop read (path) {
            if (InStr(A_LoopReadLine, item)) {
                numRemoved++
                continue
            }

            FileAppend(A_LoopReadLine "`n", temp)
        }

        ; Verify if you want to delete values, since this cannot really be undone.
        if (InputBox("You are deleting " numRemoved " item(s) that contain `"" item "`".`n`nType DELETE to confirm.", "Are you sure?").Value == "DELETE") {
            FileMove(temp, path, 1)
            MsgBox("Deleted " numRemoved " values(s) that contain `"" item "`".")
        }
        else {
            MsgBox("Deletion cancelled.")
        }
    }
    else {
        MsgBox("File at " path " does not exist!")
    }
}

/*
Searches an array for a value. Breaks early if it's found. You can optionally set an id if the array contains objects,
in which case the loop will check if the array contains an object with that id. 

If a value is found, the index is returned. You can use this with objects by grabbing array[k].val. If the value is not found,
    false is returned.

[h]: The array to search (haystack)
[n]: The value to look for (needle)
[id] (Optional, default unset): Whether [n] is an ID of an element inside an object or not. Does nothing if the array does not contain
    objects.
*/
inArray(h, n, id := false) {
    if (h is Array) {
        for (k, v in h) {
            if (v == n) {
                return k
            }
            if (v is Object && id) {
                for (name, value in v.OwnProps()) {
                    if (name == n) {
                        return k
                    }
                }
            }
        }
    }
    return false
}
