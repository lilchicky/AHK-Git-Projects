#Requires AutoHotkey v2.0

#SuspendExempt true
Insert:: Reload
Delete:: Suspend(!A_IsSuspended)

#SuspendExempt false

items := [
    "garden",
    "Garden",
    "GARDEN",
    "telephone",
    "Telephone",
    "apple",
    "Apple",
    "APPLE",
    "volcano",
    "camera",
    "Camera",
    "meadow",
    "bucket",
    "shadow",
    "Shadow",
    "rocket",
    "blanket",
    "umbrella",
    "diamond",
    "pocket",
    "woodpecker",
    "bridge",
    "jungle",
    "river",
    "compass",
    "castle",
    "Castle",
    "waterfall",
    "feather",
    "cactus",
    "painting",
    "snowflake",
    "backpack",
    "glacier",
    "hammer",
    "festival",
    "window",
    "planet",
    "library",
    "sunflower",
    "strawberry",
    "cherry",
    "ocean",
    "newspaper",
    "bicycle",
    "Bicycle",
    "BICYCLE",
    "lighthouse",
    "crystal",
    "anchor",
    "harvest",
    "orchard",
    "sandwich",
    "emerald",
    "carpet",
    "mountain",
    "scissors",
    "fireplace",
    "ceiling",
    "horizon",
    "lantern",
    "pineapple",
    "marble",
    "workshop",
    "cookie",
    "Cookie",
    "island",
    "fountain",
    "balloon",
    "dolphin",
    "thunder",
    "guitar",
    "candle",
    "rainbow",
    "kitchen",
    "drawer",
    "test",
    "Test",
    "TEST",
    "test2",
    "test6",
    "zeppelin",
    "Zeppelin",
    "zebra",
    "Zebra",
    "yellowstone",
    "Yellowstone",
    "blueberry",
    "blackberry",
    "bluebird",
    "butterfly",
    "buttercup",
    "dragonfly",
    "dragonfruit",
    "firefly",
    "firestorm",
    "moonlight",
    "moonstone",
    "starlight",
    "starfish",
    "rainfall",
    "rainforest",
    "snowball",
    "snowbird"
]
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
searchWindow := ChickySearch(items)
searchWindowObj := ChickySearch(objs, , (item => item.name " (" item.type ")"))

Home:: searchWindow.run()
+Home:: {
    if (item := searchWindowObj.run()) {
        MsgBox(item.name)
    }
}

class ChickySearch {

    __New(options, title := "Chicky Search", display := unset) {
        this.title := title
        this.display := IsSet(display) ? display : (x => x)

        this.options := []

        for (item in options) {
            displayText := this.display.Call(item)
            this.options.Push({
                item: item,
                display: displayText,
                searchItem: StrLower(displayText)
            })
        }

        this.filtered := []
        this.result := ""
        this.maxVisible := 100

        this.sortArray(this.options, (a, b) => StrCompare(a.display, b.display))

        this.createWindow()
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
        this.id := this.window.Hwnd

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

        if (this.search.Value == "") {
            for (item in this.options) {
                this.filtered.Push(item)
                this.list.Add(, item.display)
            }

            this.status.Value := this.options.Length " entries"

            if (this.list.GetCount()) {
                this.list.Modify(1, "Select Focus")
            }

            return
        }

        search := StrLower(this.search.Value)

        results := []

        for (item in this.options) {
            score := this.fuzzySearch(item.searchItem, search)

            if (score > 0) {
                results.Push({
                    item: item,
                    score: score
                })
            }
        }

        this.sortArray(results, (a, b) => b.score - a.score)

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

    sortArray(list, compareFunc) {
        n := list.Length
        size := 1

        while (size < n) {
            left := 1

            while (left <= n - size) {
                mid := left + size - 1
                right := Min(left + size * 2 - 1, n)

                this.merge(list, left, mid, right, compareFunc)

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