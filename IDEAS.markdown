It would be cool to specify a syntax for selects, inserts, replaces, and deletes.

Maybe something like:

# get the names of all functions
# -s = select, -f = function level
spatch -s -f "name" file1.php

# delete functions beginning with test*
spatch -s -f "name" file1.php | grep "^test" | spatch -d -f file1.php

Basically, something that works with unix utilities but will work on a PHP AST.
