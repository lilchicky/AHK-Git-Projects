#Requires AutoHotkey v2.0

#SuspendExempt true
Insert:: Reload
Delete:: Suspend(!A_IsSuspended)

#SuspendExempt false

objs := [
    {name: "Garden", id: 1024, type: "Location"},
    {name: "TELEPHONE", id: 2048, type: "Device"},
    {name: "apple", id: 4096, type: "Food"},
    {name: "Volcano", id: 8192, type: "Nature"},
    {name: "Camera", id: 1638, type: "Device"},
    {name: "Meadow", id: 3276, type: "Location"},
    {name: "Bucket", id: 6553, type: "Tool"},
    {name: "Shadow", id: 1111, type: "Concept"},
    {name: "Rocket", id: 2222, type: "Vehicle"},
    {name: "Blanket", id: 3333, type: "Clothing"},
    {name: "Umbrella", id: 4444, type: "Tool"},
    {name: "Diamond", id: 5555, type: "Material"},
    {name: "Pocket", id: 6666, type: "Storage"},
    {name: "Woodpecker", id: 7777, type: "Animal"},
    {name: "Bridge", id: 8888, type: "Structure"},
    {name: "JUNGLE", id: 9999, type: "Location"},
    {name: "River", id: 1212, type: "Nature"},
    {name: "Compass", id: 2323, type: "Tool"},
    {name: "Castle", id: 3434, type: "Structure"},
    {name: "Waterfall", id: 4545, type: "Nature"},
    {name: "Feather", id: 5656, type: "Material"},
    {name: "Cactus", id: 6767, type: "Plant"},
    {name: "Painting", id: 7878, type: "Art"},
    {name: "Snowflake", id: 8989, type: "Nature"},
    {name: "Backpack", id: 9090, type: "Storage"},
    {name: "Glacier", id: 1010, type: "Nature"},
    {name: "Hammer", id: 2020, type: "Tool"},
    {name: "Festival", id: 3030, type: "Event"},
    {name: "Window", id: 4040, type: "Structure"},
    {name: "Planet", id: 5050, type: "Space"},
    {name: "LIBRARY", id: 6060, type: "Building"},
    {name: "Sunflower", id: 7070, type: "Plant"},
    {name: "Strawberry", id: 8080, type: "Food"},
    {name: "Cherry", id: 9191, type: "Food"},
    {name: "Ocean", id: 1234, type: "Nature"},
    {name: "Newspaper", id: 2345, type: "Media"},
    {name: "BICYCLE", id: 3456, type: "Vehicle"},
    {name: "Lighthouse", id: 4567, type: "Structure"},
    {name: "Crystal", id: 5678, type: "Material"},
    {name: "Anchor", id: 6789, type: "Tool"},
    {name: "Harvest", id: 7890, type: "Event"},
    {name: "Orchard", id: 8901, type: "Location"},
    {name: "Sandwich", id: 9012, type: "Food"},
    {name: "Emerald", id: 1122, type: "Material"},
    {name: "Carpet", id: 2233, type: "Clothing"},
    {name: "Mountain", id: 3344, type: "Nature"},
    {name: "Scissors", id: 4455, type: "Tool"},
    {name: "Fireplace", id: 5566, type: "Structure"},
    {name: "Ceiling", id: 6677, type: "Structure"},
    {name: "Horizon", id: 7788, type: "Concept"},
    {name: "Lantern", id: 8899, type: "Tool"},
    {name: "Pineapple", id: 9900, type: "Food"},
    {name: "Marble", id: 1357, type: "Material"},
    {name: "Workshop", id: 2468, type: "Building"},
    {name: "COOKIE", id: 3579, type: "Food"},
    {name: "Island", id: 4680, type: "Location"},
    {name: "Fountain", id: 5791, type: "Structure"},
    {name: "Balloon", id: 6802, type: "Object"},
    {name: "Dolphin", id: 7913, type: "Animal"},
    {name: "Thunder", id: 8024, type: "Nature"},
    {name: "Guitar", id: 9135, type: "Instrument"},
    {name: "Candle", id: 1246, type: "Object"},
    {name: "Rainbow", id: 2357, type: "Nature"},
    {name: "Kitchen", id: 3468, type: "Room"},
    {name: "Drawer", id: 4579, type: "Storage"},
    {name: "Test", id: 5680, type: "Debug"},
    {name: "TEST", id: 6791, type: "Debug"},
    {name: "Zeppelin", id: 7802, type: "Vehicle"}
]
searchWindow := unset
searchWindowObj := ChickySearch(objs, , (item => item.name " (" item.type ")"))

