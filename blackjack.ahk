#Requires AutoHotkey v2.0

#SuspendExempt true

Insert:: Reload
Delete:: Suspend(!A_IsSuspended)

#SuspendExempt false

PgUp:: {
    game := BlackJack()
    game.run()
}

class BlackJack {

    winW := 400
    winH := 400
    winMargin := 10

    sectionH := (this.winH / 2) - (2 * this.winMargin)
    sectionW := this.winW - (2 * this.winMargin)

    playerY := this.winH / 2

    diamond := "♦"
    heart := "♥"
    spade := "♠"
    club := "♣"

    __New(initialBalance := 100) {
        this.player := Player(InputBox("Name").Value, initialBalance)

        this.playerCards := []
        this.dealerCards := []

        this.createWindow()
    }  

    run() {
        this.window.Show("w" this.winW " h" this.winH)
    }

    close(*) {
        if (!WinExist("ahk_id " this.id))
            return

        this.window.Destroy()
    }

    createWindow() {
        this.window := Gui("+AlwaysOnTop -Resize", "Black Jack")
        this.id := this.window.hwnd

        this.window.MarginX := this.winMargin
        this.window.MarginY := this.winMargin

        ; Dealer
        this.dealerBox := this.window.AddGroupBox("w" this.sectionW " h" this.sectionH, "Dealer")

        this.hit := this.window.AddButton("xp20 yp20 +0x1", "Hit")

        ; Player
        this.playerBox := this.window.AddGroupBox("y" this.playerY " w" this.sectionW " h" this.sectionH, this.player.name)

        ; Events
        this.window.OnEvent("Escape", this.close.Bind(this))
        this.window.OnEvent("Close", this.close.Bind(this))

        this.hit.OnEvent("Click", this.addCard.Bind(this))
    }

    addCard(*) {
        newCard := Card("2", this.spade, 2)

        rowWidth := (newCard.width * this.dealerCards.Length) + ((this.dealerCards.Length * this.winMargin) - 1)

        if (rowWidth > this.winW - (6 * this.winMargin))
            return

        this.dealerCards.Push(newCard.createCard(this.window))
        rowWidth += newCard.width

        leftStart := (this.winW - rowWidth) / 2

        for (i, cards in this.dealerCards) {
            cards.Move(leftStart + ((newCard.width + this.winMargin) * (i - 1)), this.sectionH - 50)
        }
    }

}

class Player {

    __New(name, balance) {
        this.name := name
        this.balance := balance
    }

}

class Card {

    __New(name, suit, value) {
        this.name := name
        this.suit := suit
        this.value := value

        this.height := 60
        this.width := this.height / 1.4
    }

    createCard(win) {
        if (win is Gui) {
            cardView := win.AddText("Border Wrap h" this.height " w" this.width, this.name "`n" this.getSuitDisplay())
            return cardView
        }
    }

    getSuitDisplay() {
        return this.suit
    }

}
