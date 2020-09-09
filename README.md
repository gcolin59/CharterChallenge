# CharterChallenge
Demo app for Charter/Spectrum interview

A simple two screen app that downloads and displays data from a remote endpoint. 
The data defines two screens and a set of integers. The integers are to be sorted
in descending order displaying the last five results on the first screen as well
as segregating the odd and even results in order to display the first five even
numbers on the second screen.

The two views are subclassed from Rectangle so that the components can just be
translated into position. Since they differ only by background color and the
location of the output Label, I wanted to make them instances of the same class
and configurable by data in a ContentNode (CharterContent). I used an AA
containing the additional data for each view added into the supplied JSON's
**screens** for the respective views, supplying color, location, and IDs for
previous and next views.

Both views are instantiated at startup, and navigating between them is accomplished
by setting the **visible** field of each. Because of this, focus and key events are
tested to see if they are for the visible view before acting on them. This is a
strategy I like to use in my smaller apps in order to make the user's experience as
responsive as possible. 

I used a single Task as a combination web service and view controller as well as
a worker to perform the sort and segregate the odd and even numbers. In my larger
apps I've had a lot of success using a Task as a view controller to achieve
consistent navigation and back-stack maintenance.

Algorithms to segregate numbers by attributes like odd or even-ness
that I'm familiar with disrupt the element ordering and the requirements didn't 
speak to whether the even numbers shown on Screen B should be sort ordered, or 
shown as the segregation algoritm left them. In the end, I re-sorted them because
that made the most sense to me, but the sort could be commented-out, of course.

Finally, I added some functions that I use a lot to prevent crashes from addressing
objects that turn out to be **invalid** even though that can't really happen in this
app, as well as a quick array slicing function since Brightscript doesn't have one
in common.brs.
