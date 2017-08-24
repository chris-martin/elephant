{-# LANGUAGE ConstraintKinds, InstanceSigs, PackageImports #-}

module Elephant where

-- This demonstration was inspired by a Stack Overflow question which asks:
--
--     How can I re-assign a variable in a function in Haskell?
--
--     For example,
--
--         elephant = 0
--
--         setElephant x =
--             elephant = x
--
-- The short answer is that we don't have a language-level mechanism to model
-- that sort of thing in Haskell, and it's generally not what you want anyway.
--
-- Here we provide the ~long answer~, demonstrating how to use the
-- 'microlens-mtl' library to produce something that looks like a direct
-- translation of the imperative-programming concept of reassigning a variable.

import "base"          Control.Monad.IO.Class    ( MonadIO (liftIO) )
import "microlens"     Lens.Micro                ( Lens', lens )
import "microlens-mtl" Lens.Micro.Mtl            ( (.=), use )
import "mtl"           Control.Monad.State.Class ( MonadState )
import "transformers"  Control.Monad.Trans.State ( StateT (runStateT) )

type Elephant =  -- Let's assume that elephants
  Integer        -- can be modeled by integers.

class HasElephant a  -- Here we define what it means to have an elephant.
  where
    elephant :: Lens' a Elephant  -- A lens captures this notion nicely.

type HasElephantState s m =  -- We'll say that a monad "has elephant state" if
  ( MonadState s m           -- it has state,
  , HasElephant s )          -- and its state has an elephant.

setElephant  -- Now we can define the action that the question asks for.
  :: HasElephantState s m  -- It operates in some monad that has elephant state,
  => Elephant -> m ()
setElephant x =
  elephant .= x            -- and it assigns a new value to the elephant state.

printElephant  -- Let's also define an action that prints the elephant.
  :: ( HasElephantState s m  -- In addition to elephant state,
     , MonadIO m )           -- this context also requires I/O.
  => m ()
printElephant =
  do
    e <- use elephant
    liftIO (putStrLn ("The current elephant is " ++ show e))

data Congo = Congo  -- The African forest elephant (Loxodonta cyclotis) is a
                    -- forest-dwelling species of elephant found in the Congo
                    -- Basin.
  { congoElephant :: Elephant }

instance HasElephant Congo  -- We must define the way in which the 'Congo' has
                            -- an elephant.
  where
    elephant :: Lens' Congo Elephant
    elephant =
      lens                  -- The lens defines
        congoElephant       -- how to get an elephant from the Congo,
        (\a b ->            -- and how to put an elephant into the Congo.
          a{ congoElephant = b })

main'                                   -- Now we can write a program.
  :: (HasElephantState s m, MonadIO m)  -- It has the same context as above.
  => m ()
main' =
  do
    printElephant  -- Our program prints the value of 'elephant',
    setElephant 2  -- then changes the value of 'elephant',
    printElephant  -- then prints it again.

main :: IO ()  -- Then we can convert this program to IO to make it executable.
main =
  let
    program =                          -- StateT Congo IO () is a convenient
      main' :: StateT Congo IO ()      -- specialization of main'.
    initialState =                     -- We use a Congo with elephant zero
      Congo{ congoElephant = 0 }       -- as our program's initial state.
  in
    () <$ runStateT program initialState

{- |

>>> main
The current elephant is 0
The current elephant is 2

-}
