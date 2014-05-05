{-# LANGUAGE MultiParamTypeClasses  #-}
{- |
Module      :  $Header$
License     :  GPLv2 or higher, see LICENSE.txt

Maintainer  : nevrenato@gmail.com
Stability   : experimental
Portability : portable

Description :
Alloy as an institution.
-}

module Alloy.Logic_Alloy where

import Logic.Logic
import Alloy.AS_Alloy
import Alloy.AlloySign
import Alloy.Parse_AS
import Alloy.Print_AS
import Alloy.StatAna
import Alloy.ATC_Alloy ()

data Alloy = Alloy deriving Show

instance Language Alloy where
         description _ = "Implementation of the Alloy language"

instance Category Sign Mor where
         -- identity morphisms        
         ide = undefined
         -- the inverse of a morphism
         inverse = undefined
         -- composition of morphisms
         composeMorphisms = undefined
         -- dom of morphism
         dom = undefined
         -- cod of morphism
         cod = undefined
         -- tests if the morphism is an inclusion
         isInclusion = undefined
         -- legal morphism ?
         legal_mor = undefined

instance Syntax Alloy X Symbol SymbItems SymbMapItems where
         parse_basic_spec Alloy = Nothing

instance Sentences Alloy Sen Sign Mor Symbol where

instance StaticAnalysis Alloy X Sen SymbItems SymbMapItems 
         Sign Mor Symbol RawSymbol where
         empty_signature Alloy = undefined

instance Logic Alloy () X Sen SymbItems SymbMapItems Sign Mor Symbol
         RawSymbol () where