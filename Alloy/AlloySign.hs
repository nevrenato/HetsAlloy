{- |
Module      :  $Header$
License     :  GPLv2 or higher, see LICENSE.txt

Maintainer  : nevrenato@gmail.com
Stability   : experimental
Portability : portable

Description :
Alloy signature definition.
-}


module Alloy.AlloySign where

import Alloy.AS_Alloy

data Sign = Sign deriving (Show, Eq, Ord)

data Mor = Mor deriving (Show, Eq, Ord)