
{-# LANGUAGE OverloadedStrings
  #-}

import Data.ByteString.Char8

import Criterion.Main

import qualified Text.ShellEscape.Bash as Bash


strings                     ::  [ByteString]
strings                      =  [ "echo * $PWD"
                                , ""
                                , "abcds"
                                , "\x00\n\204\DEL"
                                , "\x00\n\204\DELecho * $PWD" ]

main                         =  defaultMain $ fmap bench' strings
 where
  bench' s                   =  bench (show s) (whnf Bash.escape s)
