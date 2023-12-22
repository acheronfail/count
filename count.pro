count(I, Target, Result) :-
    I < Target,
    NewI is (I + 1) \/ 1,
    count(NewI, Target, Result).
count(I, _, I).

main :-
    current_prolog_flag(argv, [TargetString|_]),
    atom_number(TargetString, Target),
    count(0, Target, Result),
    writeln(Result),
    qsave_program('count').
