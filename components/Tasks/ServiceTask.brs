' The ServiceTask is a combination of a web service and a view controller. In
' this dual role, it's responsible for all of the "work" being performed by
' the app.

'@description Initialize our task, setting up constants, variables and observers
' A larger app would probably separate constants into their own file, but our
' scope is narrow enough here to just do them inline.
sub init()
    ? "Task init"
    m.port = CreateObject("roMessagePort")
    m.constants = {
        "headerKey" : "secret-key",
        "headerValue" : "$2b$10$uFTmoV/NUudBt3K/t8h9H.c08SIwq29I9RiZskcr5k.tU8lvpwfJ2",
        "endpointAddress" : "https://api.jsonbin.io/b/5e7e4017862c46101abf301f"
    }
    m.screenData = {
        "a" : {
            "outLocation" : "below",
            "prevView" : "none",
            "nextView" : "viewb",
            "bgColor" : "0x444444"
        },
        "b" : {
            "outLocation" : "above",
            "prevView" : "viewa",
            "nextView" : "none",
            "bgColor" : "0x880000"
        }
    }
    m.requestContext = {}
    m.currentView = ""
    m.dataArray = []
    m.top.functionName = "mainLoop"
    m.top.observeFieldScoped("state", "onStateChanged")
    m.top.observeFieldScoped("fire", m.port)
    m.top.observeFieldScoped("sound", m.port)
    m.top.observeFieldScoped("nav", m.port)
end sub

'@description Returns an roUrlTransfer object that's set up for downsteam usage
' (other than endpoint). In a larger app, I'd use a "pool" of them, but the
' one-shot nature of our call lets us do something simpler.
'@return urltransfer    -   The requested roUrlTransfer
function setupTransferObject() as object
    ? "Task setting up transfer object"
    urltransfer = createObject("roURLTransfer")
    urltransfer.setPort(m.port)
    urltransfer.retainBodyOnError(true)
    urltransfer.addHeader(m.constants.headerKey, m.constants.headerValue)
    urltransfer.setCertificatesFile("common:/certs/ca-bundle.crt")
    return urltransfer
end function

'@description Track state in a local variable to avoid touching m.top
' every time around the mainLoop. 
'param ev - An roSGNodeEvent containing the field that was changed (state)
sub onStateChanged(nodeevent as object)
    m.state = nodeevent.getData()
    ? "Task state changed ("; m.state; ")"
end sub

'@description Set up references to key elements of the UI that will be referred-to
' multiple times later.
sub getUIElements()
    m.scene = m.top.getScene()
    m.initialView = m.scene.findNode("viewa")
    m.secondView = m.scene.findNode("viewb")
end sub

'@description The main loop for our task. Events received on m.port are
' dispatched to handlers occording to type. The handlers, in turn, provide
' more granular handling (where applicable) based on field data. The loop
' runs as long as the Task's 'state' field is set to 'run'
sub mainLoop()
    ? "Task starting main loop - state: "; m.top.state
    getUIElements()
    while m.state = "run"
        ? "Task in run loop"
        msg = wait(0, m.port)
        mtype = lcase(type(msg))
        ? "Task received message of type "; mtype
        if mtype = "rosgnodeevent" then
            handleNodeEvent(msg)
        else if mtype = "rourlevent" then
            handleUrlEvent(msg)
        else if mtype = "roinvalid" or mtype = "invalid" then
            ' Something timed out?? Never happens with wait(0)
        else
            ' Unsupported event type
            ? "Task received unsupported event type "; mtype
        end if
    end while
end sub

