#Requires AutoHotkey v2.0

#Requires AutoHotkey v2.0

#SuspendExempt true

Insert:: Reload
Delete:: Suspend(!A_IsSuspended)

#SuspendExempt false

PgUp:: {
    win := Game(25, 25)
    win.run()
}

class Game {

    __New(row, col) {
        this.row := row
        this.col := col

        this.boxes := []

        this.createWindow()
    }

    run() {
        if (!WinExist("ahk_id " this.id))
            this.createWindow()

        this.win.Show()

        loop 100 {
            for (box in this.boxes) {
                box.updateColor()
                Sleep(250)
            }
        }
    }

    createWindow() {
        this.win := Gui("+AlwaysOnTop")

        this.win.MarginX := 10
        this.win.MarginY := 10
        this.id := this.win.hwnd

        loop this.row {
            rowNum := A_Index
            loop this.col {
                this.boxes.Push(Box(this.win, 20, 20, ((A_Index - 1) * 20) + 10, ((rowNum - 1) * 20) + 10))
            }
        }
    }

}

class Box {

    __New(window, width, height, x, y) {
        this.element := window.AddText("BackgroundBlack Border w" width " h" height " x" x " y" y, "")
        this.element.OnEvent("Click", this.updateColor.Bind(this))

        this.winId := window.hwnd
        this.isAlive := false
    }

    updateColor(*) {
        this.element.Opt(this.isAlive ? "BackgroundBlack" : "BackgroundWhite")
        this.isAlive := !this.isAlive
        this.element.Redraw()
    }

}
