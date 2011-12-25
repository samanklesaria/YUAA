{-# LANGUAGE NoImplicitPrelude #-}
module Main where
import Prelude hiding (mapM)
import System.Hardware.Serialport
import Control.Monad hiding (mapM)
import System.Directory
import Data.List (isPrefixOf)
import Control.Concurrent.MVar
import Data.Sequence ((|>), empty, Seq)
import Network.Fancy
import System.IO
import Data.Traversable

main = do
    str <- newMVar empty
    let addChar c = modifyMVar_ str (return . (|> c))
        readLoop p = do
            mc <- recvChar p
            case mc of
              (Just a) -> addChar a >> readLoop p
              Nothing -> return ()
    fpath <- liftM (head . filter (isPrefixOf "cu.usb")) (getDirectoryContents "/dev/")
    let readAgain = withSerial ("/dev/" ++ fpath) defaultSerialSettings readLoop
    streamServer serverSpec{address = (IP "" 9000)} (\h a->
        let serverloop = readMVar str >>= mapM (hPutChar h) >> hFlush h
        in forever serverloop)
    forever readAgain
