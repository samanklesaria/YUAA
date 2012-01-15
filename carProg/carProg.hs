module Main where
import System.Hardware.Serialport
import Control.Monad
import System.Directory
import Data.List (isPrefixOf)
import Control.Concurrent
import Control.Concurrent.Chan
import Network.Fancy
import System.IO
import System.Posix.Time

-- to make this work, just use parsing tags and make them thread safe.
-- otherise shared resource trouble

-- suppress errors

main = do
    chan <- newChan
    e <- epochTime
    logPath <- openFile ("./" ++ show e) AppendMode
    fpath <- liftM (safeHead . filter (isPrefixOf "cu.usb")) (getDirectoryContents "/dev/")
    s <- openSerial ("/dev/" ++ fpath) defaultSerialSettings
    streamServer serverSpec{address = (IP "" 9000)} (\h a-> do
        chan' <- dupChan chan
        let serverloop = readChan chan' >>= hPutChar h >> hFlush h
        forkIO $ forever serverloop
        let readerloop = hGetChar h >>= sendChar s
        forever readerloop)
    forever (recvChar s >>= maybe (return ()) (\x->
        hPutChar logPath x >> hFlush logPath >> writeChan chan x))
    closeSerial s
    hClose logPath

safeHead ls = if null ls then error "Can't find serial device" else head ls

