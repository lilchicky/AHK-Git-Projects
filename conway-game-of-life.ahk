#Requires AutoHotkey v2.0

#Requires AutoHotkey v2.0

#SuspendExempt true

^Insert:: Reload
^Delete:: Suspend(!A_IsSuspended)

#SuspendExempt false

PgUp:: {
    gm := Game(25, 25)
    gm.run()
}

class Game {

    __New(row, col) {
        this.row := row
        this.col := col

        MsgBox("test")

        this.running := false

        this.createWindow()
    }

    run() {
        this.win.Show()

        while (WinExist("ahk_id " this.id)) {
            if(this.running) {
                this.updateLiving()
                Sleep(500)
            }
        }
    }

    createWindow() {
        this.boxes := []

        this.win := Gui("+AlwaysOnTop")

        this.win.MarginX := 10
        this.win.MarginY := 10
        this.id := this.win.hwnd

        loop this.row {
            rowNum := A_Index
            loop this.row {
                savedRow := []
                loop this.col {
                    savedRow.Push(Box(this.win, 20, 20, ((A_Index - 1) * 20) + 10, ((rowNum - 1) * 20) + 10))
                }
                this.boxes.Push(savedRow)
            }
        }

        this.start := this.win.AddButton("Left", "Start/Stop")
        this.status := this.win.AddText("", "Running: " (this.running ? "True" : "False"))

        this.start.OnEvent("Click", updateStatus.Bind(this))

        updateStatus(*) {
            this.running := !this.running
            this.status.Text := "Running: " (this.running ? "True" : "False")
        }
    }

    updateLiving() {
        for (r, set in this.boxes) {
            for (c, box in set) {
                numAlive := 0

                numAlive += this.boxes[r - 1][c - 1].isAlive
                numAlive += this.boxes[r - 1][c].isAlive
                numAlive += this.boxes[r - 1][c + 1].isAlive
                numAlive += this.boxes[r][c - 1].isAlive
                numAlive += this.boxes[r][c + 1].isAlive
                numAlive += this.boxes[r + 1][c - 1].isAlive
                numAlive += this.boxes[r + 1][c].isAlive
                numAlive += this.boxes[r + 1][c + 1].isAlive
            }

            if ((!box.isAlive && numAlive == 3) || (box.isAlive && (numAlive < 2 || numAlive > 3))) {
                box.updateColor()
            }
        }
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
