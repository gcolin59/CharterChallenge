sub init()
    m.top.SetFocus(true)
    m.top.backExitsScene = false
    m.top.observeFieldScoped("runLoadAnimation", "onRunLoadAnimationChanged")
    createNodes()
end sub

'@description Start up the application by creating the service task. The task is
' responsible for setting content into the UI, navigating it, and anything processor-intensive.
' Both views are created with visible=false. The service task will set view A visible once the
' data is loaded in order to avoid the user seeing empty screens.
sub createNodes()
    ? "Scene creating service task"
    m.serviceTask = createObject("roSGNode", "ServiceTask")
    m.serviceTask.id = "serviceTask"
    m.top.serviceTask = m.serviceTask
    '
    ? "Scene creating View A"
    viewa = createObject("roSGNode", "CharterView")
    viewa.id = "viewa"
    viewa.visible = false
    m.top.appendChild(viewa)
    '
    ? "Scene creating View B"
    viewb = createObject("roSGNode", "CharterView")
    viewb.id = "viewb"
    viewb.visible = false
    m.top.appendChild(viewb)
    '
    m.loadingProgress = createObject("roSGNode", "LoadingIndicator")
    m.loadingProgress.imageUri = "pkg:/images/loader.png"
    m.loadingProgress.backgroundColor = "0x00000000"
    m.loadingProgress.imageWidth = 100
    m.loadingProgress.fadeInterval = 0.2
    m.top.appendChild(m.loadingProgress)
    m.loadingProgress.text = "Loading..."
    m.loadingProgress.control = "start"
    m.loadingProgress.visible = true
    '
    m.serviceTask.control = "run"
    ? "Scene sending 'fire' to task"
    m.serviceTask.fire = true
end sub

'@description Start or stop the loading animation according to changed in
' the Scene's 'runLoadAnimation' field. The LoadingIndicator is shown when
' the app starts, and the ServiceTask sets the field false when the data
' is retrieved.
'@param nodeevent   -   An roSGNodeEvent containing the changed field
sub onRunLoadAnimationChanged(nodeevent as object)
    shouldrun = nodeevent.getData()
    if shouldrun
        m.loadingProgress.control = "start"
        m.loadingProgress.visible = true
    else
        m.loadingProgress.control = "stop"
        m.loadingProgress.visible = false
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    
    return result 
end function
