{- |
Module      :  $Header$
License     :  GPLv2 or higher, see LICENSE.txt

Maintainer  : nevrenato@gmail.com
Stability   : experimental
Portability : portable

Description :
Alloy grammar.
-}

module Alloy.AS_Alloy where

import Common.Id
import Data.Monoid

-- DrIFT command
{-! global: GetRange !-}

data X = X deriving Show

data Sen = Sen deriving (Show,Eq,Ord)

instance Monoid X where
         mempty = undefined
         mappend = undefined


data Symbol = Symbol deriving (Show,Eq,Ord)
data RawSymbol = RawSymbol deriving (Show,Eq,Ord)
data SymbItems = SymbItems deriving (Show,Eq)
data SymbMapItems = SymbMapItems deriving (Show,Eq)