'@description Dispatch handler for roSGNodeEvent events. Events are dispatched to
' worker functions depending on which field has been changed.
' NOTE: Normally, I only use one input field and pass AA's with some kind of
' standardized work request, but decided against doing that here because of 
' the narrow scope of the application.
'@param nodeevent   -   The roSGNodeEvent whose fields we'll test to see which handler to call
sub handleNodeEvent(nodeevent as object)
    nodeid = nodeevent.getNode()
    field = nodeevent.getField()
    ? "Task received node event from "; nodeid; ":"; field
    if field = "fire"
        fireInternetRequest()
    else if field = "nav"
        doNavigation(nodeevent.getData())
    else if field="sound"
        playSystemSound(nodeevent.getData())
    end if
end sub

'@description Gets an roUrlTransfer object, sets the endpoint and adds it
' to a tracking AA keyed on the string value of it's getIdentity() in order
' to later match it up with a response. This app doesn't really need this,
' but I didn't want to preclude later expansion.
sub fireInternetRequest()
    ? "Task is firing internet request"
    transferobj = setupTransferObject()
    transferobj.setUrl(m.constants.endpointAddress)
    m.requestContext.addReplace(transferobj.getIdentity().toStr(), transferobj)
    transferobj.asyncGetToString()
end sub

'@description Navigate the UI to a specified view. If the view doesn't exist,
' nothing happens.
'@param view    -   The ID of the view to which we want to show
'@see makeSafeString in common.brs
sub doNavigation(view as string)
    view = makeSafeString(view)
    ? "Task received navigation request for "; view
    oldview = m.scene.findNode(m.currentView)
    if view <> "" newview = m.scene.findNode(view)
    ' Don't change views if newview is invalid since there's no place to go
    if not isInvalid(newview)
        if not isInvalid(oldview)
            oldview.visible = false
        else
            ? "Task sees oldview IS INVALID"
        end if
        newview.visible = true
        m.currentView = newview.id
    else
        ? "Task sees newview IS INVALID"
    end if
end sub

'@description Handle data returned by our request from the web server. If we get back
' good JSON, we do our sort and separate right up front so the views are never waiting
' on work to be done.
' NOTE: Attempting to operate on nonexistent objects is perhaps the single cause of app
' crashes. While that never happens in this app, real-world data is often less consistent
' and I use a couple of standard (for me) functions to ameliorate that risk and allow
' applications to fail more cleanly.
'@param urlevent    -   The roUrlEvent containing the network response
'@see makeSafeAA in common.brs
'@see makeSafeArray in common.brs
'@see sliceArray in common.brs
sub handleUrlEvent(urlevent as object)
    m.scene.runLoadAnimation = false
    rid = urlevent.getSourceIdentity().toStr()
    rc = urlevent.getResponseCode()
    resp = urlevent.getString()
    ' Have some certainty that we can't leak roUrlTrasfers so
    ' we zap it before removing it's AA entry
    m.requestContext[rid] = invalid
    m.requestContext.delete(rid)
    if rc >= 200 and rc <= 299
        if not isInvalid(resp)
            json = makeSafeAA(parseJson(resp))
            screens = makeSafeAA(json.screens)
            m.dataArray = makeSafeArray(json.data)
            count = m.dataArray.count()
            ' As it turns out, Roku's internal ifArraySort.sort is 3x faster than Quicksort
            ' implemented in Brightscript. Left in, but commented out for documentary
            ' purposes.
            ' quicksortData(m.dataArray, 0, m.dataArray.count()-1)
            m.dataArray.sort("r")
            ' Brightscript doesn't have array slicing, so we implement one of our own
            slicea = sliceArray(m.dataArray, count-5, count-1)
            screens["a"].data = formatJSON(slicea)
            evennumbers = seperateEvenOdd(m.dataArray, "e")
            ' Our algorithm for separating odd and even numbers destroys the sort
            ' order. The requirements don't speak to this, but it made sense to
            ' me that an expectation of always having sorted data was reasonable to
            ' infer. The following line can be commented out to use the 
            evennumbers.sort("r")
            sliceb = sliceArray(evennumbers, 0, 4)
            screens["b"].data = formatJSON(sliceb)
            createAndSetCNs(screens)
            ' Show our initial view
            m.initialView.visible = true
            m.currentView = m.initialView.id
        else
            ? "Task internet request had 2xx result code but no response body"
        end if
    else
        ? "Task internet request returned bad RC. Response text (if any): "; resp
    end if
