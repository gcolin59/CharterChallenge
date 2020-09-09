'@description Initialize the view.
sub init()
    ? "View base class init"
    devinfo = createObject("roDeviceInfo")
    m.dsize = devinfo.getDisplaySize()
    m.scene = m.top.getScene()
    findElements()
    positionElements()
    m.content = invalid
    m.visible = false
    m.top.color="0x880088FF"
    m.top.width = m.dsize.w
    m.top.height = m.dsize.h
    m.backButton.observeFieldScoped("buttonSelected", "onButtonSelected")
    m.forwardButton.observeFieldScoped("buttonSelected", "onButtonSelected")
    m.top.observeFieldScoped("content", "onContentChanged")
    m.top.observeFieldScoped("visible", "onVisibleChanged")
end sub

'@description Locates child (and other) elements and sets them into local variables
sub findElements()
    m.bgPoster = m.top.findNode("bgPoster")
    m.titleLabel = m.top.findNode("titleLabel")
    m.outputLabel = m.top.findNode("outputLabel")
    m.forwardButton = m.top.findNode("forwardButton")
    m.backButton = m.top.findNode("backButton")
    m.serviceTask = m.top.getScene().serviceTask
end sub

'@description Set the UI elements to their initial positions. Some may
' move during operation based on view content.
sub positionElements()
    ' We're going to use the poster's x and y a few times, so let's set those up...
    m.posterw = 640
    m.posterh = 175
    m.posterx = (m.dsize.w-m.posterw)/2
    m.postery = (m.dsize.h-m.posterh)/2
    '
    m.titleLabel.translation = [50, 50]
    m.titleLabel.width = m.dsize.w - 100
    m.titleLabel.horizAlign = "center"
    '
    m.outputLabel.translation = [m.posterx, m.postery-50]
    m.outputLabel.width = m.posterw
    m.outputLabel.horizAlign = "center"
    '
    m.bgPoster.width = m.posterw
    m.bgPoster.height = m.posterh
    m.bgposter.translation = [m.posterx, m.postery]
    '
    m.forwardButton.translation = [m.dsize.w-200, m.dsize.h-100]
    m.forwardButton.minWidth = 100
    m.forwardButton.height = 35
    m.forwardButton.text = "Next"
    '
    m.backButton.translation = [50, m.dsize.h-100]
    m.backButton.minWidth = 100
    m.backButton.height = 35
    m.backButton.text = "Back"
end sub

'@description Position the output label based on whether the 'outLocation'
' field of our content is "above" or "below" (passed as boolean from caller)
'@param above   -   True if the label should be above the logo, false if should be below
sub positionOutput(above as boolean)
    if above
        m.outputLabel.translation = [m.posterx, m.postery-50]
    else
        m.outputLabel.translation = [m.posterx, m.postery + m.posterh]
    end if
end sub

'@description Sets up focus when the view is shown. Because all of the
' views always exist in this app, we never want to do anything with the
' focus is the view isn't visible.
sub onVisibleChanged(nodeevent as object)
    m.visible = nodeevent.getData()
    ? "CharterView "; m.top.id; " visible changed to "; m.visible
    if m.visible
        cn = m.top.content
        if not isInvalid(cn)
            ? "CharterView "; m.top.id; " will set button focus because CONTENT is GOOD"
            setButtonFocus(cn)
        else
            ? "CharterView "; m.top.id; " will not set button focus because CONTENT is INVALID"
        end if
    end if
end sub

'@description Captures clicks on either nav button and asks the ServiceTask to perform
' navigation accordingly. It isn't possible to focus a button that doesn't point to a
' view that's known to exist already, so we don't have to test for that before navigating.
'@param nodeevent   -   An roSGNodeEvent from the Button object that was changed.
sub onButtonSelected(nodeevent as object)
    btnid = nodeevent.getNode()
    ? "CharterView "; m.top.id; " sees button ID "; btnid; " selected"
    if btnid = "forwardButton"
        m.serviceTask.nav = m.content.nextView
    else if btnid = "backButton"
        m.serviceTask.nav = m.content.prevView
    end if
end sub

