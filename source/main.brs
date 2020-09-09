' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

sub Main()
    showChannelSGScreen()
end sub

sub showChannelSGScreen()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    m.scene = screen.CreateScene("MainScene")
    screen.show()
    ' Screen must be showing in order for observer to work
    m.scene.observeField("exitApp", m.port)
    
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        ? "Main sees msgType: "; msgType
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            msgField = msg.getField()
            if msgField = "exitApp"
                if msg.getData() then return
            end if
        end if
    end while
end sub
