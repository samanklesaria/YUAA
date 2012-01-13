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
main = do
    e <- epochTime
    chan <- newChan
    logPath <- openFile ("./" ++ show e) AppendMode
    fpath <- liftM (safeHead . filter (isPrefixOf "cu.usb")) (getDirectoryContents "/dev/")
    let putLogPath x = do
        b <- hIsOpen logPath
        if b then hPutChar logPath x >> hFlush logPath else return ()
    s <- openSerial ("/dev/" ++ fpath) defaultSerialSettings
    streamServer serverSpec{address = (IP "" 9000)} (\h a-> do
        chan' <- dupChan chan
        let serverloop = do
            b <- hIsOpen h
            if b then readChan chan' >>= hPutChar h >> hFlush h else return ()
        forkIO $ forever serverloop
        let readerloop = do
            b <- hIsOpen h
            if b then hGetChar h >>= sendChar s else return ()
        forever readerloop)
    forever (recvChar s >>= maybe (return ()) (\x-> putLogPath x >> writeChan chan x))
    closeSerial s
    hClose logPath

safeHead ls = if null ls then error "Can't find serial device" else head ls