'@description Focuses the appropriate button for page navigation, implementing our
' focus rules:
' - Do not focus any button whose corresponding view in the CN is set to 'none'
' - If a next page exists, focus NEXT preferentially
' - Otherwise focus PREV
'@param cn  -   The ContentNode containing or page data, including next/previous view(s)
sub setButtonFocus(cn as object)
    if cn.nextView <> "none"
        if focusForwardButton()
            ? "CharterView "; m.top.id; " NEXT view is not NONE so focusing FORWARD"
        else
            ? "CharterView "; m.top.id; " no need to focus FORWARD because view is not visible"
        end if
    else if cn.prevView <> "none"
        if focusBackButton()
            ? "CharterView "; m.top.id; " PREV view is not NONE so focusing BACK"
        else
            ? "CharterView "; m.top.id; " no need to focus BACK because view is not visible"
        end if
    end if
end sub

'@description When the service task has completed it's work, it will set a ContentNode
' into our 'content' field, which will contain the array to be displayed as well as
' the onscreen location to place the output Label. Since the CN is already present in
' nodeevent, we can save ourselves an access to m.top
'@param nodeevent   -   The roSGNodeEvent generated when the content was set, containing view setup data
sub onContentChanged(nodeevent as object)
    cn = nodeevent.getData()
    ? "CharterView "; m.top.id; " received new content: "; cn
    if not isInvalid(cn)
        m.bgPoster.uri = cn.logo
        m.titleLabel.text = cn.title
        ' Reposition the output label before populating it to be sure
        ' that our user doesn't see it "jump"
        if cn.outLocation = "above"
            positionOutput(true)
        else
            positionOutput(false)
        end if
        if cn.data <> "" m.outputLabel.text = cn.data
        m.top.color = cn.bgColor
        setButtonFocus(cn)
    end if
    m.content = cn
end sub

'@description Returns a boolean indicating whether or not conditions are right
' to set focus on the BACK button. Both screens are instantiated during startup
' so one or the other is always invisible. Accordingly, the view must be visible
' AND the content's prev/next view has to point to a known view ID in order to
' be able to focus the button.
function isBackEnabled() as boolean
    return m.top.visible and m.content <> invalid and m.content.prevView <> "none"
end function

'@description Returns a boolean indicating whether or not conditions are right
' to set focus on the FORWARD button. Both screens are instantiated during startup
' so one or the other is always invisible. Accordingly, the view must be visible
' AND the content's prev/next view has to point to a known view ID in order to
' be able to focus the button.
function isForwardEnabled() as boolean
    return m.top.visible and m.content <> invalid and m.content.nextView <> "none"
end function

'@description Focuses the forward button after testing to make sure that
' our focus rules allow it, and does nothing otherwise.
'@return Whether or not the button was focused due to focusability criteria
function focusForwardButton() as boolean
    wasFocused = false
    if isForwardEnabled()
        wasFocused = true
        m.forwardButton.setFocus(true)
        m.forwardButton.textColor = "0xFFFFFF"
        m.backButton.textColor = "0x888888"
    end if
    return wasFocused
end function

'@description Focuses the back button after testing to make sure that
' our focus rules allow it, and does nothing otherwise.
'@return Whether or not the button was focused due to focusability criteria
function focusBackButton() as boolean
    wasFocused = false
    if isBackEnabled()
        wasFocused = true
        m.backButton.setFocus(true)
        m.backButton.textColor = "0xFFFFFF"
        m.forwardButton.textColor = "0x888888"
    end if
    return wasFocused
end function

'@description Change the focus in response to keyboard events
'@param key     -   Key that was pressed
'@param press   -   Whether the key was pressed or release
function onKeyEvent(key as String, press as Boolean) as Boolean
    ? "CharterView "; m.top.id; " sees key: "; key; " and press: "; press
    result = false
    if press
        if key = "right"
            ? "Key is RIGHT"
            if m.backButton.hasFocus() and isForwardEnabled()
                ? "BACK had focus and FORWARD is enabled"
                m.forwardButton.setFocus(true)
            end if
            result = true
        else if key = "left"
            ? "Key is LEFT"
            if m.forwardButton.hasFocus() and isBackEnabled()
                ? "FORWARD has focus and BACK is enabled"
                m.backButton.setFocus(true)
            end if
            result = true
        else if key = "back"
            ? "Key is BACK"
            if isBackEnabled()
                ? "BACK is enabled so going back"
                result = true
                m.serviceTask.nav = m.content.prevView
            else
                ' If isBackEnabled is false and we are visible, we're at the first
                ' page. Exit on BACK.
                ' Our scene has backExitsScene set false so we trigger a field
                ' set up to cause an exit
                if m.visible
                    ? "Setting Scene exit flag"
                    m.top.getScene().exitApp = true
                    ? m.top.getScene()
                else
                    ? "BACK but invisible. Doing nothing."
                end if
            end if
        end if
    end if
    return result 
end function