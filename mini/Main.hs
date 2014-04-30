{-# LANGUAGE ScopedTypeVariables, MultiParamTypeClasses, DeriveDataTypeable #-}

module Main where

import Text.ParserCombinators.Parsec
import Logic
import Grothendieck
import Parser
import StaticAnalysis

import Data.Dynamic

data L1 = L1 deriving (Typeable, Show)
data L2 = L2 deriving (Typeable, Show)

instance Language L1 where language_name _ = "L1"
instance Language L2 where language_name _ = "L2"

data B1 = B1 deriving (Typeable, Show, Eq)
data B2 = B2 deriving (Typeable, Show, Eq)

instance Category L1 B1 B1 where
         identity = undefined
         o = undefined
         dom = undefined
         cod = undefined
instance Category L2 B2 B2 where
         identity = undefined
         o = undefined
         dom = undefined
         cod = undefined


instance Syntax L1 B1 B1 B1 B1 where
    parse_basic_spec _ =
      do string "{}"
         spaces
         return B1
    parse_symbol_mapping _ =
      do string "m"
         spaces
         return B1
    parse_sentence = undefined
instance Syntax L2 B2 B2 B2 B2 where
    parse_basic_spec _ =
      do string "#"
         spaces
         return B2
    parse_symbol_mapping _ =
      do string "n"
         spaces
         return B2
    parse_sentence = undefined

instance StaticAnalysis L1 B1 B1 B1 B1 B1 where
         basic_analysis _ sig b = Just (sig, [])
         stat_symbol_mapping = undefined
instance StaticAnalysis L2 B2 B2 B2 B2 B2 where
         basic_analysis _ sig b = Just (sig, [])
         stat_symbol_mapping = undefined

instance Logic L1 B1 B1 B1 B1 B1 where
   empty_signature _ = B1
   map_sentence = undefined
   prover = undefined
instance Logic L2 B2 B2 B2 B2 B2 where
   empty_signature _ = B2
   map_sentence = undefined
   prover = undefined

{-
th1 = (G_theory L1 (B1,[]))
sp1 = (Basic_spec (G_basic_spec L1 B1))
sp2 = (Basic_spec (G_basic_spec L2 B2))
-}

t1 = Logic_translation L1 L2 (\ B1 -> B2) (\ B1 -> B2) (\ _ B1 -> Just B2) (\ _ B2 -> Just B1)
logicGraph = ([("L1", G_logic L1), ("L2", G_logic L2)],
              [("T1", G_LTR t1)])

instance Eq AnyLogic where
  (G_logic i1) == (G_logic (i2 :: id2)) =
     case coerce i1 :: Maybe id2 of
         Just _ -> True
         _ -> False

instance Show AnyLogic where
  show id = case lookup id (map (\ (x, y) -> (y, x)) (fst logicGraph)) of
     Nothing -> "???"
     Just s -> "Logic: " ++ s

p s = do let output = hetParse logicGraph s
         print output

main = do putStrLn "Enter spec\n"
          s <- readLn
          p s