Home:: ChickySearch.Create(&searchWindow, "C:\Users\escar\OneDrive\Documents\AutoHotkey\AHK Git Projects\words.txt")
+Home:: {
    if (item := searchWindowObj.run()) {
        MsgBox(item.name)
    }
}

class ChickySearch {

    static Create(&instance, options, title := "Chicky Search", display := unset) {
        if (!IsSet(instance))
            instance := IsSet(display) ? ChickySearch(options, title, display) : ChickySearch(options, title)

        instance.run()
    }

    __New(options, title := "Chicky Search", display := unset) {
        this.title := title
        this.options := []
        this.display := IsSet(display) ? display : (x => x)
        this.currentInfo := ""
        this.lastUpdate := 0

        this.lastSearch := ""
        this.lastResults := []

        this.loading := Gui("+AlwaysOnTop", this.title "(Loading...)")
        this.loading.MarginX := 10
        this.loading.MarginY := 10

        this.loadingInfo := this.loading.AddText("w200 h150", "")

        this.loadingInfo.SetFont("s10", "Segoe UI")

        this.loading.Show()

        if (Type(options) = "String" && FileExist(options)) {
            file := FileOpen(options, "r")
            fileSize := file.Length

            while (!file.AtEOF) {
                item := Trim(file.ReadLine())

                if (A_TickCount - this.lastUpdate > 100) {
                    progress := file.Pos / fileSize
                    this.loadingInfo.Value := "Reading options... " Round(progress * 100) "%"
                    this.lastUpdate := A_TickCount
                }

                if (item = "")
                    continue

                displayText := this.display.Call(item)

                this.options.Push({
                    item: item,
                    display: displayText,
                    searchItem: StrLower(displayText)
                })
            }

            file.Close()
        }
        else {
            for (item in options) {
                displayText := this.display.Call(item)

                if (A_TickCount - this.lastUpdate > 100) {
                    progress := A_Index / options.Length
                    this.loadingInfo.Value := "Reading options... " Round(progress * 100) "%"
                    this.lastUpdate := A_TickCount
                }

                this.options.Push({
                    item: item,
                    display: displayText,
                    searchItem: StrLower(displayText)
                })
            }
        }
        this.loadingInfo.Value := (this.currentInfo := "Reading options... 100%`n[" this.options.Length "] options registered!`n")

        this.filtered := []
        this.result := ""
        this.maxVisible := 100

        this.sortArray(this.options, (a, b) => StrCompare(a.display, b.display), this.loadingInfo)
        this.loadingInfo.Value := (this.currentInfo := "Sorting options... 100%`nOptions sorted!`n")

        this.createWindow()

        this.loading.Value := (this.currentInfo := "")
        this.loading.Hide()
    }

    run() {
        if (!WinExist("ahk_id " this.id))
            this.createWindow()

        this.window.Show()

        WinWaitClose(this.id)

        return this.result
    }

    close(*) {
        this.result := ""
        this.destroy()
    }

    destroy() {
        if (!WinExist("ahk_id " this.id))
            return

        HotIfWinActive("ahk_id " this.id)
        Hotkey("Enter", "Off")
        HotIfWinActive()

        this.window.Destroy()
    }

    createWindow() {
        this.window := Gui("+AlwaysOnTop", this.title)
        this.window.MarginX := 10
        this.window.MarginY := 10
        this.id := this.window.hwnd

        this.search := this.window.AddEdit("w400 h28", "")
        this.instruction := this.window.AddText("w400 h15", "Enter/Double Click - Select | Esc - Cancel")
        this.list := this.window.AddListView("w400 h300 Grid -Multi -Hdr", ["Entry"])
        this.status := this.window.AddText("w400", this.options.Length " entries")

        this.search.SetFont("s12", "Segoe UI")
        this.list.SetFont("s12", "Segoe UI")
        this.instruction.SetFont("s9", "Segoe UI")

        this.search.OnEvent("Change", this.updateResults.Bind(this))
        this.list.OnEvent("DoubleClick", this.acceptSelection.Bind(this))

        this.window.OnEvent("Escape", this.close.Bind(this))
        this.window.OnEvent("Close", this.close.Bind(this))

        this.enter := this.acceptSelection.Bind(this)
        HotIfWinActive("ahk_id " this.id)
        Hotkey("Enter", this.enter)
        HotIfWinActive()

        this.updateResults()
    }

