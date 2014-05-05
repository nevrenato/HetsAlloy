{- |
Module      :  $Header$
License     :  GPLv2 or higher, see LICENSE.txt

Maintainer  : nevrenato@gmail.com
Stability   : experimental
Portability : portable

Description :
Pretty printer.
-}

module Alloy.Print_AS where


import Common.Doc
import Common.DocUtils
import Common.AS_Annotation

import Alloy.AS_Alloy
import Alloy.AlloySign

instance Pretty X where 
         pretty X = undefined

instance Pretty Symbol where
         pretty Symbol = undefined

instance Pretty RawSymbol where
         pretty RawSymbol = undefined


instance Pretty SymbItems where
         pretty SymbItems = undefined

instance Pretty SymbMapItems where
         pretty SymbMapItems = undefined

instance Pretty Sign where
         pretty Sign = undefined

instance Pretty Mor where
         pretty Mor = undefined

instance Pretty Sen where
         pretty Sen = undefined