'@description Returns a string containing the current epoch time in milliseconds
' I used this to time my Quicksort and Roku's internal sort to see which was
' faster
'@return epochms    -    A string representing the current epoch time in milliseconds
function getTimestamp() as string
    dt = CreateObject ("roDateTime")
    return dt.AsSeconds ().ToStr () + Right ("00" + dt.GetMilliseconds ().ToStr (), 3)
end function

' A subset of some functions I use a lot to prevent app crashes and allow apps
' to fail more cleanly.

'@description Returns a boolean representing whether or not the supplied object
' is either invalid or uninitialized
'@param obj     -   The object to be tested
'@return TRUE if the object is invalid or uninitialized, FALSE otherwise
function isInvalid(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "roinvalid") or (lctype = "invalid") or (lctype = "<uninitialized>")
end function

'@description Returns a boolean representing whether or not the supplied object
' is a string
'@param obj     -   The object to be tested
'@return TRUE if the object is a string, FALSE otherwise
function isString(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "string") or (lctype = "rostring")
end function

'@description Returns a boolean representing whether or not the supplied object
' is a associative array
'@param obj     -   The object to be tested
'@return TRUE if the object is an AA, FALSE otherwise
function isAA(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "assocarray") or (lctype = "roassociativearray")
end function

'@description Returns a boolean representing whether or not the supplied object
' is an array
'@param obj     -   The object to be tested
'@return TRUE if the object is an array, FALSE otherwise
function isArray(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "array") or (lctype = "roarray")
end function

'@description Returns a boolean representing whether or not the supplied object
' is an integer
'@param obj     -   The object to be tested
'@return TRUE if the object is an integer, FALSE otherwise
function isInteger(obj) as boolean
    lctype = lcase(type(obj))
    return (lctype = "integer") or (lctype = "rointeger")
end function

'@description Makes an string "safe" by making sure that a valid string was
' supplied, and either returning the supplied object, or an empty string
' to enable to application to fail cleaner.
'@param obj      -   The object to be tested for safety and returned
'@return Either the supplied string or an empty string
function makeSafeString(obj) as string
    if isString(obj)
        return obj
    end if
    return ""
end function

'@description Makes an AA "safe" by making sure that a valid AA was
' supplied, and either returning the supplied object, or an empty AA
' to enable to application to fail cleaner.
'@param obj      -   The object to be tested for safety and returned
'@return Either the supplied AA or an empty AA
function makeSafeAA(obj) as object
    if isAA(obj)
        return obj
    endif
    return {}
end function

'@description Makes an array "safe" by making sure that a valid array was
' supplied, and either returning the supplied object, or an empty array
' to enable to application to fail cleaner.
'@param obj      -   The object to be tested for safety and returned
'@return Either the supplied array or an empty array
function makeSafeArray(obj) as object
    if isArray(obj)
        return obj
    end if
    return []
end function

'@description Makes an integer "safe" by making sure that a valid integer was
' supplied, and either returning the supplied object, or zero
' to enable to application to fail cleaner.
'@param obj      -   The object to be tested for safety and returned
'@return Either the supplied array or an empty array
function makeSafeInteger(obj) as integer
    if isInteger(obj)
        return obj
    end if
    return 0
end function

'@description Provide an array slicer woefully missing from Brightscript. A subset of the provided
' array is returned comprising elements between the indexes 'low' and 'high' and allowing for a
' "step" interval that defaults to one.
'@param arr     -   The array to be split
'@param low     -   The low index of the sub-array to be returned
'@param high    -   The high index of the sub-array to be returned
'@param interval-   A step parameter in case we only want every other (etc.) element
'@return A subset of the input array split according to the parameters
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