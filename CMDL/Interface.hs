{-# LANGUAGE CPP #-}
{- |
Module      : $Header$
Description : The definition of CMDL interface for
              standard input and file input
Copyright   : uni-bremen and DFKI
License     : GPLv2 or higher, see LICENSE.txt
Maintainer  : r.pascanu@jacobs-university.de
Stability   : provisional
Portability : portable

CMDL.Interface describes the interface specific function
for standard input and file input
-}

module CMDL.Interface where

#ifdef HASKELINE
import System.Console.Haskeline
import Interfaces.DataTypes
import Comorphisms.LogicGraph (logicGraph)
import Proofs.AbstractState (getConsCheckers, sublogicOfTheory, getCcName )
import Logic.Grothendieck
#endif

import System.IO

import CMDL.Commands (getCommands)
import CMDL.DataTypes
import CMDL.DataTypesUtils
import CMDL.Shell
import CMDL.ProcessScript
import CMDL.Utils (stripComments)

import Interfaces.Command

import Common.Utils (trim)

import Data.List

import Data.IORef
import Control.Monad
import Control.Monad.Trans (MonadIO (..))

#ifdef HASKELINE
shellSettings :: IORef CmdlState -> Settings IO
shellSettings st =
  Settings {
      complete = cmdlComplete st
    , historyFile = Just "consoleHistory.tmp"
    , autoAddHistory = True
  }

{- We need an MVar here because our CmdlState is no Monad
   (and we use IO as Monad). -}

showCmdComplete :: CmdlState -> [String] -> [String] -> String ->
                    IO (String, [Completion])
showCmdComplete state shortConsCList comps left = do
  let (_, nodes) = case i_state $ intState state of
                     Nothing -> ("", [])
                     Just dgState -> getSelectedDGNodes dgState
      cmdss = "prove-all" : map (cmdNameStr . cmdDescription) getCommands
      cmds = cmdss ++ (map ("cons-checker " ++) shortConsCList)
      cmdcomps = filter (isPrefixOf (reverse left)) cmds
      cmdcomps' = if null nodes
                          then filter (not . isSuffixOf "-current") cmdcomps
                          else cmdcomps
  return ("", map simpleCompletion $ comps ++ cmdcomps')

cmdlComplete :: IORef CmdlState -> CompletionFunc IO
cmdlComplete st (left, _) = do

  state <- liftIO $ readIORef st
  comps <- liftIO $ cmdlCompletionFn getCommands state $ reverse left

  if isPrefixOf (reverse left) "cons-checker "
   then
    case i_state $ intState state of
     Just pS ->
       case elements pS of
        Element z _ : _ ->
          do
           let consCheckList = getConsCheckers $ findComorphismPaths
                                  logicGraph $ sublogicOfTheory z
               shortConsCList = nub $ map (\ (y, _) -> getCcName y)
                                       consCheckList
           showCmdComplete state shortConsCList comps left
        [] -> showCmdComplete state [] comps left
     Nothing -> showCmdComplete state [] comps left
   else showCmdComplete state [] comps left

#endif

#ifdef HASKELINE
getMultiLineT :: String -> String -> InputT IO (Maybe String)
getMultiLineT prompt past = do
  minput <- getInputLine prompt
  case minput of
          Nothing -> return Nothing
          Just input -> let
                  str = reverse input
                  has = hasSlash str
                in if has then
                  getMultiLineT prompt ( past ++ (reverse (takeOutSlash str)))
                else
                  return $ Just $ past ++ input
#endif

hasSlash :: String -> Bool
hasSlash x = case x of
        '\\' : _ -> True
        ' ' : ls -> hasSlash ls
        '\n' : ls -> hasSlash ls
        _ -> False

takeOutSlash :: String -> String
takeOutSlash str = case str of
          '\\' : ls -> ls
          '\n' : ls -> takeOutSlash ls
          ' ' : ls -> takeOutSlash ls
          l -> l


getLongLine :: IO String
getLongLine = do
  l <- getLine
  if isSuffixOf "\\" l then fmap (init l ++) getLongLine else return l

shellLoop :: IORef CmdlState
          -> Bool
#ifdef HASKELINE
          -> InputT IO CmdlState
#else
          -> IO CmdlState
#endif
shellLoop st isTerminal =
  do
    state <- liftIO $ readIORef st
    let prompt = if isTerminal then generatePrompter state else ""
#ifdef HASKELINE
    minput <- getMultiLineT prompt ""
#else
    putStr prompt
    hFlush stdout
    eof <- isEOF
    minput <- if eof then return Nothing else liftM Just getLongLine

#endif
    case minput of
      Nothing -> return state
      Just input ->
        do
          let echo = trim $ stripComments input
          when (not isTerminal && not (null echo))
               (liftIO $ putStrLn $ generatePrompter state ++ echo)
          (state', mc) <- liftIO $ cmdlProcessString "" 0 input state
          case mc of
            Nothing -> if elem input ["exit", ":q"] -- additional exit cmds
                         then return state'
                         else do
                                liftIO $ putStrLn $ "Unknown command: " ++ input
                                shellLoop st isTerminal
            Just ExitCmd -> return state'
            Just c -> do
                        newState <- liftIO $ printCmdResult state'
                        newState' <- liftIO $ case find
                                       (eqCmd c . cmdDescription) getCommands of
                                         Nothing -> return newState
                                         Just cm -> checkCom
                                              cm { cmdDescription = c } newState
                        liftIO $ writeIORef st newState'
                        shellLoop st isTerminal

-- | The function runs hets in a shell
cmdlRunShell :: CmdlState -> IO CmdlState
cmdlRunShell state = do
  isTerminal <- hIsTerminalDevice stdin
  st <- newIORef state
#ifdef HASKELINE
  runInputT (shellSettings st) $ shellLoop st isTerminal
#else
  hSetBuffering stdin LineBuffering
  shellLoop st isTerminal
#endif
