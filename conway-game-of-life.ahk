#Requires AutoHotkey v2.0

#SuspendExempt true

^Insert:: Reload
^Delete:: Suspend(!A_IsSuspended)

#SuspendExempt false

PgUp:: {
    gm := Game(30, 30, 20, 75)
    gm.run()
}

class Game {

    __New(row, col, size, updateInterval) {
        this.row := row
        this.col := col
        this.size := size

        this.winMargin := 10
        this.buttonWidth := 80
        this.buttonHeight := 20

        this.randomPercent := 50

        this.updateInterval := updateInterval

        this.running := false

        this.createWindow()
    }

    run() {
        this.win.Show()

        while (WinExist("ahk_id " this.id)) {
            if(this.running) {
                this.updateLiving()
                Sleep(this.updateInterval)
            }
        }
    }

    createWindow() {
        this.boxes := []
        this.saved := []

        this.win := Gui("+AlwaysOnTop", "Conway's Game of Life (By Chicky)")

        this.win.MarginX := this.winMargin
        this.win.MarginY := this.winMargin
        this.id := this.win.hwnd

        loop this.row {
            rowNum := A_Index
            savedRow := []

            loop this.col {
                savedRow.Push(Box(this.win, this.size, this.size, ((A_Index - 1) * this.size) + this.winMargin, ((rowNum - 1) * this.size) + this.winMargin))
            }
            this.boxes.Push(savedRow)
        }

        row1x := this.winMargin
        row1y := (this.size * this.row) + (this.winMargin * 2)

        this.start := this.win.AddText("Center 0x1000 w" this.buttonWidth " h" this.buttonHeight " BackgroundGreen" this.getUILoc(1, 2), "Start")
        this.reset := this.win.AddText("Center 0x1000 w" this.buttonWidth " h" this.buttonHeight " Background9b9b9b" this.getUILoc(1, 3), "Reset")
        this.randomize := this.win.AddText("Center 0x1000 w" this.buttonWidth " h" this.buttonHeight " Background9b9b9b" this.getUILoc(2, 2), "Randomize")
        this.save := this.win.AddText("Center 0x1000 w" this.buttonWidth " h" this.buttonHeight " Background9b9b9b" this.getUILoc(2, 3), "Save")

        this.slider := this.win.AddSlider("ToolTip TickInterval10 w" this.buttonWidth * 2 " Range1-100" this.getUILoc(2, 4), this.randomPercent)
        this.sliderVal := this.win.AddText("Center h24 w" this.buttonWidth * 2 this.getUILoc(1, 4), "Percent Board Randomly Filled: " this.randomPercent "%")

        this.start.SetFont("s10 Bold", "Segoe UI")
        this.reset.SetFont("s10 Bold", "Segoe UI")
        this.randomize.SetFont("s10 Bold", "Segoe UI")
        this.sliderVal.SetFont("s8 Bold", "Segoe UI")
        this.save.SetFont("s10 Bold", "Segoe UI")

        this.start.OnEvent("Click", updateStatus.Bind(this))
        this.reset.OnEvent("Click", reset.Bind(this))
        this.randomize.OnEvent("Click", randomizeBoard.Bind(this))
        this.slider.OnEvent("Change", sliderUpdate.Bind(this))
        this.save.OnEvent("Click", savePaste.Bind(this))

        updateStatus(*) {
            this.running := !this.running
            this.start.Opt(this.running ? "Backgroundd61f1f" : "Background409a40")
            this.start.Text := this.running ? "Stop" : "Start"
            this.start.Redraw()
        }

        reset(*) {
            for (set in this.boxes) {
                for (box in set) {
                    if (box.isAlive) {
                        box.updateColor()
                    }
                }
            }
        }

        randomizeBoard(*) {
            for (set in this.boxes) {
                for (box in set) {
                    if (box.isAlive) {
                        box.updateColor()
                    }
                    if (Random() < (this.randomPercent / 100)) {
                        box.updateColor()
                    }
                }
            }
        }

        sliderUpdate(*) {
            this.randomPercent := this.slider.Value
            this.sliderVal.Text := "Percent Board Randomly Filled: " this.randomPercent "%"
        }

        savePaste(*) {
            if (this.saved.Length == 0) {
                this.saved := this.boxes
                this.save.Text := "Paste"
                this.save.Opt("Background5c5c5c")
                this.save.Redraw()
            }
            else {
                this.save.Text := "Save"
                this.save.Opt("Background9b9b9b")
                this.save.Redraw()

                for (r, set in this.boxes) {
                    for (c, box in set) {
                        if (box.isAlive != this.saved[r][c].isAlive) {
                            box.updateColor()
                        }
                    }
                }

                this.saved := []
            }
        }
    }

    updateLiving() {
        newState := []

        for (r, set in this.boxes) {
            newRowState := []

            for (c, box in set) {
                numAlive := 0

                upperRow := (r - 1 < 1 ? this.boxes.Length : r - 1)
                lowerRow := (r + 1 > this.boxes.Length ? 1 : r + 1)

                leftCol := (c - 1 < 1 ? set.Length : c - 1)
                rightCol := (c + 1 > set.Length ? 1 : c + 1)

                numAlive += this.boxes[upperRow][leftCol].isAlive
                numAlive += this.boxes[upperRow][c].isAlive
                numAlive += this.boxes[upperRow][rightCol].isAlive

                numAlive += this.boxes[r][leftCol].isAlive
                numAlive += this.boxes[r][rightCol].isAlive

                numAlive += this.boxes[lowerRow][leftCol].isAlive
                numAlive += this.boxes[lowerRow][c].isAlive
                numAlive += this.boxes[lowerRow][rightCol].isAlive

                newRowState.Push((!box.isAlive && numAlive == 3) || (box.isAlive && (numAlive == 2 || numAlive == 3)))
            }

            newState.Push(newRowState)
        }

        for (r, set in this.boxes) {
            for (c, box in set) {
                if (box.isAlive != newState[r][c]) {
                    box.updateColor()
                }
            }
        }
    }

    getUILoc(row, col) {
        return " x" this.winMargin * (col) + this.buttonWidth * (col - 1) " y" (this.size * this.row) + (this.winMargin * (row + 1)) + (this.buttonHeight * (row - 1))
    }
}

class Box {

    __New(window, width, height, x, y) {
        this.element := window.AddText("BackgroundBlack Border w" width " h" height " x" x " y" y, "")
        this.element.OnEvent("Click", this.updateColor.Bind(this))

        this.winId := window.hwnd
        this.isAlive := true

        this.updateColor()
    }

    updateColor(*) {
        this.isAlive := !this.isAlive
        this.element.Opt(!this.isAlive ? "BackgroundBlack" : "BackgroundWhite")
        this.element.Redraw()
    }

}
