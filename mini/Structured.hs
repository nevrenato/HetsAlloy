module Structured where

import Grothendieck

data SPEC = Basic_spec G_basic_spec     -- unstructured specifications
          | Intra_Translation SPEC G_symbol_mapping_list  -- renaming within a logic
          | Inter_Translation SPEC AnyTranslation    -- translation between logics
          | Extension SPEC SPEC            -- hierarchical extension or union
          deriving Show

data Env = Basic_env G_theory
         | Intra_Translation_env G_theory Env G_morphism
         | Inter_Translation_env G_theory Env AnyTranslation
         | Extension_env G_theory Env Env
