:- dynamic ([
       allocated/2,
       available_resources/2,
       requested/2,
       seq/1
           ]).
/*%test-case:1
available_resources(r1,0).
available_resources(r2,0).

allocated(p1,[r1]).
allocated(p2,[r2]).

requested(p2,[r1]).
requested(p3,[r1]).
requested(p3,[r2]).
*/
%test-case:2
available_resources(r1,0).
available_resources(r2,0).

allocated(p1,[r2]).
allocated(p2,[r1]).
allocated(p3,[r1]).
allocated(p4,[r2]).

requested(p1,[r1]).
requested(p3,[r2]).

/*
%test-case:3
available_resources(r1,0).
available_resources(r2,0).
available_resources(r3,0).

allocated(p1,[r2]).
allocated(p2,[r1]).
allocated(p2,[r2]).
allocated(p3,[r3]).
%allocated(p4,[r2]). %no deadlock

requested(p1,[r1]).
requested(p2,[r3]).
requested(p3,[r2]).
*/

release(P,R):-
    allocated(P, [R]),
    not(requested(P,_)).

update_avail(R,Key):-
    available_resources(R,V),
    (   Key== 1 -> NV is V+1; NV is V-1),
    retract(available_resources(R,_)),
    assert(available_resources(R,NV)).

check_req(P,R):-
    requested(P,[R]),
    available_resources(R,V),
    not(V==0).

accept_req(Size,P,R):-
    retract(requested(P,[R])),
    (allocated(P,[X])-> retract(allocated(P,[X])), update_avail(X,1), assert(allocated(P,[R]))
    ;
    assert(allocated(P,[R]))
    ),
    update_avail(R,-1),
    safe_state(Size,_).

safe_state(0,_).

safe_state(Size,S):- %size: number of Processes still in the system

    (   release(P,R)->%check if anyone can be released:
                      retract(allocated(P,[R])), Processes is Size-1, update_avail(R,1),
                      assert(seq(P)),
                      safe_state(Processes,_)

        %ELSE:check if any request can be accepted
        ; (check_req(P,R)->
                          accept_req(Size,P,R)

          %;else: writeln("false, Deadlock")
           )
     ),!,seq(S).

clear:- retractall(seq(_)).



















