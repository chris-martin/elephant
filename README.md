# elephant

![](https://travis-ci.org/chris-martin/elephant.svg)

This demo project was inspired by [a Stack Overflow question][1] which asks:

> How can I re-assign a variable in a function in Haskell?

> For example,

> ```haskell
> elephant = 0
>
> function x = elephant = x
> ```

The short answer is that we don't have a language-level mechanism to model that
sort of thing in Haskell, and it's generally not what you want anyway.

This project provides the *long answer*, demonstrating how to use a lens with a
state monad class to produce a sort of direct translation of the
imperative-programming concept of reassigning a variable.

We end up writing a program that looks like this:

```haskell
do
  printElephant
  function 2
  printElephant
```

When the value of elephant is initialized as zero, this program prints `0` and
then `2`.

  [1]: https://stackoverflow.com/questions/43525193
