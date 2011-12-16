module Main where
import System.IO
import Network.Fancy

main = withStream (IP "localhost" 9000) looper

looper h = do
    c <- hGetChar h
    putChar c
    hFlush stdout
    looper h