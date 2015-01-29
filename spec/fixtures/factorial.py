#!/usr/bin/env python
# Content above the snippet is ignored

print 'Hello, world!'

# {{snippet factorial}}
def factorial(n):
    if n == 0:
        return 1
    else:
        return n * factorial(n-1)
# {{endsnippet}}

# So is content below the snippet
print "{{snippet factorial_result}}"
print "The result of factorial(7) is:"
print "  %d" % factorial(7)
print "{{endsnippet}}"