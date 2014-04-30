{- |
Module      :  $Header$
Copyright   :  Heng Jiang, Uni Bremen 2007
License     :  GPLv2 or higher, see LICENSE.txt

Maintainer  :  Christian.Maeder@dfki.de
Stability   :  provisional
Portability :  portable

OWL 2 signature and sentences
-}

module OWL2.Sign where

import OWL2.AS

import qualified Data.Set as Set
import qualified Data.Map as Map

import Common.Lib.State
import Common.Result

import Control.Monad

data Sign = Sign
            { concepts :: Set.Set Class
              -- classes
            , datatypes :: Set.Set Datatype -- datatypes
            , objectProperties :: Set.Set ObjectProperty
              -- object properties
            , dataProperties :: Set.Set DataProperty
              -- data properties
            , annotationRoles :: Set.Set AnnotationProperty
              -- annotation properties
            , individuals :: Set.Set Individual  -- named individuals
            , prefixMap :: PrefixMap
            } deriving (Show, Eq, Ord)

data SignAxiom =
    Subconcept ClassExpression ClassExpression   -- subclass, superclass
  | Role (DomainOrRangeOrFunc (RoleKind, RoleType)) ObjectPropertyExpression
  | Data (DomainOrRangeOrFunc ()) DataPropertyExpression
  | Conceptmembership Individual ClassExpression
    deriving (Show, Eq, Ord)

data RoleKind = FuncRole | RefRole deriving (Show, Eq, Ord)

data RoleType = IRole | DRole deriving (Show, Eq, Ord)

data DesKind = RDomain | DDomain | RIRange deriving (Show, Eq, Ord)

data DomainOrRangeOrFunc a =
    DomainOrRange DesKind ClassExpression
  | RDRange DataRange
  | FuncProp a
    deriving (Show, Eq, Ord)

emptySign :: Sign
emptySign = Sign
  { concepts = Set.empty
  , datatypes = Set.empty
  , objectProperties = Set.empty
  , dataProperties = Set.empty
  , annotationRoles = Set.empty
  , individuals = Set.empty
  , prefixMap = Map.empty
  }

diffSig :: Sign -> Sign -> Sign
diffSig a b =
    a { concepts = concepts a `Set.difference` concepts b
      , datatypes = datatypes a `Set.difference` datatypes b
      , objectProperties = objectProperties a
            `Set.difference` objectProperties b
      , dataProperties = dataProperties a `Set.difference` dataProperties b
      , annotationRoles = annotationRoles a `Set.difference` annotationRoles b
      , individuals = individuals a `Set.difference` individuals b
      }

addSymbToSign :: Sign -> Entity -> Result Sign
addSymbToSign sig ent =
 case ent of
   Entity Class eIri ->
    return sig {concepts = Set.insert eIri $ concepts sig}
   Entity ObjectProperty eIri ->
    return sig {objectProperties = Set.insert eIri $ objectProperties sig}
   Entity NamedIndividual eIri ->
    return sig {individuals = Set.insert eIri $ individuals sig}
   _ -> return sig

addSign :: Sign -> Sign -> Sign
addSign toIns totalSign =
    totalSign {
                concepts = Set.union (concepts totalSign)
                                     (concepts toIns),
                datatypes = Set.union (datatypes totalSign)
                                      (datatypes toIns),
                objectProperties = Set.union (objectProperties totalSign)
                                           (objectProperties toIns),
                dataProperties = Set.union (dataProperties totalSign)
                                            (dataProperties toIns),
                annotationRoles = Set.union (annotationRoles totalSign)
                                            (annotationRoles toIns),
                individuals = Set.union (individuals totalSign)
                                        (individuals toIns)
              }

isSubSign :: Sign -> Sign -> Bool
isSubSign a b =
    Set.isSubsetOf (concepts a) (concepts b)
       && Set.isSubsetOf (datatypes a) (datatypes b)
       && Set.isSubsetOf (objectProperties a) (objectProperties b)
       && Set.isSubsetOf (dataProperties a) (dataProperties b)
       && Set.isSubsetOf (annotationRoles a) (annotationRoles b)
       && Set.isSubsetOf (individuals a) (individuals b)

symOf :: Sign -> Set.Set Entity
symOf s = Set.unions
  [ Set.map (Entity Class) $ concepts s
  , Set.map (Entity Datatype) $ datatypes s
  , Set.map (Entity ObjectProperty) $ objectProperties s
  , Set.map (Entity DataProperty) $ dataProperties s
  , Set.map (Entity NamedIndividual) $ individuals s
  , Set.map (Entity AnnotationProperty) $ annotationRoles s ]

-- | takes an entity and modifies the sign according to the given function
modEntity :: (IRI -> Set.Set IRI -> Set.Set IRI) -> Entity -> State Sign ()
modEntity f (Entity ty u) = do
  s <- get
  let chg = f u
  unless (isDatatypeKey u || isThing u) $ put $ case ty of
    Datatype -> s { datatypes = chg $ datatypes s }
    Class -> s { concepts = chg $ concepts s }
    ObjectProperty -> s { objectProperties = chg $ objectProperties s }
    DataProperty -> s { dataProperties = chg $ dataProperties s }
    NamedIndividual -> if isAnonymous u then s
         else s { individuals = chg $ individuals s }
    AnnotationProperty -> s {annotationRoles = chg $ annotationRoles s}

-- | adding entities to the signature
addEntity :: Entity -> State Sign ()
addEntity = modEntity Set.insert
