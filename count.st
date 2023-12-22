| i target |
i := 0.
target := (Smalltalk arguments first) asInteger.
[i < target] whileTrue: [ i := (i + 1) bitOr: 1 ].
Transcript show: i asString; cr.
