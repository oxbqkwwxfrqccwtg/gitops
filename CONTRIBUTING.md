


# Error Handling

Evaluations of conditions SHOULD be handled through `case` statement. A
catch-all is only required, if the 

Error messages should follow the indentation level of the wrapping function
call statement. Code readability takes precedence, since we gain more code
readability, than we loose error discoverability. It will "just" look a little
weird, but I could swear I've seen other people doing it in their
configure.ac and it wasn't too weird too me.