    updateResults(*) {
        this.list.Delete()
        this.filtered := []
        visibleCount := 0
        source := this.options
        search := StrLower(this.search.Value)
        searchChar := SubStr(search, 1, 1)

        results := []

        if (this.lastSearch != "" && InStr(search, this.lastSearch) == 1) {
            source := this.lastResults
        }

        if (this.search.Value == "") {
            this.lastSearch := ""
            this.lastResults := []

            for (item in this.options) {
                if (++visibleCount > this.maxVisible)
                    break

                this.filtered.Push(item)
                this.list.Add(, item.display)
            }

            this.status.Value := this.options.Length > this.maxVisible ? this.maxVisible "/" this.options.Length " entries" : this.options.Length " entries"

            if (this.list.GetCount()) {
                this.list.Modify(1, "Select Focus")
            }

            return
        }

        for (item in source) {
            if (!InStr(item.searchItem, searchChar))
                continue

            score := this.fuzzySearch(item.searchItem, search)

            if (score > 0) {
                results.Push({
                    item: item,
                    score: score
                })
            }
        }

        this.sortArray(results, (a, b) => b.score - a.score)

        this.lastSearch := search
        this.lastResults := []
        for (result in results) {
            this.lastResults.Push(result.item)
        }

        if (!WinExist("ahk_id " this.id)) 
            return
        
        for (result in results) {
            if (++visibleCount > this.maxVisible)
                break

            this.filtered.Push(result.item)
            this.list.Add(, result.item.display)
        }

        if (this.list.GetCount()) {
            this.list.Modify(1, "Select Focus")
        }

        this.status.Value := (results.Length > 0 ? (results.Length > this.maxVisible ? this.maxVisible " out of " results.Length " matches" : results.Length " matches") : "No matches")
    }

    acceptSelection(*) {
        row := this.list.GetNext()

        if (!row)
            return

        this.result := this.filtered[row].item
        this.destroy()
    }

    fuzzySearch(item, search) {
        score := 0
        searchPos := 1
        lastMatch := 0

        searchLen := StrLen(search)
        itemLen := StrLen(item)

        if (item == search) {
            return 1000
        }

        if (searchLen > itemLen) {
            return 0
        }

        loop itemLen {
            if (searchPos > searchLen)
                break

            if (SubStr(item, A_Index, 1) == SubStr(search, searchPos, 1)) {
                if (lastMatch) {
                    score -= (A_Index - lastMatch - 1) * 2
                }

                if (lastMatch && A_Index == lastMatch + 1) {
                    score += 10
                }
                else {
                    score += 1
                }

                if (A_Index == 1) {
                    score += 20
                }
                else if (A_Index <= 3) {
                    score += 5
                }

                lastMatch := A_Index
                searchPos++
            }
        }

        if (searchPos <= searchLen) {
            return 0
        }

        if (SubStr(item, 1, searchLen) == search) {
            score += 100
        }

        return score
    }

    sortArray(list, compareFunc, tracker := unset) {
        n := list.Length
        size := 1
        mergesDone := 0
        totalMerges := 0

        while (size < n) {
            totalMerges += Ceil(n / (size * 2))
            size *= 2
        }
        size := 1

        while (size < n) {
            left := 1

            while (left <= n - size) {
                mid := left + size - 1
                right := Min(left + size * 2 - 1, n)

                this.merge(list, left, mid, right, compareFunc)

                if (IsSet(tracker) && tracker is Gui.Control) {
                    if (A_TickCount - this.lastUpdate > 100) {
                        progress := mergesDone / totalMerges
                        tracker.Value := this.currentInfo "Sorting options... " Round((progress ** 10) * 100, 2) "%"
                        this.lastUpdate := A_TickCount
                    }
                }

                mergesDone++
                left += size * 2
            }

            size *= 2
        }
    }

    merge(list, left, mid, right, compareFunc) {
        temp := []

        x := left
        y := mid + 1

        while (x <= mid && y <= right) {
            if (compareFunc(list[x], list[y]) <= 0) {
                temp.Push(list[x])
                x++
            }
            else {
                temp.Push(list[y])
                y++
            }
        }

        while (x <= mid) {
            temp.Push(list[x])
            x++
        }

        while (y <= right) {
            temp.Push(list[y])
            y++
        }

        for (k, v in temp) {
            list[left + k - 1] := v
        }
    }
}