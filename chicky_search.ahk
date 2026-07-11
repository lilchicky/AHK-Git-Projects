#Requires AutoHotkey v2.0

class ChickySearch {

    static Create(&instance, options, title := "Chicky Search", display := unset, initialSort := unset) {
        if (!IsSet(instance))
            instance := IsSet(display) ? ChickySearch(options, title, display) : ChickySearch(options, title)

        val := instance.run()
        return val
    }

    __New(options, title := "Chicky Search", display := unset, initialSort := unset) {
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

        if (Type(options) == "String" && FileExist(options)) {
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
    
                displayText := ""
                try displayText := this.display.Call(item)

                this.options.Push({
                    item: item,
                    display: displayText,
                    searchItem: StrLower(displayText)
                })
            }

            file.Close()
        }
        else if (options is Array && options.Length > 0) {
            for (item in options) {
                displayText := ""
                try displayText := this.display.Call(item)

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
        else {
            this.options.Push({
                item: "",
                display: "",
                searchItem: ""
            })
        }

        this.loadingInfo.Value := (this.currentInfo := "Reading options... 100%`n[" this.options.Length "] options registered!`n")

        this.filtered := []
        this.result := ""
        this.maxVisible := 100

        this.sortArray(this.options, IsSet(initialSort) ? initialSort : (a, b) => StrCompare(a.display, b.display), this.loadingInfo)
        this.loadingInfo.Value := (this.currentInfo := "Sorting options... 100%`nOptions sorted!`n")

        this.createWindow()

        this.loading.Value := (this.currentInfo := "")
        this.loading.Hide()
    }

    run() {
        if (!WinExist("ahk_id " this.id))
            this.createWindow()

        this.window.Show()

        WinWaitClose("ahk_id " this.id)

        return this.result
    }

    close(*) {
        this.result := this.getEmptyResult()
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

    getEmptyResult() {
        if (this.options.Length > 0 && (obj := this.options[1].item) is Object) {
            for (id, val in obj.OwnProps()) {
                obj.DefineProp(id, {value:""})
            }
            return obj
        }
        return ""
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
        Critical(1)

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

            Critical(0)
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

        if (!WinExist("ahk_id " this.id)) {
            Critical(0)
            return
        }

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
    
        Critical(0)
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
                    score := Max(score, 1)
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
