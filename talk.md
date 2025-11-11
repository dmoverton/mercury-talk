---
marp: true
theme: default
class: lead
paginate: true
title: "The Mercury Programming Language"
---

# The Mercury Programming Language

## Melbourne Compose Talk November 2025

### David Overton

---

# Introduction to Mercury

- Logic/functional programming language
- Purely declarative
  - no side effects
  - referential transparency
- Strong static type system
- Strong mode and determinism systems
- "Logic programming for the real world"

---
## Why Another Declarative Language?

- **Prolog:** expressive but dynamically typed and unpredictable  
- **Haskell:** pure and safe but function-centric  
- **Mercury:** bridges the gap — *logic + purity + performance*

> Bringing Haskell-like rigor to the relational world of Prolog.

---

## A Bit of History

- Developed in **1995** at the University of Melbourne  
- Creators: **Zoltan Somogyi, Fergus Henderson, Thomas Conway, et al**  
- Goal: industrial-strength logic programming  
- Compiles to C and native code

---

# Logic Programming

- Predicate logic
- Horn clauses
- Logical connectives
- Unification
- Backtracking

---

# Prolog

```prolog
% facts
parent(alice, bob).
parent(bob, carol).

% rule
grandparent(A, B) :-
  parent(A, C),
  parent(C, B).
```
### Grandparent rule in predicate logic

$$
\begin{align}
\forall A \forall B~ & \mathrm{grandparent}(A, B) \leftarrow \\
    &\exists C~\mathrm{parent}(A, C) \land \mathrm{parent}(C, B)
\end{align}
$$

---

## Problems with Prolog

- Lack of static types, modes and determinism
  - No help from compiler to catch potential errors
  - Hard for compiler to generate efficient code
  - Negation can be unsound
  - Requires use of non-logical constructs (such as *cut*) for efficiency


---



## Example

```mercury
:- pred append(list(T), list(T), list(T)).
:- mode append(in, in, out) is det.

append([], Ys, Ys).
append([X | Xs], Ys, [X | Zs]) :-
  append(Xs, Ys, Zs).
```
compare Haskell code:
```haskell
append :: [a] -> [a] -> [a]
append [] ys = ys
append (x:xs) ys = x : append xs ys
```

---

Could also write `append` as a function:
```mercury
:- func append(list(T), list(T)) = list(T).

append([], Ys) = Ys.
append([X | Xs], Ys) = [X | append(Xs, Ys)].
```
compare Haskell code:
```haskell
append :: [a] -> [a] -> [a]
append [] ys = ys
append (x:xs) ys = x : append xs ys
```

---

... but `append` as a predicate can have other *modes*:

```mercury
:- pred append(list(T), list(T), list(T)).
:- mode append(in, in, out) is det.
:- mode append(in, in, in) is semidet.
:- mode append(in, out, in) is semidet.
:- mode append(out, out, in) is multi.

append([], Ys, Ys).
append([X | Xs], Ys, [X | Zs]) :-
  append(Xs, Ys, Zs).
```
---

```mercury
?- append(Xs, Ys, [1, 2, 3]).
```
multiple solutions:
```mercury
  Xs = [],        Ys = [1, 2, 3]
; Xs = [1],       Ys = [2, 3]
; Xs = [1, 2],    Ys = [3]
; Xs = [1, 2, 3], Ys = []
```
(uses mode `append(out, out, in)`)
Solution space explored through depth-first search and backtracking.

---

## Another example

```mercury
:- pred member(T, list(T)).
:- mode member(in, in) is semidet.
:- mode member(in, out) is nondet.

member(X, [X | _]).
member(X, [_ | Xs]) :-
    member(X, Xs).
```
---

# Mercury types
 - strong static type system
 - type inference (with ad-hoc overloading)
 - algebraic data types
 - higher order types
 - record types with names fields
 - type classes (but no constructor classes :cry:)
 - existential types
 - RTTI

---
 # Example type definitions

<table>
<tr><th/><th>Mercury</th><th>Haskell</th></tr>
<tr>
<th>enum</th>
<td>

```mercury
:- type bool ---> yes ; no.
```

</td>
<td>

```haskell
data Bool = True ; False
```

</td>
</tr>
<tr>
<th>polymorphic type</th>
<td>

```mercury
:- type maybe(T) ---> yes(T) ; no.
```

</td>
<td>

```haskell
data Maybe a = Just a | Nothing
```
</td>
</tr>

<tr>
<th>type alias</th>
<td>

```mercury
:- type width == float.
```
</td>
<td>

```haskell
type Width = Float
```
</td>
</tr>
<tr>
<th>newtype</th>
<td>

```mercury
:- type counter == counter(int).
```
</td>

<td>

```haskell
newtype Counter = Counter Int
```
</td>
</table>

---

## Higher order types

```mercury
:- pred map(pred(T, U), list(T), list(U)).
:- mode map(pred(in, out) is det, in, out) is det.

map(_, [], []).
map(P, [X | Xs], [Y | Ys]) :-
  P(X, Y),
  map(P, Xs, Ys).
```
Currying
```mercury
:- pred add(int, int, int).
:- mode add(in, in, out) is det.

?- map(add(1), [1, 2, 3], Ys).
Ys = [2, 3, 4]
```

---

# Modes

- Describe data flow through _instantiation states_ of variables

```mercury
:- mode in == ground >> ground.
:- mode out == free >> ground.
:- mode unused == free >> free.
```

- Mode declarations for a predicate must give a mode for each argument:

```mercury
:- mode add(in, in, out).
```

- Functions have a default mode where arguments have mode `in` and the function result has mode `out`, unless otherwise specified.

---

# Determinism

Each mode of a predicate or function is categorised by whether or not it can fail and how many solutions it can produce:

- `det`: exactly one solution
- `semidet`: at most one solution (can fail or succeed once)
- `multi`: at least one solution
- `nondet`: zero or more solutions
- `failure`: no solutions (always fails)
- `erroneous`: never returns (infinite loop, exception or runtime error)

---

| max solutions | 0         | 1          | >1      |
| ------------- | --------- | ---------- | ------- |
| cannot fail   | `erroneous` | `det` | `multi` |
| can fail      | `failure` | `semidet` | `nondet` |

---

# Module system

---

# Real example: Zipper
