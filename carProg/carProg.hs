module Main where
import System.Hardware.Serialport
import Control.Monad
import System.Directory
import Data.List (isPrefixOf)
import Control.Concurrent.Chan
import Network.Fancy
import System.IO

main = do
    chan <- newChan
    let readLoop p = do
            mc <- recvChar p
            case mc of
              (Just a) -> writeChan chan a >> readLoop p
              Nothing -> readLoop p
    fpath <- liftM (safeHead . filter (isPrefixOf "cu.usb")) (getDirectoryContents "/dev/")
    let readAgain = withSerial ("/dev/" ++ fpath) defaultSerialSettings readLoop
    streamServer serverSpec{address = (IP "" 9000)} (\h a-> do
        chan' <- dupChan chan
        let serverloop = readChan chan' >>= hPutChar h >> hFlush h
        forever serverloop)
    forever readAgain

safeHead ls = if null ls then error "Can't find serial device" else head ls