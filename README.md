# Five words. Twenty five letters

## Premise

See `https://www.youtube.com/watch?v=_-AfhLQfb6w&t=1s`

## Based on

There's an awesome solution at `https://gitlab.com/bpaassen/five_clique`
This is a scheme implementation. For fun.

I've written a much more optimized implementation at
https://github.com/stothardj/five-letter-words if speed is all you care about.

## Setup

Clone words\_alpha.txt from https://github.com/dwyl/english-words

I used `dos2unix words_alpha.txt` to convert line endings since I'm running
linux.

## Running

Make sure to have guile3 installed. Depending on where it's installed you may
need to change the first line of five.scm to match.

```
time cat words_alpha.txt | ./five.scm > cliques.txt
```

On my machine the timing is:

```
real	16m9.095s
user	16m17.764s
sys	0m0.236s
```