end sub

'@description Iterate through the 'screens' JSON fragment and setup content nodes
' for each view, then set each into their view's 'content' field.
' NOTE: It seemed to me that the 'screens' element of the JSON pointed to a
' data-driven approach to setting up the screens. There was nothing in the
' returned JSON that would do this completely, so I set up a constant AA to
' contain the color, the above/below positioning data, and next/previous
' screen.
'@param jsonfrag    -   
sub createAndSetCNs(jsonfrag as object)
    ? "Task is creating ContentNodes"
    for each key in jsonfrag
        findID = "view" + key
        ? "Task using "; key; " to setup CN with: "; jsonfrag[key]
        cn = createObject("roSGNode", "CharterContent")
        cn.update(jsonfrag[key])
        cn.update(m.screenData[key])
        m.scene.findNode(findID).content = cn
        ? "Task set content into "; findID
    end for
end sub

'@description A helper function for Quicksort and odd/even separator that
' swaps two elements of an array. Validation for existence and range is
' expected to have occurred upstream. 
'@param arr -   The array being operted on
'@param x   -   Index of the first object to be swapped
'@param y   -   Index of the second item to be swapped
sub swap(arr as object, x as integer, y as integer)
    temp = arr[x]
    arr[x] = arr[y]
    arr[y] = temp
end sub

'@description An implementation of Quicksort returning descending order.
' NOTE: I found by experimentation that Roku's ifArraySort.sort() is 3x
' faster than this implementation of QS, so this code isn't used but left
' in for documentary purposes.
'param arr      -   The array (or "sub-array") to be sorted
'param low      -   The lowest index to be sorted
'@param high    -   The highest index to be sorted
sub quicksortData(arr as object, low as integer, high as integer)
    middle = fix(low + (high - low) / 2)
    pivot = arr[middle]
    i = low
    j = high
    while (i <= j)
        while (arr[i] > pivot)
            i++
        end while
        while (arr[j] < pivot)
            j--
        end while
        if i <= j
            swap(arr, i, j)
            i++
            j--
        end if
    end while
    if low < j
        quicksortData(arr, low, j)
    end if
    if high > i
        quicksortData(arr, i, high)
    end if
end sub

'@description Separate an array of integers into odd and even elements and
' return either the odd or even subset.
' NOTE: The output array won't be ordered in the same way as the input, but
' we'll leave that for the caller to handle
'@param arr     -   The array to be operated on
'@param flag    -   Whether the caller wants back the odd number or the even
'@return The subset of the input array containing either the odd or even elements, as requested
'@see makeSafeArray in common.brs
'@see makeSafeString in common.brs
'@see sliceArray in common.brs
function seperateEvenOdd(arr as object, flag="o" as string) as object
    arr = makeSafeArray(arr)
    flag = makeSafeString(flag)
    if flag <> "e" and flag <> "o"
        ? "seperateEvenOdd: Parameter error, flag must be [e]ven or [o]dd"
        return []
    end if
    arr = makeSafeArray(arr)
    count = arr.count()
    if count = 0 return []
    left_index = 0
    right_index = count - 1
    while (left_index < right_index)
        while (arr[left_index] mod 2 = 0 and left_index < right_index)
            left_index++
        end while
        while (arr[right_index] mod 2 = 1 and left_index < right_index)
            right_index--
        end while
        if left_index < right_index
            swap(arr, left_index, right_index)
            left_index++
            right_index--
        end if
    end while
    ' At this point, both left_index and right_index point to the first odd number
    if flag = "o"
        return sliceArray(arr, right_index, arr.count()-1)
    else
        return sliceArray(arr, 0, right_index-1)
    end if
end function

