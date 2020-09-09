function getTimestamp() as string
    dt = CreateObject ("roDateTime")
    return dt.AsSeconds ().ToStr () + Right ("00" + dt.GetMilliseconds ().ToStr (), 3)
end function

function isInvalid(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "roinvalid") or (lctype = "invalid") or (lctype = "<uninitialized>")
end function

function isString(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "string") or (lctype = "rostring")
end function

function isAA(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "assocarray") or (lctype = "roassociativearray")
end function

function isArray(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "array") or (lctype = "roarray")
end function

function isInteger(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "integer") or (lctype = "rointeger")
end function

function makeSafeString(obj) as string
    if isString(obj)
        return obj
    end if
    return ""
end function

function makeSafeAA(obj) as object
    if isAA(obj)
        return obj
    endif
    return {}
end function

function makeSafeArray(obj) as object
    if isArray(obj)
        return obj
    end if
    return []
end function

function makeSafeInteger(obj) as integer
    if isInteger(obj)
        return obj
    end if
    return 0
end function

function sliceArray(arr as object, low as integer, high as integer, interval=1 as integer) as object
    arr = makeSafeArray(arr) : low = makeSafeInteger(low) : high = makeSafeInteger(high) : interval = makeSafeInteger(interval)
    ? "sliceArray: arr contains: "; arr.count(); " low="; low; " high="; high; " interval="; interval
    if interval <= 0 or interval >= arr.count()-1
        ? "sliceArray parameter (interval) error. Interval is <= 0 or >= array size"
        return []
    end if
    if low < 0 or high >= arr.count() or high-low < interval
        ? "sliceArray parameter (high and/or low) error"
        return []
    end if
    newarr = []
    for i = low to high step interval
        newarr.push(arr[i])
    end for
    return newarr
end function

sub printArray(arr as object)
    ? "printArray: ["
    for i = 0 to arr.count() - 1
        ? "    ["; i; "] "; arr[i]
    end for
    ? "]"
end sub